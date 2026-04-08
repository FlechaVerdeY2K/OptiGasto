-- Migración para tabla de reportes y configuración de storage para promociones
-- Fecha: 2026-04-07

-- =====================================================
-- TABLA DE REPORTES
-- =====================================================

-- Crear tabla de reportes
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    promotion_id UUID NOT NULL REFERENCES promotions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved', 'dismissed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    
    -- Índices para mejorar rendimiento
    CONSTRAINT reports_reason_check CHECK (reason IN (
        'expired',
        'incorrect_info',
        'duplicate',
        'inappropriate',
        'spam',
        'other'
    ))
);

-- Crear índices
CREATE INDEX IF NOT EXISTS idx_reports_promotion_id ON reports(promotion_id);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- Trigger para actualizar updated_at
CREATE OR REPLACE FUNCTION update_reports_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reports_updated_at
    BEFORE UPDATE ON reports
    FOR EACH ROW
    EXECUTE FUNCTION update_reports_updated_at();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) PARA REPORTES
-- =====================================================

-- Habilitar RLS
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Política: Cualquier usuario autenticado puede crear reportes
CREATE POLICY "Users can create reports"
    ON reports
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Política: Los usuarios pueden ver sus propios reportes
CREATE POLICY "Users can view their own reports"
    ON reports
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Nota: La actualización de reportes se manejará mediante funciones RPC
-- o se puede agregar una política de admin cuando se implemente el sistema de roles

-- =====================================================
-- STORAGE BUCKETS
-- =====================================================

-- Crear bucket para imágenes de promociones (si no existe)
INSERT INTO storage.buckets (id, name, public)
VALUES ('promotions', 'promotions', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas de storage para el bucket de promociones
CREATE POLICY "Anyone can view promotion images"
    ON storage.objects FOR SELECT
    TO public
    USING (bucket_id = 'promotions');

CREATE POLICY "Authenticated users can upload promotion images"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'promotions'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update their own promotion images"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'promotions'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete their own promotion images"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'promotions'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- =====================================================
-- FUNCIONES AUXILIARES
-- =====================================================

-- Función para obtener estadísticas de reportes de una promoción
CREATE OR REPLACE FUNCTION get_promotion_report_stats(promotion_uuid UUID)
RETURNS TABLE (
    total_reports BIGINT,
    pending_reports BIGINT,
    resolved_reports BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_reports,
        COUNT(*) FILTER (WHERE status = 'pending')::BIGINT as pending_reports,
        COUNT(*) FILTER (WHERE status = 'resolved')::BIGINT as resolved_reports
    FROM reports
    WHERE promotion_id = promotion_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para marcar promoción como inactiva si tiene muchos reportes
CREATE OR REPLACE FUNCTION check_promotion_reports()
RETURNS TRIGGER AS $$
DECLARE
    report_count INTEGER;
BEGIN
    -- Contar reportes pendientes de la promoción
    SELECT COUNT(*) INTO report_count
    FROM reports
    WHERE promotion_id = NEW.promotion_id
    AND status = 'pending';
    
    -- Si hay más de 5 reportes pendientes, marcar promoción como inactiva
    IF report_count >= 5 THEN
        UPDATE promotions
        SET is_active = false,
            updated_at = NOW()
        WHERE id = NEW.promotion_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_promotion_reports_trigger
    AFTER INSERT ON reports
    FOR EACH ROW
    EXECUTE FUNCTION check_promotion_reports();

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON TABLE reports IS 'Tabla para almacenar reportes de promociones por parte de usuarios';
COMMENT ON COLUMN reports.reason IS 'Razón del reporte: expired, incorrect_info, duplicate, inappropriate, spam, other';
COMMENT ON COLUMN reports.status IS 'Estado del reporte: pending, reviewed, resolved, dismissed';

-- Made with Bob