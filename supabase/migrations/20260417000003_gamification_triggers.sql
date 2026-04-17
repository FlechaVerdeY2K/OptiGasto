-- Migration: Gamification Triggers and Functions
-- Description: Server-side point calculation, badge unlocking, and loyalty tracking
-- Date: 2026-04-17

-- ============================================================================
-- 1. CENTRAL FUNCTION: award_points
-- ============================================================================

CREATE OR REPLACE FUNCTION award_points(
  p_user_id UUID,
  p_event_type TEXT,
  p_reference_id UUID DEFAULT NULL
) RETURNS void AS $$
DECLARE
  v_points INT;
  v_new_total INT;
  v_old_level TEXT;
  v_new_level TEXT;
BEGIN
  -- Determine points based on event type
  v_points := CASE p_event_type
    WHEN 'publish' THEN 10
    WHEN 'validate' THEN 5
    WHEN 'use' THEN 3
    WHEN 'report_valid' THEN 2
    WHEN 'report_false' THEN -10
    ELSE 0
  END;

  -- Insert into ledger (append-only audit log)
  INSERT INTO points_ledger (user_id, event_type, points, reference_id)
  VALUES (p_user_id, p_event_type, v_points, p_reference_id);

  -- Get old level before update
  SELECT level INTO v_old_level FROM users WHERE id = p_user_id;

  -- Update user total points
  UPDATE users 
  SET points = GREATEST(points + v_points, 0)  -- Prevent negative points
  WHERE id = p_user_id
  RETURNING points INTO v_new_total;

  -- Calculate new level based on total points
  v_new_level := CASE
    WHEN v_new_total >= 5000 THEN 'diamond'
    WHEN v_new_total >= 2000 THEN 'platinum'
    WHEN v_new_total >= 500 THEN 'gold'
    WHEN v_new_total >= 100 THEN 'silver'
    ELSE 'bronze'
  END;

  -- Update level if changed
  IF v_new_level != v_old_level THEN
    UPDATE users 
    SET level = v_new_level
    WHERE id = p_user_id;
    
    RAISE NOTICE 'User % leveled up from % to %', p_user_id, v_old_level, v_new_level;
  END IF;

  -- Check for badge unlocks
  PERFORM check_and_unlock_badges(p_user_id);

  -- Update commerce loyalty if 'use' event
  IF p_event_type = 'use' AND p_reference_id IS NOT NULL THEN
    PERFORM update_commerce_loyalty(p_user_id, p_reference_id);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error in award_points for user %: %', p_user_id, SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION award_points IS 'Central function for awarding points, updating levels, and triggering badge checks';

-- ============================================================================
-- 2. FUNCTION: check_and_unlock_badges
-- ============================================================================

CREATE OR REPLACE FUNCTION check_and_unlock_badges(p_user_id UUID) 
RETURNS void AS $$
DECLARE
  v_badge RECORD;
  v_condition JSONB;
  v_should_unlock BOOLEAN;
  v_count INT;
  v_threshold INT;
