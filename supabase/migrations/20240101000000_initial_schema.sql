-- ============================================
-- MIGRACIÓN INICIAL - OPTIGASTO
-- Esquema completo de base de datos
-- ============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "postgis";

-- ============================================
-- TABLA: users
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    photo_url TEXT,
    phone TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    reputation INTEGER DEFAULT 0,
    badges TEXT[] DEFAULT '{}',
    saved_promotions TEXT[] DEFAULT '{}',
    total_savings DOUBLE PRECISION DEFAULT 0.0,
    is_commerce BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_created_at ON public.users(created_at);

COMMENT ON TABLE public.users IS 'Usuarios de la aplicación OptiGasto';

-- ============================================
-- TABLA: categories
-- ============================================
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    icon TEXT NOT NULL,
    color TEXT NOT NULL DEFAULT '#000000',
    promotion_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_categories_name ON public.categories(name);

COMMENT ON TABLE public.categories IS 'Categorías de promociones';

-- ============================================
-- TABLA: commerces
-- ============================================
CREATE TABLE IF NOT EXISTS public.commerces (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT NOT NULL,
    phone TEXT,
    email TEXT,
    logo TEXT,
    photos TEXT[] DEFAULT '{}',
    rating DOUBLE PRECISION DEFAULT 0.0,
    total_promotions INTEGER DEFAULT 0,
    is_premium BOOLEAN DEFAULT FALSE,
    owner_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_commerces_name ON public.commerces(name);
CREATE INDEX idx_commerces_type ON public.commerces(type);
CREATE INDEX idx_commerces_location ON public.commerces(latitude, longitude);
CREATE INDEX idx_commerces_owner_id ON public.commerces(owner_id);

COMMENT ON TABLE public.commerces IS 'Comercios registrados en OptiGasto';

-- ============================================
-- TABLA: promotions
-- ============================================
CREATE TABLE IF NOT EXISTS public.promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    commerce_id UUID REFERENCES public.commerces(id) ON DELETE CASCADE,
    commerce_name TEXT NOT NULL,
    category TEXT NOT NULL,
    discount TEXT NOT NULL,
    original_price DOUBLE PRECISION,
    discounted_price DOUBLE PRECISION,
    images TEXT[] DEFAULT '{}',
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    address TEXT NOT NULL,
    valid_until TIMESTAMP WITH TIME ZONE NOT NULL,
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    positive_validations INTEGER DEFAULT 0,
    negative_validations INTEGER DEFAULT 0,
    validated_by_users TEXT[] DEFAULT '{}',
    views INTEGER DEFAULT 0,
    saves INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_promotions_commerce_id ON public.promotions(commerce_id);
CREATE INDEX idx_promotions_category ON public.promotions(category);
CREATE INDEX idx_promotions_is_active ON public.promotions(is_active);
CREATE INDEX idx_promotions_valid_until ON public.promotions(valid_until);
CREATE INDEX idx_promotions_created_at ON public.promotions(created_at DESC);
CREATE INDEX idx_promotions_location ON public.promotions(latitude, longitude);
CREATE INDEX idx_promotions_created_by ON public.promotions(created_by);
CREATE INDEX idx_promotions_title_search ON public.promotions USING gin(to_tsvector('spanish', title));
CREATE INDEX idx_promotions_description_search ON public.promotions USING gin(to_tsvector('spanish', description));

COMMENT ON TABLE public.promotions IS 'Promociones publicadas en OptiGasto';

-- ============================================
-- TABLA: saved_promotions
-- ============================================
CREATE TABLE IF NOT EXISTS public.saved_promotions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    promotion_id UUID REFERENCES public.promotions(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, promotion_id)
);

CREATE INDEX idx_saved_promotions_user_id ON public.saved_promotions(user_id);
CREATE INDEX idx_saved_promotions_promotion_id ON public.saved_promotions(promotion_id);

COMMENT ON TABLE public.saved_promotions IS 'Promociones guardadas por usuarios';

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers para updated_at
CREATE TRIGGER update_users_updated_at 
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_commerces_updated_at 
    BEFORE UPDATE ON public.commerces
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_promotions_updated_at 
    BEFORE UPDATE ON public.promotions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Función para incrementar vistas
CREATE OR REPLACE FUNCTION public.increment_promotion_views(promotion_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.promotions
    SET views = views + 1
    WHERE id = promotion_id;
END;
$$ LANGUAGE plpgsql;

-- Función para actualizar contador de promociones del comercio
CREATE OR REPLACE FUNCTION public.update_commerce_promotion_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.commerces
        SET total_promotions = total_promotions + 1
        WHERE id = NEW.commerce_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.commerces
        SET total_promotions = total_promotions - 1
        WHERE id = OLD.commerce_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_commerce_count
    AFTER INSERT OR DELETE ON public.promotions
    FOR EACH ROW EXECUTE FUNCTION public.update_commerce_promotion_count();

-- ============================================
-- DATOS INICIALES
-- ============================================

INSERT INTO public.categories (name, icon, color) VALUES
    ('Alimentos', '🍔', '#FF6B6B'),
    ('Restaurantes', '🍽️', '#4ECDC4'),
    ('Supermercados', '🛒', '#45B7D1'),
    ('Tecnología', '💻', '#96CEB4'),
    ('Ropa', '👕', '#FFEAA7'),
    ('Belleza', '💄', '#DFE6E9'),
    ('Hogar', '🏠', '#74B9FF'),
    ('Deportes', '⚽', '#A29BFE'),
    ('Entretenimiento', '🎬', '#FD79A8'),
    ('Salud', '💊', '#FDCB6E')
ON CONFLICT (name) DO NOTHING;

-- Made with Bob