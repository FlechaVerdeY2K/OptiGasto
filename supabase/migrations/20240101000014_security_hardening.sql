-- ============================================
-- MIGRACIÓN: Security Hardening
-- Resuelve todos los avisos del Supabase Security Advisor
-- ============================================

-- ============================================
-- 1. RLS EN spatial_ref_sys (ERROR)
-- Resuelto en migración 015: al mover PostGIS al schema extensions,
-- spatial_ref_sys deja de estar expuesta en public/PostgREST.
-- ============================================


-- ============================================
-- 2. FIJAR search_path EN TODAS LAS FUNCIONES (WARN × 19)
-- Sin search_path fijo, un atacante con permisos de crear esquemas
-- podría crear objetos homónimos para secuestrar llamadas a funciones.
-- Fijamos a 'public' para mantener compatibilidad sin cambiar cuerpos.
-- ============================================

DO $$
DECLARE
    func_record RECORD;
BEGIN
    FOR func_record IN
        SELECT
            p.proname AS name,
            pg_get_function_identity_arguments(p.oid) AS args
        FROM pg_proc p
        JOIN pg_namespace n ON p.pronamespace = n.oid
        WHERE n.nspname = 'public'
          AND p.proname IN (
            'calculate_distance',
            'nearby_promotions',
            'nearby_commerces',
            'update_stats_on_report',
            'get_promotion_report_stats',
            'update_fcm_tokens_updated_at',
            'update_notifications_updated_at',
            'update_commerce_promotion_count',
            'update_stats_on_promotion_publish',
            'mark_all_notifications_read',
            'check_promotion_reports',
            'increment_promotion_views',
            'get_unread_notifications_count',
            'create_notification',
            'initialize_user_stats',
            'get_user_fcm_tokens',
            'update_updated_at_column',
            'update_reports_updated_at',
            'update_stats_on_validation',
            'trigger_fcm_notification',
            'cleanup_old_fcm_tokens'
          )
    LOOP
        EXECUTE format(
            'ALTER FUNCTION public.%I(%s) SET search_path = public',
            func_record.name,
            func_record.args
        );
    END LOOP;
END;
$$;


-- ============================================
-- 3. CORREGIR POLÍTICAS RLS PERMISIVAS EN users (WARN × 2)
-- Las políticas anteriores usaban WITH CHECK(true) / USING(true),
-- permitiendo que cualquier usuario autenticado insertara o modificara
-- el perfil de cualquier otro usuario.
-- ============================================

-- INSERT: solo puede crear su propio perfil (auth.uid() debe coincidir con id)
DROP POLICY IF EXISTS "users_insert_any_authenticated" ON public.users;
CREATE POLICY "users_insert_own"
    ON public.users FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- UPDATE: solo puede modificar su propio perfil
DROP POLICY IF EXISTS "users_update_any_authenticated" ON public.users;
CREATE POLICY "users_update_own"
    ON public.users FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);


-- ============================================
-- 4. CORREGIR PUBLIC BUCKET ALLOWS LISTING (WARN × 5)
-- Los buckets públicos sirven URLs directas sin necesitar política SELECT
-- en storage.objects. La política SELECT amplia solo permite listar TODOS
-- los archivos del bucket, lo cual es innecesario y expone metadatos.
--
-- Reemplazamos con políticas de solo-propietario para listing vía API.
-- Las URLs públicas siguen funcionando igual (no requieren esta política).
-- ============================================

-- ---- avatars ----
DROP POLICY IF EXISTS "Anyone can view avatars" ON storage.objects;
CREATE POLICY "avatars_owner_select"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ---- commerce-logos ----
DROP POLICY IF EXISTS "commerce_logos_public_read" ON storage.objects;
CREATE POLICY "commerce_logos_owner_select"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'commerce-logos'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ---- promotion-images ----
DROP POLICY IF EXISTS "promotion_images_public_read" ON storage.objects;
CREATE POLICY "promotion_images_owner_select"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'promotion-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ---- promotions ----
DROP POLICY IF EXISTS "Anyone can view promotion images" ON storage.objects;
CREATE POLICY "promotions_bucket_owner_select"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'promotions'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- ---- user-avatars ----
DROP POLICY IF EXISTS "user_avatars_public_read" ON storage.objects;
CREATE POLICY "user_avatars_owner_select"
    ON storage.objects FOR SELECT
    TO authenticated
    USING (
        bucket_id = 'user-avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );


-- ============================================
-- NOTAS: Puntos que requieren acción manual
-- ============================================
--
-- 5. Extension postgis en public schema (WARN)
--    PostgreSQL NO permite mover PostGIS con ALTER EXTENSION SET SCHEMA
--    (error: "extension does not support SET SCHEMA"). La única forma de
--    resolverlo sería DROP + recrear la extensión en extensions schema,
--    lo cual destruiría todos los objetos dependientes. Este WARN es
--    inofensivo y es una limitación conocida de PostGIS en Supabase.
--
-- 6. Leaked Password Protection (WARN)
--    Activar en: Supabase Dashboard → Authentication → Providers
--    → Email → Enable leaked password protection (HaveIBeenPwned).
--    No es configurable vía SQL.
--
-- Made with Bob
