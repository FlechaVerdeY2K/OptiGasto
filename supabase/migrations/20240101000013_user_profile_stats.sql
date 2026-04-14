-- ============================================
-- MIGRACIÓN: PERFIL DE USUARIO Y ESTADÍSTICAS
-- Tablas para gestión de perfil y estadísticas
-- ============================================

-- ============================================
-- TABLA: user_stats
-- Estadísticas detalladas del usuario
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_stats (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    total_savings DOUBLE PRECISION DEFAULT 0.0,
    promotions_used INTEGER DEFAULT 0,
    promotions_published INTEGER DEFAULT 0,
    validations_given INTEGER DEFAULT 0,
    reports_submitted INTEGER DEFAULT 0,
    savings_by_category JSONB DEFAULT '{}',
    promotions_by_month JSONB DEFAULT '{}',
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_stats_user_id ON public.user_stats(user_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_total_savings ON public.user_stats(total_savings DESC);
CREATE INDEX IF NOT EXISTS idx_user_stats_promotions_used ON public.user_stats(promotions_used DESC);

COMMENT ON TABLE public.user_stats IS 'Estadísticas detalladas de cada usuario';

-- ============================================
-- TABLA: promotion_history
-- Historial de promociones usadas por el usuario
-- ============================================
CREATE TABLE IF NOT EXISTS public.promotion_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    promotion_id UUID NOT NULL REFERENCES public.promotions(id) ON DELETE CASCADE,
    promotion_title TEXT NOT NULL,
    commerce_name TEXT NOT NULL,
    category TEXT NOT NULL,
    savings_amount DOUBLE PRECISION NOT NULL,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_promotion_history_user_id ON public.promotion_history(user_id);
CREATE INDEX IF NOT EXISTS idx_promotion_history_promotion_id ON public.promotion_history(promotion_id);
CREATE INDEX IF NOT EXISTS idx_promotion_history_used_at ON public.promotion_history(used_at DESC);
CREATE INDEX IF NOT EXISTS idx_promotion_history_category ON public.promotion_history(category);

COMMENT ON TABLE public.promotion_history IS 'Historial de promociones utilizadas por los usuarios';

-- ============================================
-- STORAGE: avatars bucket
-- Bucket para fotos de perfil
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- POLÍTICAS RLS: user_stats
-- ============================================

-- Habilitar RLS
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;

-- Los usuarios pueden ver sus propias estadísticas
DROP POLICY IF EXISTS "Users can view own stats" ON public.user_stats;
CREATE POLICY "Users can view own stats"
    ON public.user_stats
    FOR SELECT
    USING (auth.uid() = user_id);

-- Los usuarios pueden insertar sus propias estadísticas
DROP POLICY IF EXISTS "Users can insert own stats" ON public.user_stats;
CREATE POLICY "Users can insert own stats"
    ON public.user_stats
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden actualizar sus propias estadísticas
DROP POLICY IF EXISTS "Users can update own stats" ON public.user_stats;
CREATE POLICY "Users can update own stats"
    ON public.user_stats
    FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS RLS: promotion_history
-- ============================================

-- Habilitar RLS
ALTER TABLE public.promotion_history ENABLE ROW LEVEL SECURITY;

-- Los usuarios pueden ver su propio historial
DROP POLICY IF EXISTS "Users can view own history" ON public.promotion_history;
CREATE POLICY "Users can view own history"
    ON public.promotion_history
    FOR SELECT
    USING (auth.uid() = user_id);

-- Los usuarios pueden insertar en su propio historial
DROP POLICY IF EXISTS "Users can insert own history" ON public.promotion_history;
CREATE POLICY "Users can insert own history"
    ON public.promotion_history
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden eliminar de su propio historial
DROP POLICY IF EXISTS "Users can delete own history" ON public.promotion_history;
CREATE POLICY "Users can delete own history"
    ON public.promotion_history
    FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- POLÍTICAS DE STORAGE: avatars
-- ============================================

-- Permitir a los usuarios subir sus propias fotos de perfil
DROP POLICY IF EXISTS "Users can upload own avatar" ON storage.objects;
CREATE POLICY "Users can upload own avatar"
    ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir a los usuarios actualizar sus propias fotos de perfil
DROP POLICY IF EXISTS "Users can update own avatar" ON storage.objects;
CREATE POLICY "Users can update own avatar"
    ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir a los usuarios eliminar sus propias fotos de perfil
DROP POLICY IF EXISTS "Users can delete own avatar" ON storage.objects;
CREATE POLICY "Users can delete own avatar"
    ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'avatars' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir a todos ver las fotos de perfil (son públicas)
-- NOTA: Esta política es reemplazada por avatars_owner_select en migración 014
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
CREATE POLICY "Anyone can view avatars"
    ON storage.objects
    FOR SELECT
    USING (bucket_id = 'avatars');

-- ============================================
-- FUNCIÓN: Actualizar estadísticas automáticamente
-- ============================================

-- Función para actualizar estadísticas cuando se publica una promoción
CREATE OR REPLACE FUNCTION update_stats_on_promotion_publish()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar o insertar estadísticas del usuario
    INSERT INTO public.user_stats (user_id, promotions_published, last_updated)
    VALUES (NEW.created_by, 1, NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        promotions_published = user_stats.promotions_published + 1,
        last_updated = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar estadísticas al publicar promoción
DROP TRIGGER IF EXISTS trigger_update_stats_on_promotion_publish ON public.promotions;
CREATE TRIGGER trigger_update_stats_on_promotion_publish
    AFTER INSERT ON public.promotions
    FOR EACH ROW
    EXECUTE FUNCTION update_stats_on_promotion_publish();

-- Función para actualizar estadísticas cuando se valida una promoción
CREATE OR REPLACE FUNCTION update_stats_on_validation()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar o insertar estadísticas del usuario que validó
    INSERT INTO public.user_stats (user_id, validations_given, last_updated)
    VALUES (NEW.user_id, 1, NOW())
    ON CONFLICT (user_id) 
    DO UPDATE SET 
        validations_given = user_stats.validations_given + 1,
        last_updated = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar estadísticas al validar (si existe tabla de validaciones)
-- Nota: Esto se activará cuando se implemente la tabla de validaciones

-- Función para actualizar estadísticas cuando se reporta una promoción
CREATE OR REPLACE FUNCTION update_stats_on_report()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar o insertar estadísticas del usuario que reportó
    INSERT INTO public.user_stats (user_id, reports_submitted, last_updated)
    VALUES (NEW.user_id, 1, NOW())
    ON CONFLICT (user_id)
    DO UPDATE SET
        reports_submitted = user_stats.reports_submitted + 1,
        last_updated = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar estadísticas al reportar
DROP TRIGGER IF EXISTS trigger_update_stats_on_report ON public.reports;
CREATE TRIGGER trigger_update_stats_on_report
    AFTER INSERT ON public.reports
    FOR EACH ROW
    EXECUTE FUNCTION update_stats_on_report();

-- ============================================
-- FUNCIÓN: Inicializar estadísticas para usuarios existentes
-- ============================================
CREATE OR REPLACE FUNCTION initialize_user_stats()
RETURNS void AS $$
BEGIN
    INSERT INTO public.user_stats (user_id, total_savings, promotions_used, promotions_published, validations_given, reports_submitted)
    SELECT 
        u.id,
        COALESCE(u.total_savings, 0.0),
        0,
        COALESCE((SELECT COUNT(*) FROM public.promotions WHERE created_by = u.id), 0),
        0,
        COALESCE((SELECT COUNT(*) FROM public.reports WHERE user_id = u.id), 0)
    FROM public.users u
    WHERE NOT EXISTS (
        SELECT 1 FROM public.user_stats WHERE user_id = u.id
    );
END;
$$ LANGUAGE plpgsql;

-- Ejecutar inicialización para usuarios existentes
SELECT initialize_user_stats();

-- Made with Bob