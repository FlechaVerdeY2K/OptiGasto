-- ============================================
-- MIGRACIÓN: Restaurar trigger handle_new_user
-- Razón: La inserción manual en signUpWithEmail falla cuando la
-- confirmación de email está activa en Supabase (response.session = null
-- → auth.uid() = null → RLS bloquea el INSERT).
-- El trigger SECURITY DEFINER bypasea RLS y se ejecuta siempre.
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Made with Bob
