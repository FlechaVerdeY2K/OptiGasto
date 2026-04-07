-- ============================================
-- CONFIGURACIÓN DE STORAGE
-- Buckets y políticas para OptiGasto
-- ============================================

-- Crear buckets de storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
    ('promotion-images', 'promotion-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('user-avatars', 'user-avatars', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp']),
    ('commerce-logos', 'commerce-logos', true, 2097152, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- POLÍTICAS PARA PROMOTION-IMAGES
-- ============================================

-- Permitir lectura pública de imágenes de promociones
CREATE POLICY "promotion_images_public_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'promotion-images');

-- Permitir subida de imágenes a usuarios autenticados
CREATE POLICY "promotion_images_authenticated_upload"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'promotion-images' 
        AND auth.role() = 'authenticated'
    );

-- Permitir actualización de imágenes al creador
CREATE POLICY "promotion_images_owner_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'promotion-images' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir eliminación de imágenes al creador
CREATE POLICY "promotion_images_owner_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'promotion-images' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================
-- POLÍTICAS PARA USER-AVATARS
-- ============================================

-- Permitir lectura pública de avatares
CREATE POLICY "user_avatars_public_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'user-avatars');

-- Permitir subida de avatar propio
CREATE POLICY "user_avatars_own_upload"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'user-avatars' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir actualización de avatar propio
CREATE POLICY "user_avatars_own_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'user-avatars' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir eliminación de avatar propio
CREATE POLICY "user_avatars_own_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'user-avatars' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ============================================
-- POLÍTICAS PARA COMMERCE-LOGOS
-- ============================================

-- Permitir lectura pública de logos
CREATE POLICY "commerce_logos_public_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'commerce-logos');

-- Permitir subida de logo a usuarios autenticados
CREATE POLICY "commerce_logos_authenticated_upload"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'commerce-logos' 
        AND auth.role() = 'authenticated'
    );

-- Permitir actualización de logo al dueño
CREATE POLICY "commerce_logos_owner_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'commerce-logos' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Permitir eliminación de logo al dueño
CREATE POLICY "commerce_logos_owner_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'commerce-logos' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Made with Bob