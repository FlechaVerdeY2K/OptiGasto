-- ============================================
-- FIX: Política de inserción de usuarios
-- Permite que los usuarios autenticados creen su perfil
-- ============================================

-- Eliminar la política restrictiva anterior
DROP POLICY IF EXISTS "users_insert_own" ON public.users;

-- Crear nueva política que permite a usuarios autenticados insertar su perfil
CREATE POLICY "users_insert_authenticated"
    ON public.users FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Alternativamente, crear un trigger para insertar automáticamente
-- cuando un usuario se registra en auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Crear trigger que se ejecuta cuando se crea un usuario en auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Made with Bob
