-- Migración: buckets de Storage para avatares de usuario e imágenes de promociones
-- Fecha: 2026-04-17

-- =====================================================
-- BUCKET: user-avatars
-- Path esperado: {userId}/{timestamp}.jpg
-- =====================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'user-avatars',
  'user-avatars',
  true,
  5242880, -- 5 MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- SELECT: cualquiera puede ver avatares (bucket público)
DROP POLICY IF EXISTS "Anyone can view user avatars" ON storage.objects;
CREATE POLICY "Anyone can view user avatars"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'user-avatars');

-- INSERT: usuario sólo puede subir a su propia carpeta
DROP POLICY IF EXISTS "Users can upload their own avatar" ON storage.objects;
CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'user-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- UPDATE: usuario sólo puede actualizar su propia carpeta
DROP POLICY IF EXISTS "Users can update their own avatar" ON storage.objects;
CREATE POLICY "Users can update their own avatar"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'user-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- DELETE: usuario sólo puede eliminar su propia carpeta
DROP POLICY IF EXISTS "Users can delete their own avatar" ON storage.objects;
CREATE POLICY "Users can delete their own avatar"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'user-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- =====================================================
-- BUCKET: promotion-images
-- Path esperado: promotions/{promotionId}/{fileName}
-- Cualquier usuario autenticado puede subir (la validación
-- de ownership se hace en la app y en la tabla promotions).
-- =====================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'promotion-images',
  'promotion-images',
  true,
  10485760, -- 10 MB
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- SELECT: cualquiera puede ver imágenes de promociones
DROP POLICY IF EXISTS "Anyone can view promotion images" ON storage.objects;
CREATE POLICY "Anyone can view promotion images"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'promotion-images');

-- INSERT: cualquier usuario autenticado puede subir imágenes de promociones
DROP POLICY IF EXISTS "Authenticated users can upload promotion images" ON storage.objects;
CREATE POLICY "Authenticated users can upload promotion images"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'promotion-images');

-- UPDATE/DELETE: cualquier usuario autenticado (la app controla ownership)
DROP POLICY IF EXISTS "Authenticated users can update promotion images" ON storage.objects;
CREATE POLICY "Authenticated users can update promotion images"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'promotion-images');

DROP POLICY IF EXISTS "Authenticated users can delete promotion images" ON storage.objects;
CREATE POLICY "Authenticated users can delete promotion images"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'promotion-images');

-- Made with Bob
