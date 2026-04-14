-- Insertar categorías predefinidas
-- Esta migración inserta las categorías base para OptiGasto

-- Limpiar categorías existentes (opcional, comentar si no se desea)
-- TRUNCATE TABLE categories CASCADE;

-- Insertar categorías
INSERT INTO categories (name, icon)
VALUES
  ('Alimentos y Bebidas', '🍔'),
  ('Electrónica', '📱'),
  ('Ropa', '👕'),
  ('Hogar', '🏠'),
  ('Salud', '💊'),
  ('Deportes', '⚽'),
  ('Otros', '📦')
ON CONFLICT (name) DO NOTHING;

-- Crear índice para búsquedas rápidas por nombre
CREATE INDEX IF NOT EXISTS idx_categories_name ON categories(name);

-- Comentario
COMMENT ON TABLE categories IS 'Categorías de promociones disponibles en OptiGasto';

-- Made with Bob
