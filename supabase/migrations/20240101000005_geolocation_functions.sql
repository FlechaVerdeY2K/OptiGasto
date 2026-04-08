-- ============================================
-- MIGRACIÓN: Funciones de Geolocalización
-- Funciones RPC para búsqueda de promociones y comercios cercanos
-- ============================================

-- ============================================
-- FUNCIÓN: nearby_promotions
-- Busca promociones cercanas a una ubicación
-- ============================================
CREATE OR REPLACE FUNCTION nearby_promotions(
    lat DOUBLE PRECISION,
    long DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0,
    max_results INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    commerce_id UUID,
    commerce_name TEXT,
    category TEXT,
    discount TEXT,
    original_price DOUBLE PRECISION,
    discounted_price DOUBLE PRECISION,
    images TEXT[],
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address TEXT,
    valid_until TIMESTAMP WITH TIME ZONE,
    created_by UUID,
    positive_validations INTEGER,
    negative_validations INTEGER,
    validated_by_users TEXT[],
    views INTEGER,
    saves INTEGER,
    is_active BOOLEAN,
    is_premium BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE,
    distance_km DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.description,
        p.commerce_id,
        p.commerce_name,
        p.category,
        p.discount,
        p.original_price,
        p.discounted_price,
        p.images,
        p.latitude,
        p.longitude,
        p.address,
        p.valid_until,
        p.created_by,
        p.positive_validations,
        p.negative_validations,
        p.validated_by_users,
        p.views,
        p.saves,
        p.is_active,
        p.is_premium,
        p.created_at,
        p.updated_at,
        -- Calcular distancia usando fórmula de Haversine
        (
            6371 * acos(
                cos(radians(lat)) * 
                cos(radians(p.latitude)) * 
                cos(radians(p.longitude) - radians(long)) + 
                sin(radians(lat)) * 
                sin(radians(p.latitude))
            )
        ) AS distance_km
    FROM public.promotions p
    WHERE 
        p.is_active = TRUE
        AND p.valid_until > NOW()
        AND (
            6371 * acos(
                cos(radians(lat)) * 
                cos(radians(p.latitude)) * 
                cos(radians(p.longitude) - radians(long)) + 
                sin(radians(lat)) * 
                sin(radians(p.latitude))
            )
        ) <= radius_km
    ORDER BY distance_km ASC
    LIMIT max_results;
END;
$$;

COMMENT ON FUNCTION nearby_promotions IS 'Busca promociones activas cercanas a una ubicación específica';

-- ============================================
-- FUNCIÓN: nearby_commerces
-- Busca comercios cercanos a una ubicación
-- ============================================
CREATE OR REPLACE FUNCTION nearby_commerces(
    lat DOUBLE PRECISION,
    long DOUBLE PRECISION,
    radius_km DOUBLE PRECISION DEFAULT 5.0,
    max_results INTEGER DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    type TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    address TEXT,
    phone TEXT,
    email TEXT,
    logo TEXT,
    photos TEXT[],
    rating DOUBLE PRECISION,
    total_promotions INTEGER,
    is_premium BOOLEAN,
    owner_id UUID,
    created_at TIMESTAMP WITH TIME ZONE,
    distance_km DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id,
        c.name,
        c.type,
        c.latitude,
        c.longitude,
        c.address,
        c.phone,
        c.email,
        c.logo,
        c.photos,
        c.rating,
        c.total_promotions,
        c.is_premium,
        c.owner_id,
        c.created_at,
        -- Calcular distancia usando fórmula de Haversine
        (
            6371 * acos(
                cos(radians(lat)) * 
                cos(radians(c.latitude)) * 
                cos(radians(c.longitude) - radians(long)) + 
                sin(radians(lat)) * 
                sin(radians(c.latitude))
            )
        ) AS distance_km
    FROM public.commerces c
    WHERE (
        6371 * acos(
            cos(radians(lat)) * 
            cos(radians(c.latitude)) * 
            cos(radians(c.longitude) - radians(long)) + 
            sin(radians(lat)) * 
            sin(radians(c.latitude))
        )
    ) <= radius_km
    ORDER BY distance_km ASC
    LIMIT max_results;
END;
$$;

COMMENT ON FUNCTION nearby_commerces IS 'Busca comercios cercanos a una ubicación específica';

-- ============================================
-- FUNCIÓN: calculate_distance
-- Calcula la distancia entre dos puntos geográficos
-- ============================================
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DOUBLE PRECISION,
    lon1 DOUBLE PRECISION,
    lat2 DOUBLE PRECISION,
    lon2 DOUBLE PRECISION
)
RETURNS DOUBLE PRECISION
LANGUAGE plpgsql
IMMUTABLE
AS $$
BEGIN
    -- Fórmula de Haversine para calcular distancia en kilómetros
    RETURN (
        6371 * acos(
            cos(radians(lat1)) * 
            cos(radians(lat2)) * 
            cos(radians(lon2) - radians(lon1)) + 
            sin(radians(lat1)) * 
            sin(radians(lat2))
        )
    );
END;
$$;

COMMENT ON FUNCTION calculate_distance IS 'Calcula la distancia en kilómetros entre dos coordenadas geográficas usando la fórmula de Haversine';

-- ============================================
-- ÍNDICES ESPACIALES
-- Mejoran el rendimiento de búsquedas geográficas
-- ============================================

-- Índice para búsquedas de promociones por ubicación
CREATE INDEX IF NOT EXISTS idx_promotions_location
ON public.promotions(latitude, longitude)
WHERE is_active = TRUE;

-- Índice para búsquedas de comercios por ubicación
CREATE INDEX IF NOT EXISTS idx_commerces_location 
ON public.commerces(latitude, longitude);

-- Índice compuesto para promociones activas y válidas
CREATE INDEX IF NOT EXISTS idx_promotions_active_valid 
ON public.promotions(is_active, valid_until)
WHERE is_active = TRUE;

-- ============================================
-- PERMISOS
-- Permitir ejecución de funciones RPC
-- ============================================

-- Permitir a usuarios autenticados ejecutar las funciones
GRANT EXECUTE ON FUNCTION nearby_promotions TO authenticated;
GRANT EXECUTE ON FUNCTION nearby_commerces TO authenticated;
GRANT EXECUTE ON FUNCTION calculate_distance TO authenticated;

-- Permitir a usuarios anónimos ejecutar las funciones (solo lectura)
GRANT EXECUTE ON FUNCTION nearby_promotions TO anon;
GRANT EXECUTE ON FUNCTION nearby_commerces TO anon;
GRANT EXECUTE ON FUNCTION calculate_distance TO anon;

-- Made with Bob