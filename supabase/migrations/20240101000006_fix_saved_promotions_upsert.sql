-- ============================================
-- FIX: Agregar política UPDATE para saved_promotions
-- Necesaria para que upsert funcione correctamente
-- ============================================

-- Los usuarios pueden actualizar sus promociones guardadas (necesario para upsert)
CREATE POLICY "saved_promotions_update_own"
    ON public.saved_promotions FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Made with Bob
