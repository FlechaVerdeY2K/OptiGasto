-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- Políticas de seguridad para OptiGasto
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.commerces ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_promotions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- POLÍTICAS PARA USERS
-- ============================================

-- Permitir que todos vean perfiles públicos
CREATE POLICY "users_select_public"
    ON public.users FOR SELECT
    USING (true);

-- Los usuarios pueden actualizar su propio perfil
CREATE POLICY "users_update_own"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- Los usuarios pueden insertar su propio perfil
CREATE POLICY "users_insert_own"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================
-- POLÍTICAS PARA CATEGORIES
-- ============================================

-- Todos pueden ver las categorías
CREATE POLICY "categories_select_all"
    ON public.categories FOR SELECT
    USING (true);

-- Solo administradores pueden modificar categorías (implementar después)
-- CREATE POLICY "categories_admin_only"
--     ON public.categories FOR ALL
--     USING (auth.jwt() ->> 'role' = 'admin');

-- ============================================
-- POLÍTICAS PARA COMMERCES
-- ============================================

-- Todos pueden ver los comercios
CREATE POLICY "commerces_select_all"
    ON public.commerces FOR SELECT
    USING (true);

-- Los dueños pueden actualizar sus comercios
CREATE POLICY "commerces_update_owner"
    ON public.commerces FOR UPDATE
    USING (auth.uid() = owner_id);

-- Los usuarios autenticados pueden crear comercios
CREATE POLICY "commerces_insert_authenticated"
    ON public.commerces FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

-- Los dueños pueden eliminar sus comercios
CREATE POLICY "commerces_delete_owner"
    ON public.commerces FOR DELETE
    USING (auth.uid() = owner_id);

-- ============================================
-- POLÍTICAS PARA PROMOTIONS
-- ============================================

-- Todos pueden ver promociones activas
CREATE POLICY "promotions_select_active"
    ON public.promotions FOR SELECT
    USING (is_active = true OR auth.uid() = created_by);

-- Los creadores pueden actualizar sus promociones
CREATE POLICY "promotions_update_creator"
    ON public.promotions FOR UPDATE
    USING (auth.uid() = created_by);

-- Los usuarios autenticados pueden crear promociones
CREATE POLICY "promotions_insert_authenticated"
    ON public.promotions FOR INSERT
    WITH CHECK (auth.uid() = created_by);

-- Los creadores pueden eliminar sus promociones
CREATE POLICY "promotions_delete_creator"
    ON public.promotions FOR DELETE
    USING (auth.uid() = created_by);

-- ============================================
-- POLÍTICAS PARA SAVED_PROMOTIONS
-- ============================================

-- Los usuarios pueden ver sus promociones guardadas
CREATE POLICY "saved_promotions_select_own"
    ON public.saved_promotions FOR SELECT
    USING (auth.uid() = user_id);

-- Los usuarios pueden guardar promociones
CREATE POLICY "saved_promotions_insert_own"
    ON public.saved_promotions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden eliminar sus promociones guardadas
CREATE POLICY "saved_promotions_delete_own"
    ON public.saved_promotions FOR DELETE
    USING (auth.uid() = user_id);

-- Made with Bob