BEGIN
  -- Loop through all badges not yet unlocked by user
  FOR v_badge IN 
    SELECT b.* FROM badges b
    WHERE b.category = 'general'  -- Only check global badges (loyalty badges are dynamic)
    AND NOT EXISTS (
      SELECT 1 FROM user_badges ub 
      WHERE ub.user_id = p_user_id AND ub.badge_id = b.id
    )
  LOOP
    v_condition := v_badge.unlock_condition;
    v_should_unlock := FALSE;

    -- Check condition based on type
    CASE v_condition->>'type'
      
      -- Publish count badges
      WHEN 'publish_count' THEN
        v_threshold := (v_condition->>'threshold')::INT;
        SELECT COUNT(*) INTO v_count
        FROM promotions WHERE user_id = p_user_id;
        v_should_unlock := v_count >= v_threshold;
      
      -- Validation count badges
      WHEN 'validation_count' THEN
        v_threshold := (v_condition->>'threshold')::INT;
        SELECT COUNT(*) INTO v_count
        FROM promotion_validations WHERE user_id = p_user_id;
        v_should_unlock := v_count >= v_threshold;
      
      -- Distinct commerce count badges
      WHEN 'distinct_commerce_count' THEN
        v_threshold := (v_condition->>'threshold')::INT;
        SELECT COUNT(DISTINCT commerce_id) INTO v_count
        FROM commerce_loyalty WHERE user_id = p_user_id AND purchase_count > 0;
        v_should_unlock := v_count >= v_threshold;
      
      -- Monthly savings badges
      WHEN 'monthly_savings' THEN
        v_threshold := (v_condition->>'threshold')::INT;
        SELECT COALESCE(SUM(ph.savings_amount), 0) INTO v_count
        FROM promotion_history ph
        WHERE ph.user_id = p_user_id
        AND ph.used_at >= date_trunc('month', CURRENT_DATE);
        v_should_unlock := v_count >= v_threshold;
      
      -- Daily streak badges
      WHEN 'daily_streak' THEN
        v_threshold := (v_condition->>'threshold')::INT;
        -- Check for consecutive days with activity
        WITH daily_activity AS (
          SELECT DISTINCT DATE(created_at) as activity_date
          FROM points_ledger
          WHERE user_id = p_user_id
          ORDER BY activity_date DESC
        ),
        streak_calc AS (
          SELECT 
            activity_date,
            activity_date - (ROW_NUMBER() OVER (ORDER BY activity_date))::INT as grp
          FROM daily_activity
        ),
        max_streak AS (
          SELECT COUNT(*) as streak_length
          FROM streak_calc
          GROUP BY grp
          ORDER BY streak_length DESC
          LIMIT 1
        )
        SELECT COALESCE(streak_length, 0) INTO v_count FROM max_streak;
        v_should_unlock := v_count >= v_threshold;
      
      -- Leaderboard rank badges
      WHEN 'leaderboard_rank' THEN
        v_threshold := (v_condition->>'threshold')::INT;
        IF v_condition->>'period' = 'monthly' THEN
          SELECT rank INTO v_count
          FROM leaderboard_monthly
          WHERE user_id = p_user_id;
          v_should_unlock := v_count IS NOT NULL AND v_count <= v_threshold;
        END IF;
      
      -- Validation accuracy badge
      WHEN 'validation_accuracy' THEN
        DECLARE
          v_min_validations INT := (v_condition->>'min_validations')::INT;
          v_validation_count INT;
          v_false_report_count INT;
        BEGIN
          -- Count validations
          SELECT COUNT(*) INTO v_validation_count
          FROM promotion_validations WHERE user_id = p_user_id;
          
          -- Count false reports on user's validations (if reports table exists)
          -- This is a placeholder - adjust based on actual reports schema
          v_false_report_count := 0;
          
          v_should_unlock := v_validation_count >= v_min_validations 
                            AND v_false_report_count = 0;
        END;
      
      -- First favorite badge
      WHEN 'first_favorite' THEN
        -- This would check favorites table if it exists
        -- Placeholder for now
        v_should_unlock := FALSE;
      
      ELSE
        v_should_unlock := FALSE;
    END CASE;

    -- Unlock badge if condition met
    IF v_should_unlock THEN
      INSERT INTO user_badges (user_id, badge_id)
      VALUES (p_user_id, v_badge.id)
      ON CONFLICT DO NOTHING;
      
      RAISE NOTICE 'Badge unlocked: % for user %', v_badge.code, p_user_id;
    END IF;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error in check_and_unlock_badges for user %: %', p_user_id, SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION check_and_unlock_badges IS 'Check all badge conditions and unlock if criteria met';

-- ============================================================================
-- 3. FUNCTION: update_commerce_loyalty
-- ============================================================================

CREATE OR REPLACE FUNCTION update_commerce_loyalty(
  p_user_id UUID,
  p_promotion_id UUID
) RETURNS void AS $$
DECLARE
  v_commerce_id UUID;
  v_new_count INT;
  v_old_level TEXT;
  v_new_level TEXT;
BEGIN
  -- Get commerce_id from promotion (promotion_id is from promotion_history)
  SELECT p.commerce_id INTO v_commerce_id
  FROM promotions p
  WHERE p.id = p_promotion_id;

  IF v_commerce_id IS NULL THEN
    RETURN;
  END IF;

  -- Get old loyalty level
  SELECT loyalty_level INTO v_old_level
  FROM commerce_loyalty
  WHERE user_id = p_user_id AND commerce_id = v_commerce_id;

  -- Upsert commerce_loyalty
  INSERT INTO commerce_loyalty (user_id, commerce_id, purchase_count, last_purchase_at)
  VALUES (p_user_id, v_commerce_id, 1, now())
  ON CONFLICT (user_id, commerce_id) 
  DO UPDATE SET 
    purchase_count = commerce_loyalty.purchase_count + 1,
    last_purchase_at = now()
  RETURNING purchase_count INTO v_new_count;

  -- Calculate new loyalty level
  v_new_level := CASE
    WHEN v_new_count >= 50 THEN 'vip'
    WHEN v_new_count >= 25 THEN 'loyal'
    WHEN v_new_count >= 10 THEN 'frequent'
    WHEN v_new_count >= 5 THEN 'customer'
    ELSE 'none'
  END;

  -- Update loyalty level if changed
  IF v_new_level != COALESCE(v_old_level, 'none') THEN
    UPDATE commerce_loyalty
    SET loyalty_level = v_new_level
    WHERE user_id = p_user_id AND commerce_id = v_commerce_id;
    
    RAISE NOTICE 'User % loyalty level changed from % to % for commerce %', 
                 p_user_id, COALESCE(v_old_level, 'none'), v_new_level, v_commerce_id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'Error in update_commerce_loyalty: %', SQLERRM;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_commerce_loyalty IS 'Update user loyalty level for a specific commerce';

