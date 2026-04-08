-- Migración para corregir políticas de storage de promociones
-- Fecha: 2026-04-07
-- Problema: Las políticas actuales verifican user_id en el path, pero usamos promotion_id

-- =====================================================
-- ELIMINAR POLÍTICAS ANTIGUAS
-- =====================================================

DROP POLICY IF EXISTS "Authenticated users can upload promotion images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own promotion images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own promotion images" ON storage.objects;

-- =====================================================
-- CREAR NUEVAS POLÍTICAS MÁS PERMISIVAS
-- =====================================================

-- Política: Usuarios autenticados pueden subir imágenes de promociones
-- El path es: promotions/{promotion_id}/{filename}
CREATE POLICY "Authenticated users can upload promotion images"
    ON storage.objects FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'promotions'
        AND (storage.foldername(name))[1] = 'promotions'
    );

-- Política: Usuarios autenticados pueden actualizar imágenes de promociones
CREATE POLICY "Authenticated users can update promotion images"
    ON storage.objects FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'promotions'
        AND (storage.foldername(name))[1] = 'promotions'
    );

-- Política: Usuarios autenticados pueden eliminar imágenes de promociones
-- (Opcional: se puede restringir más adelante para que solo el creador pueda eliminar)
CREATE POLICY "Authenticated users can delete promotion images"
    ON storage.objects FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'promotions'
        AND (storage.foldername(name))[1] = 'promotions'
    );

-- Made with Bob