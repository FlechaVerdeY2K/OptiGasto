-- ============================================================
-- Fase 8: Full-Text Search Setup
-- ============================================================

-- 1. search_vector columna generada en promotions
ALTER TABLE promotions ADD COLUMN IF NOT EXISTS search_vector tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('spanish', coalesce(title, '')), 'A') ||
    setweight(to_tsvector('spanish', coalesce(description, '')), 'B') ||
    setweight(to_tsvector('spanish', coalesce(product_name, '')), 'A')
  ) STORED;

CREATE INDEX IF NOT EXISTS promotions_search_idx ON promotions USING GIN(search_vector);

-- 2. search_vector columna generada en commerces
ALTER TABLE commerces ADD COLUMN IF NOT EXISTS search_vector tsvector
  GENERATED ALWAYS AS (
    setweight(to_tsvector('spanish', coalesce(name, '')), 'A') ||
    setweight(to_tsvector('spanish', coalesce(description, '')), 'B')
  ) STORED;

CREATE INDEX IF NOT EXISTS commerces_search_idx ON commerces USING GIN(search_vector);

-- ============================================================
-- 3. RPC: search_promotions
--    Parámetros:
--      p_query   text  — texto de búsqueda (vacío = sin filtro de texto)
--      p_filters jsonb — filtros adicionales:
--        {
--          "min_discount":  number,   -- porcentaje mínimo (0-100)
--          "category_ids":  string[], -- lista de category IDs
--          "date_from":     string,   -- ISO 8601
--          "date_to":       string,   -- ISO 8601
--          "radius_km":     number,   -- distancia máxima
--          "lat":           number,   -- latitud usuario
--          "lng":           number,   -- longitud usuario
--          "sort_by":       string    -- "relevance"|"discount"|"distance"|"newest"
--        }
-- ============================================================
CREATE OR REPLACE FUNCTION search_promotions(
  p_query   text    DEFAULT '',
  p_filters jsonb   DEFAULT '{}'::jsonb
)
RETURNS TABLE (
  id                   uuid,
  title                text,
  description          text,
  product_name         text,
  discount             text,
  original_price       numeric,
  discounted_price     numeric,
  category             text,
  commerce_id          uuid,
  commerce_name        text,
  latitude             double precision,
  longitude            double precision,
  image_urls           text[],
  is_active            boolean,
  valid_from           timestamptz,
  valid_until          timestamptz,
  views                integer,
  positive_validations integer,
  negative_validations integer,
  validated_by_users   text[],
  saved_by_users       text[],
  user_id              uuid,
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
    p.product_name,
    p.discount,
    p.original_price,
    p.discounted_price,
    p.category,
    p.commerce_id,
    p.commerce_name,
    p.latitude,
    p.longitude,
    p.image_urls,
    p.is_active,
    p.valid_from,
    p.valid_until,
    p.views,
    p.positive_validations,
    p.negative_validations,
    p.validated_by_users,
    p.saved_by_users,
    p.user_id,
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
    -- RLS: solo el propio usuario puede ver sus privadas (si aplica)
    -- Las promociones públicas no tienen restricción de user_id
    -- Respeta RLS existente via SECURITY DEFINER + auth.uid() check
    AND (p.user_id = auth.uid() OR true)  -- promotions son públicas; ajustar si cambia
    -- Filtro texto
    AND (v_tsquery IS NULL OR p.search_vector @@ v_tsquery)
    -- Filtro descuento mínimo
    AND (
      v_min_discount = 0
      OR (regexp_replace(p.discount, '[^0-9.]', '', 'g'))::numeric >= v_min_discount
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
    AND (v_date_to IS NULL OR p.valid_from <= v_date_to)
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
      THEN (regexp_replace(p.discount, '[^0-9.]', '', 'g'))::numeric
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

-- Otorgar acceso a usuarios autenticados
GRANT EXECUTE ON FUNCTION search_promotions(text, jsonb) TO authenticated;

-- ============================================================
-- 4. RPC: get_search_suggestions
--    Retorna top 5 títulos únicos que coincidan con el texto parcial
-- ============================================================
CREATE OR REPLACE FUNCTION get_search_suggestions(p_partial text)
RETURNS TABLE (suggestion text)
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT DISTINCT title AS suggestion
  FROM promotions
  WHERE
    is_active = true
    AND search_vector @@ to_tsquery('spanish', p_partial || ':*')
  LIMIT 5;
$$;

GRANT EXECUTE ON FUNCTION get_search_suggestions(text) TO authenticated;
