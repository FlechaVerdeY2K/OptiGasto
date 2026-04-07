-- ============================================
-- LIMPIAR tabla saved_promotions y verificar políticas
-- ============================================

-- Limpiar todos los registros existentes
TRUNCATE TABLE public.saved_promotions;

-- Eliminar políticas existentes para recrearlas correctamente
DROP POLICY IF EXISTS "saved_promotions_select_own" ON public.saved_promotions;
DROP POLICY IF EXISTS "saved_promotions_insert_own" ON public.saved_promotions;
DROP POLICY IF EXISTS "saved_promotions_update_own" ON public.saved_promotions;
DROP POLICY IF EXISTS "saved_promotions_delete_own" ON public.saved_promotions;

-- Recrear políticas con la configuración correcta
-- Los usuarios pueden ver sus promociones guardadas
CREATE POLICY "saved_promotions_select_own"
    ON public.saved_promotions FOR SELECT
    USING (auth.uid() = user_id);

-- Los usuarios pueden guardar promociones (INSERT)
CREATE POLICY "saved_promotions_insert_own"
    ON public.saved_promotions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden actualizar sus promociones guardadas (UPDATE - necesario para UPSERT)
CREATE POLICY "saved_promotions_update_own"
    ON public.saved_promotions FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Los usuarios pueden eliminar sus promociones guardadas
CREATE POLICY "saved_promotions_delete_own"
    ON public.saved_promotions FOR DELETE
    USING (auth.uid() = user_id);

-- Made with Bob
