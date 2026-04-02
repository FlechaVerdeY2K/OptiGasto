-- ============================================
-- DATOS DE PRUEBA PARA OPTIGASTO
-- Seed data para desarrollo y testing
-- ============================================

-- Insertar usuarios de prueba
INSERT INTO public.users (id, email, name, photo_url, reputation, is_commerce, created_at) VALUES
    ('00000000-0000-0000-0000-000000000001', 'usuario1@test.com', 'Juan Pérez', NULL, 100, false, NOW()),
    ('00000000-0000-0000-0000-000000000002', 'usuario2@test.com', 'María González', NULL, 50, false, NOW()),
    ('00000000-0000-0000-0000-000000000003', 'comercio1@test.com', 'Super Ahorro', NULL, 0, true, NOW())
ON CONFLICT (id) DO NOTHING;

-- Insertar comercios de prueba en San José, Costa Rica
INSERT INTO public.commerces (id, name, type, latitude, longitude, address, phone, rating, is_premium, owner_id, created_at) VALUES
    ('10000000-0000-0000-0000-000000000001', 'Super Ahorro Central', 'Supermercado', 9.9281, -84.0907, 'Avenida Central, San José', '2222-3333', 4.5, false, '00000000-0000-0000-0000-000000000003', NOW()),
    ('10000000-0000-0000-0000-000000000002', 'Restaurante El Buen Sabor', 'Restaurante', 9.9350, -84.0830, 'Barrio Escalante, San José', '2233-4444', 4.8, true, '00000000-0000-0000-0000-000000000003', NOW()),
    ('10000000-0000-0000-0000-000000000003', 'Farmacia Salud Total', 'Farmacia', 9.9320, -84.0850, 'Paseo Colón, San José', '2244-5555', 4.2, false, '00000000-0000-0000-0000-000000000003', NOW()),
    ('10000000-0000-0000-0000-000000000004', 'Tienda de Ropa Fashion', 'Ropa', 9.9300, -84.0880, 'Avenida Segunda, San José', '2255-6666', 4.0, false, '00000000-0000-0000-0000-000000000003', NOW())
ON CONFLICT (id) DO NOTHING;

-- Insertar promociones de prueba
INSERT INTO public.promotions (
    id, title, description, commerce_id, commerce_name, category, discount,
    original_price, discounted_price, latitude, longitude, address,
    valid_until, created_by, is_active, created_at
) VALUES
    (
        '20000000-0000-0000-0000-000000000001',
        '2x1 en Arroz',
        'Compra un saco de arroz de 5kg y lleva otro gratis. Válido solo hoy.',
        '10000000-0000-0000-0000-000000000001',
        'Super Ahorro Central',
        'Alimentos',
        '50%',
        10000.00,
        5000.00,
        9.9281,
        -84.0907,
        'Avenida Central, San José',
        NOW() + INTERVAL '7 days',
        '00000000-0000-0000-0000-000000000001',
        true,
        NOW()
    ),
    (
        '20000000-0000-0000-0000-000000000002',
        'Menú del día ₡3500',
        'Menú completo: sopa, plato fuerte, refresco y postre por solo ₡3500',
        '10000000-0000-0000-0000-000000000002',
        'Restaurante El Buen Sabor',
        'Restaurantes',
        '30%',
        5000.00,
        3500.00,
        9.9350,
        -84.0830,
        'Barrio Escalante, San José',
        NOW() + INTERVAL '30 days',
        '00000000-0000-0000-0000-000000000002',
        true,
        NOW()
    ),
    (
        '20000000-0000-0000-0000-000000000003',
        '20% en medicamentos',
        'Descuento del 20% en todos los medicamentos de venta libre',
        '10000000-0000-0000-0000-000000000003',
        'Farmacia Salud Total',
        'Salud',
        '20%',
        NULL,
        NULL,
        9.9320,
        -84.0850,
        'Paseo Colón, San José',
        NOW() + INTERVAL '14 days',
        '00000000-0000-0000-0000-000000000001',
        true,
        NOW()
    ),
    (
        '20000000-0000-0000-0000-000000000004',
        'Liquidación de temporada',
        'Hasta 50% de descuento en ropa de temporada pasada',
        '10000000-0000-0000-0000-000000000004',
        'Tienda de Ropa Fashion',
        'Ropa',
        '50%',
        NULL,
        NULL,
        9.9300,
        -84.0880,
        'Avenida Segunda, San José',
        NOW() + INTERVAL '21 days',
        '00000000-0000-0000-0000-000000000002',
        true,
        NOW()
    )
ON CONFLICT (id) DO NOTHING;

-- Actualizar contador de promociones en comercios
UPDATE public.commerces
SET total_promotions = (
    SELECT COUNT(*)
    FROM public.promotions
    WHERE promotions.commerce_id = commerces.id
);

-- Made with Bob