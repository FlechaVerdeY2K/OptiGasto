-- ============================================================
-- Fix: Corrección del filtro de descuento mínimo
-- ============================================================
-- El campo discount tiene formato "25%", "-25%", etc.
-- La extracción anterior no manejaba correctamente el signo negativo
-- y podía causar que promociones con descuento < 50% aparecieran
-- cuando se filtraba por >= 50%

CREATE OR REPLACE FUNCTION search_promotions(
  p_query   text    DEFAULT '',
  p_filters jsonb   DEFAULT '{}'::jsonb
)
RETURNS TABLE (
  id                   uuid,
  title                text,
  description          text,
  discount             text,
  original_price       double precision,
  discounted_price     double precision,
  category             text,
  commerce_id          uuid,
  commerce_name        text,
  latitude             double precision,
  longitude            double precision,
  images               text[],
  is_active            boolean,
  valid_until          timestamptz,
  views                integer,
  positive_validations integer,
  negative_validations integer,
  validated_by_users   text[],
  created_by           uuid,
  created_at           timestamptz,
  updated_at           timestamptz,
  ts_rank              real
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_min_discount  numeric  := coalesce((p_filters->>'min_discount')::numeric, 0);
  v_date_from     timestamptz := (p_filters->>'date_from')::timestamptz;
  v_date_to       timestamptz := (p_filters->>'date_to')::timestamptz;
  v_radius_km     numeric  := (p_filters->>'radius_km')::numeric;
  v_lat           double precision := (p_filters->>'lat')::double precision;
  v_lng           double precision := (p_filters->>'lng')::double precision;
  v_sort_by       text     := coalesce(p_filters->>'sort_by', 'relevance');
  v_tsquery       tsquery;
BEGIN
  -- Construir tsquery solo si hay texto
  IF p_query <> '' THEN
    v_tsquery := plainto_tsquery('spanish', p_query);
  END IF;

  RETURN QUERY
  SELECT
    p.id,
    p.title,
    p.description,
    p.discount,
    p.original_price,
    p.discounted_price,
    p.category,
    p.commerce_id,
    p.commerce_name,
    p.latitude,
    p.longitude,
    p.images,
    p.is_active,
    p.valid_until,
    p.views,
    p.positive_validations,
    p.negative_validations,
    p.validated_by_users,
    p.created_by,
    p.created_at,
    p.updated_at,
    CASE
      WHEN v_tsquery IS NOT NULL THEN ts_rank(p.search_vector, v_tsquery)
      ELSE 1.0
    END AS ts_rank
  FROM promotions p
  WHERE
    -- Solo activas
    p.is_active = true
    -- Promociones activas visibles según políticas existentes
    -- Filtro texto
    AND (v_tsquery IS NULL OR p.search_vector @@ v_tsquery)
    -- Filtro descuento mínimo
    -- Extrae el valor numérico del descuento (ej: "25%" -> 25, "-25%" -> 25)
    -- Usa ABS para manejar descuentos negativos correctamente
    AND (
      v_min_discount = 0
      OR (
        CASE 
          WHEN p.discount ~ '^-?[0-9]+\.?[0-9]*%?$' THEN
            ABS((regexp_replace(p.discount, '[^0-9.-]', '', 'g'))::numeric)
          ELSE 0
        END
      ) >= v_min_discount
    )
    -- Filtro categorías
    AND (
      p_filters->'category_ids' IS NULL
      OR jsonb_array_length(p_filters->'category_ids') = 0
      OR p.category = ANY(
           ARRAY(SELECT jsonb_array_elements_text(p_filters->'category_ids'))
         )
    )
    -- Filtro fecha desde
    AND (v_date_from IS NULL OR p.valid_until >= v_date_from)
    -- Filtro fecha hasta
    AND (v_date_to IS NULL OR p.valid_until <= v_date_to)
    -- Filtro distancia (Haversine simplificado en grados; usar PostGIS si disponible)
    AND (
      v_radius_km IS NULL
      OR v_lat IS NULL
      OR v_lng IS NULL
      OR (
        6371.0 * 2 * asin(
          sqrt(
            power(sin(radians((p.latitude - v_lat) / 2)), 2) +
            cos(radians(v_lat)) * cos(radians(p.latitude)) *
            power(sin(radians((p.longitude - v_lng) / 2)), 2)
          )
        )
      ) <= v_radius_km
    )
  ORDER BY
    CASE
      WHEN v_sort_by = 'relevance' AND v_tsquery IS NOT NULL
        THEN ts_rank(p.search_vector, v_tsquery)
      ELSE NULL
    END DESC NULLS LAST,
    CASE WHEN v_sort_by = 'discount'
      THEN ABS((regexp_replace(p.discount, '[^0-9.-]', '', 'g'))::numeric)
      ELSE NULL
    END DESC NULLS LAST,
    CASE WHEN v_sort_by = 'newest'
      THEN EXTRACT(EPOCH FROM p.created_at)
      ELSE NULL
    END DESC NULLS LAST,
    CASE WHEN v_sort_by = 'distance' AND v_lat IS NOT NULL AND v_lng IS NOT NULL
      THEN (
        6371.0 * 2 * asin(
          sqrt(
            power(sin(radians((p.latitude - v_lat) / 2)), 2) +
            cos(radians(v_lat)) * cos(radians(p.latitude)) *
            power(sin(radians((p.longitude - v_lng) / 2)), 2)
          )
        )
      )
      ELSE NULL
    END ASC NULLS LAST,
    p.created_at DESC;
END;
$$;

-- Mantener permisos
GRANT EXECUTE ON FUNCTION search_promotions(text, jsonb) TO authenticated;

-- Made with Bob
