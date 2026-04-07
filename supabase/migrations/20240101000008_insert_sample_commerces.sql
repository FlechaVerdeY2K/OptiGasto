-- Insertar comercios de ejemplo para Costa Rica
-- Esta migración inserta comercios de prueba para facilitar el desarrollo y testing

-- Insertar comercios de ejemplo (solo si no existen)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM commerces LIMIT 1) THEN
    INSERT INTO commerces (name, type, address, latitude, longitude, phone, email)
    VALUES
      ('Automercado Escazú', 'Supermercado', 'Multiplaza Escazú, San José', 9.9281, -84.1311, '+506 2201-9800', 'info@automercado.cr'),
      ('Walmart San Pedro', 'Supermercado', 'San Pedro de Montes de Oca, San José', 9.9350, -84.0514, '+506 2283-6000', 'contacto@walmart.cr'),
      ('Restaurante Grano de Oro', 'Restaurante', 'Paseo Colón, San José', 9.9333, -84.0961, '+506 2255-3322', 'reservas@hotelgranodeoro.com'),
      ('Soda Tapia', 'Restaurante', 'La Sabana, San José', 9.9400, -84.1050, '+506 2222-6734', NULL),
      ('Gollo Multiplaza', 'Tienda', 'Multiplaza Escazú, San José', 9.9281, -84.1311, '+506 2519-5000', 'servicio@gollo.com'),
      ('Extreme Tech', 'Tienda', 'San Pedro de Montes de Oca, San José', 9.9350, -84.0514, '+506 2280-8080', 'ventas@extremetech.cr'),
      ('Zara Multiplaza', 'Tienda', 'Multiplaza Escazú, San José', 9.9281, -84.1311, '+506 2201-5500', NULL),
      ('Tienda Universal', 'Tienda', 'Avenida Central, San José', 9.9333, -84.0833, '+506 2222-2222', 'info@universal.cr'),
      ('Farmacia Fischel', 'Farmacia', 'Paseo Colón, San José', 9.9333, -84.0961, '+506 2257-1414', 'info@fischel.cr'),
      ('Farmacia Sucre', 'Farmacia', 'San Pedro de Montes de Oca, San José', 9.9350, -84.0514, '+506 2224-6666', 'contacto@farmaciasucre.com');
  END IF;
END $$;

-- Crear índices para búsquedas eficientes
CREATE INDEX IF NOT EXISTS idx_commerces_name ON commerces(name);
CREATE INDEX IF NOT EXISTS idx_commerces_location ON commerces(latitude, longitude);

-- Comentario
COMMENT ON TABLE commerces IS 'Comercios registrados en OptiGasto con ubicaciones en Costa Rica';

-- Made with Bob
