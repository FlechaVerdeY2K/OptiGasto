-- Migration: Gamification RLS Policies
-- Description: Row Level Security policies for all gamification tables
-- Date: 2026-04-17

-- ============================================================================
-- 1. ENABLE RLS ON ALL GAMIFICATION TABLES
-- ============================================================================

ALTER TABLE points_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE commerce_loyalty ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 2. POINTS LEDGER POLICIES
-- ============================================================================

-- Users can only view their own points ledger
CREATE POLICY "Users can view own points ledger"
ON points_ledger FOR SELECT
USING (auth.uid() = user_id);

-- No direct INSERT/UPDATE/DELETE - only through SECURITY DEFINER functions
-- (Functions bypass RLS, so triggers can insert)

COMMENT ON POLICY "Users can view own points ledger" ON points_ledger 
IS 'Users can only read their own point transaction history';

-- ============================================================================
-- 3. BADGES POLICIES
-- ============================================================================

-- Everyone can view all badges (public catalog)
CREATE POLICY "Badges are publicly readable"
ON badges FOR SELECT
USING (true);

-- Only admins can modify badges (future feature)
-- For now, badges are managed through migrations only

COMMENT ON POLICY "Badges are publicly readable" ON badges 
IS 'All users can view the badge catalog';

-- ============================================================================
-- 4. USER BADGES POLICIES
-- ============================================================================

-- Everyone can view all user badges (for profiles, leaderboards, etc.)
CREATE POLICY "User badges are publicly readable"
ON user_badges FOR SELECT
USING (true);

-- No direct INSERT/UPDATE/DELETE - only through SECURITY DEFINER functions
-- (Badge unlocking happens via check_and_unlock_badges function)

COMMENT ON POLICY "User badges are publicly readable" ON user_badges 
IS 'All users can see which badges others have unlocked (for social features)';

-- ============================================================================
-- 5. COMMERCE LOYALTY POLICIES
-- ============================================================================

-- Users can only view their own loyalty data
CREATE POLICY "Users can view own commerce loyalty"
ON commerce_loyalty FOR SELECT
USING (auth.uid() = user_id);

-- Commerce owners can view loyalty data for their commerce (future feature)
-- This would require a commerce_owners table or similar

-- No direct INSERT/UPDATE/DELETE - only through SECURITY DEFINER functions
-- (Loyalty updates happen via update_commerce_loyalty function)

COMMENT ON POLICY "Users can view own commerce loyalty" ON commerce_loyalty 
IS 'Users can only view their own loyalty levels and purchase counts';

-- ============================================================================
-- 6. ADDITIONAL SECURITY: Prevent direct manipulation
-- ============================================================================

-- Ensure users table gamification columns are protected
-- Users can read their own points and level
CREATE POLICY "Users can view own gamification stats" ON users
FOR SELECT
USING (auth.uid() = id);

-- Prevent direct updates to points and level (only through triggers)
-- This is enforced by not having UPDATE policies for these columns

-- ============================================================================
-- 7. HELPER VIEWS FOR SAFE DATA ACCESS
-- ============================================================================

-- Create a view for user stats that's safe to query
CREATE OR REPLACE VIEW user_gamification_stats AS
SELECT
  u.id as user_id,
  u.name as username,
  u.points,
  u.level,
  get_points_to_next_level(u.points) as points_to_next_level,
  (SELECT COUNT(*) FROM user_badges WHERE user_id = u.id) as badge_count,
  (SELECT COUNT(*) FROM points_ledger WHERE user_id = u.id) as total_transactions
FROM users u;

COMMENT ON VIEW user_gamification_stats IS 'Safe view of user gamification statistics';

-- Grant SELECT on view to authenticated users
GRANT SELECT ON user_gamification_stats TO authenticated;

-- ============================================================================
-- 8. AUDIT LOGGING (Optional but recommended)
-- ============================================================================

-- Create audit log for suspicious activity
CREATE TABLE IF NOT EXISTS gamification_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id),
  action TEXT NOT NULL,
  details JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_gamification_audit_user ON gamification_audit_log(user_id);
CREATE INDEX idx_gamification_audit_created ON gamification_audit_log(created_at DESC);

-- Enable RLS on audit log
ALTER TABLE gamification_audit_log ENABLE ROW LEVEL SECURITY;

-- Only admins can view audit log (future feature - for now, no one can access)
-- TODO: Implement admin role system before enabling this
CREATE POLICY "Audit log access restricted"
ON gamification_audit_log FOR SELECT
USING (false);

COMMENT ON TABLE gamification_audit_log IS 'Audit log for gamification system security events';

-- ============================================================================
-- 9. RATE LIMITING HELPERS
-- ============================================================================

-- Function to check if user is rate limited
CREATE OR REPLACE FUNCTION is_rate_limited(
  p_user_id UUID,
  p_action TEXT,
  p_max_per_hour INT DEFAULT 100
) RETURNS BOOLEAN AS $$
DECLARE
  v_count INT;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM points_ledger
  WHERE user_id = p_user_id
  AND event_type = p_action
  AND created_at > now() - interval '1 hour';
  
  RETURN v_count >= p_max_per_hour;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION is_rate_limited IS 'Check if user has exceeded rate limit for an action';

-- ============================================================================
-- 10. SECURITY VALIDATIONS
-- ============================================================================

-- Function to validate point transaction integrity
CREATE OR REPLACE FUNCTION validate_points_integrity(p_user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_ledger_total INT;
  v_user_points INT;
BEGIN
  -- Sum all points from ledger
  SELECT COALESCE(SUM(points), 0) INTO v_ledger_total
  FROM points_ledger
  WHERE user_id = p_user_id;
  
  -- Get current user points
  SELECT points INTO v_user_points
  FROM users
  WHERE id = p_user_id;
  
  -- They should match (or user_points should be >= 0 if ledger has negatives)
  RETURN v_user_points = GREATEST(v_ledger_total, 0);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION validate_points_integrity IS 'Validate that user points match ledger sum';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Log completion
DO $$
BEGIN
  RAISE NOTICE 'Gamification RLS policies successfully applied';
  RAISE NOTICE 'Security features:';
  RAISE NOTICE '  - Points ledger: Users can only view own transactions';
  RAISE NOTICE '  - Badges: Publicly readable catalog';
  RAISE NOTICE '  - User badges: Publicly readable for social features';
  RAISE NOTICE '  - Commerce loyalty: Users can only view own data';
  RAISE NOTICE '  - All modifications through SECURITY DEFINER functions only';
END $$;

-- Made with Bob
