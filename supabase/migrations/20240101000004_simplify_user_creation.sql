-- ============================================
-- SIMPLIFICAR: Permitir inserción directa de usuarios
-- Eliminar trigger y usar inserción manual desde el código
-- ============================================

-- Eliminar el trigger si existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- Eliminar política anterior
DROP POLICY IF EXISTS "users_insert_authenticated" ON public.users;

-- Crear política simple que permite a cualquier usuario autenticado insertar
CREATE POLICY "users_insert_any_authenticated"
    ON public.users FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Permitir a usuarios autenticados actualizar cualquier perfil (temporal para desarrollo)
DROP POLICY IF EXISTS "users_update_own" ON public.users;
CREATE POLICY "users_update_any_authenticated"
    ON public.users FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Made with Bob
