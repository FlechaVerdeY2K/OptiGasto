-- Migration: Seed Badges
-- Description: Insert 15 global badges with unlock conditions
-- Date: 2026-04-17

-- ============================================================================
-- INSERT 15 GLOBAL BADGES
-- ============================================================================

INSERT INTO badges (code, name, description, icon, category, unlock_condition) VALUES

-- Badge 1: First Save
('first_save', 'Primer Ahorro', 'Guardaste tu primera promoción favorita', '⭐', 'general', 
 '{"type": "first_favorite", "threshold": 1}'::jsonb),

-- Badge 2: Photographer (10 promotions)
('photographer_10', 'Fotógrafo', 'Publicaste 10 promociones', '📸', 'general', 
 '{"type": "publish_count", "threshold": 10}'::jsonb),

-- Badge 3: Paparazzi (50 promotions)
('paparazzi_50', 'Paparazzi', 'Publicaste 50 promociones', '📷', 'general', 
 '{"type": "publish_count", "threshold": 50}'::jsonb),

-- Badge 4: Validator (50 validations)
('validator_50', 'Validador', 'Validaste 50 promociones', '✅', 'general', 
 '{"type": "validation_count", "threshold": 50}'::jsonb),

-- Badge 5: Inspector (200 validations)
('inspector_200', 'Inspector', 'Validaste 200 promociones', '🔍', 'general', 
 '{"type": "validation_count", "threshold": 200}'::jsonb),

-- Badge 6: Explorer (20 distinct commerces)
('explorer_20', 'Explorador', 'Visitaste 20 comercios distintos', '🗺️', 'general', 
 '{"type": "distinct_commerce_count", "threshold": 20}'::jsonb),

-- Badge 7: Adventurer (50 distinct commerces)
('adventurer_50', 'Aventurero', 'Visitaste 50 comercios distintos', '🧭', 'general', 
 '{"type": "distinct_commerce_count", "threshold": 50}'::jsonb),

-- Badge 8: Saver (₡10,000 in a month)
('saver_10k', 'Ahorrador', 'Ahorraste ₡10,000 en un mes', '💰', 'general', 
 '{"type": "monthly_savings", "threshold": 10000}'::jsonb),

-- Badge 9: Saver Pro (₡50,000 in a month)
('saver_50k', 'Ahorrador Pro', 'Ahorraste ₡50,000 en un mes', '💎', 'general', 
 '{"type": "monthly_savings", "threshold": 50000}'::jsonb),

-- Badge 10: Millionaire (₡100,000 in a month)
('millionaire', 'Millonario del Ahorro', 'Ahorraste ₡100,000 en un mes', '👑', 'general', 
 '{"type": "monthly_savings", "threshold": 100000}'::jsonb),

-- Badge 11: Fire Streak (7 consecutive days)
('streak_7', 'Racha de Fuego', '7 días consecutivos de actividad', '🔥', 'general', 
 '{"type": "daily_streak", "threshold": 7}'::jsonb),

-- Badge 12: Unstoppable (30 consecutive days)
('streak_30', 'Imparable', '30 días consecutivos de actividad', '⚡', 'general', 
 '{"type": "daily_streak", "threshold": 30}'::jsonb),

-- Badge 13: Ambassador (Top 10 monthly)
('ambassador', 'Embajador', 'Llegaste al top 10 del mes', '🏆', 'general', 
 '{"type": "leaderboard_rank", "period": "monthly", "threshold": 10}'::jsonb),

-- Badge 14: Legend (Top 3 monthly)
('legend', 'Leyenda', 'Llegaste al top 3 del mes', '👑', 'general', 
 '{"type": "leaderboard_rank", "period": "monthly", "threshold": 3}'::jsonb),

-- Badge 15: Precision (20+ validations, no false reports)
('precision', 'Precisión', '20+ validaciones sin reportes falsos', '🎯', 'general', 
 '{"type": "validation_accuracy", "min_validations": 20, "max_false_reports": 0}'::jsonb)

ON CONFLICT (code) DO NOTHING;

-- ============================================================================
-- VERIFY BADGE COUNT
-- ============================================================================

DO $$
DECLARE
  badge_count INT;
BEGIN
  SELECT COUNT(*) INTO badge_count FROM badges WHERE category = 'general';
  
  IF badge_count < 15 THEN
    RAISE WARNING 'Expected 15 badges, but found %', badge_count;
  ELSE
    RAISE NOTICE 'Successfully seeded % global badges', badge_count;
  END IF;
END $$;

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE badges IS 'Catalog of all available badges. Global badges are seeded here, loyalty badges are generated dynamically.';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Made with Bob
