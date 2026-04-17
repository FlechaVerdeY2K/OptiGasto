-- Fix gamification triggers: promotions table uses 'created_by', not 'user_id'

-- Fix trigger_award_publish_points
CREATE OR REPLACE FUNCTION trigger_award_publish_points()
RETURNS TRIGGER AS $$
BEGIN
  PERFORM award_points(NEW.created_by, 'publish', NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Fix check_and_unlock_badges: query promotions by created_by
CREATE OR REPLACE FUNCTION check_and_unlock_badges(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
  v_badge RECORD;
  v_count INTEGER;
  v_condition TEXT;
  v_threshold INTEGER;
BEGIN
  FOR v_badge IN
    SELECT b.*
    FROM badges b
    WHERE NOT EXISTS (
      SELECT 1 FROM user_badges ub
      WHERE ub.user_id = p_user_id AND ub.badge_id = b.id
    )
  LOOP
    BEGIN
      v_condition := v_badge.unlock_condition->>'type';
      v_threshold := (v_badge.unlock_condition->>'threshold')::INTEGER;

      IF v_condition = 'promotions_published' THEN
        SELECT COUNT(*) INTO v_count
        FROM promotions WHERE created_by = p_user_id;
      ELSIF v_condition = 'promotions_validated' THEN
        SELECT COUNT(*) INTO v_count
        FROM promotion_validations WHERE user_id = p_user_id;
      ELSIF v_condition = 'loyalty_visits' THEN
        SELECT COALESCE(MAX(purchase_count), 0) INTO v_count
        FROM commerce_loyalty WHERE user_id = p_user_id AND purchase_count > 0;
      ELSIF v_condition = 'promotions_used' THEN
        SELECT COUNT(*) INTO v_count
        FROM promotion_history ph
        WHERE ph.user_id = p_user_id
          AND ph.used_at >= NOW() - INTERVAL '30 days';
      ELSIF v_condition = 'points_total' THEN
        SELECT COALESCE(SUM(points), 0) INTO v_count
        FROM points_ledger
          WHERE user_id = p_user_id;
      ELSIF v_condition = 'validations_given' THEN
        SELECT COUNT(*) INTO v_count
        FROM promotion_validations WHERE user_id = p_user_id;
      ELSE
        CONTINUE;
      END IF;

      IF v_count >= v_threshold THEN
        INSERT INTO user_badges (user_id, badge_id)
        VALUES (p_user_id, v_badge.id)
        ON CONFLICT DO NOTHING;
        RAISE NOTICE 'Badge unlocked: % for user %', v_badge.id, p_user_id;
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE WARNING 'Error in check_and_unlock_badges for user %: %', p_user_id, SQLERRM;
    END;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