-- ============================================================================
-- 4. TRIGGER: Award points on promotion publish
-- ============================================================================

CREATE OR REPLACE FUNCTION trigger_award_publish_points()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM award_points(NEW.user_id, 'publish', NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS award_publish_points ON promotions;
CREATE TRIGGER award_publish_points
AFTER INSERT ON promotions
FOR EACH ROW
EXECUTE FUNCTION trigger_award_publish_points();

COMMENT ON FUNCTION trigger_award_publish_points IS 'Trigger function to award points when promotion is published';

-- ============================================================================
-- 5. TRIGGER: Award points on promotion use
-- ============================================================================

CREATE OR REPLACE FUNCTION trigger_award_use_points()
RETURNS TRIGGER AS $$
BEGIN
  -- Award points when promotion is added to history (used)
  PERFORM award_points(NEW.user_id, 'use', NEW.promotion_id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS award_use_points ON promotion_history;
CREATE TRIGGER award_use_points
AFTER INSERT ON promotion_history
FOR EACH ROW
EXECUTE FUNCTION trigger_award_use_points();

COMMENT ON FUNCTION trigger_award_use_points IS 'Trigger function to award points when promotion is added to history (used)';

-- ============================================================================
-- 6. TRIGGER: Award points on validation
-- ============================================================================
-- NOTE: Commented out until promotion_validations table is created
-- This will be enabled in a future migration when validation feature is implemented

-- CREATE OR REPLACE FUNCTION trigger_award_validation_points()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   PERFORM award_points(NEW.user_id, 'validate', NEW.id);
--   RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- DROP TRIGGER IF EXISTS award_validation_points ON promotion_validations;
-- CREATE TRIGGER award_validation_points
-- AFTER INSERT ON promotion_validations
-- FOR EACH ROW
-- EXECUTE FUNCTION trigger_award_validation_points();

-- COMMENT ON FUNCTION trigger_award_validation_points IS 'Trigger function to award points when user validates a promotion';

-- ============================================================================
-- 7. CRON JOB: Refresh leaderboard materialized views
-- ============================================================================

-- Enable pg_cron extension if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule refresh every hour at minute 0
-- Note: Wrapped in DO block to handle if cron job already exists
DO $$
BEGIN
  -- Unschedule if exists
  PERFORM cron.unschedule('refresh-leaderboards');
EXCEPTION
  WHEN OTHERS THEN NULL;
END $$;

-- Schedule the job
SELECT cron.schedule(
  'refresh-leaderboards',
  '0 * * * *',  -- Every hour at minute 0
  $$
    REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_weekly;
    REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_monthly;
    REFRESH MATERIALIZED VIEW CONCURRENTLY leaderboard_yearly;
  $$
);

-- ============================================================================
-- 8. HELPER FUNCTION: Get user's current rank in leaderboard
-- ============================================================================

CREATE OR REPLACE FUNCTION get_user_leaderboard_rank(
  p_user_id UUID,
  p_period TEXT DEFAULT 'monthly'
) RETURNS INT AS $$
DECLARE
  v_rank INT;
BEGIN
  CASE p_period
    WHEN 'weekly' THEN
      SELECT rank INTO v_rank FROM leaderboard_weekly WHERE user_id = p_user_id;
    WHEN 'monthly' THEN
      SELECT rank INTO v_rank FROM leaderboard_monthly WHERE user_id = p_user_id;
    WHEN 'yearly' THEN
      SELECT rank INTO v_rank FROM leaderboard_yearly WHERE user_id = p_user_id;
    ELSE
      v_rank := NULL;
  END CASE;
  
  RETURN v_rank;
END;
$$ LANGUAGE plpgsql STABLE;

COMMENT ON FUNCTION get_user_leaderboard_rank IS 'Get user rank in specified leaderboard period';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Made with Bob
