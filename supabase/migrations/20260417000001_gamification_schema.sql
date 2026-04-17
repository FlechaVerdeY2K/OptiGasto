-- Migration: Gamification Schema
-- Description: Create core gamification tables for points, badges, and commerce loyalty
-- Date: 2026-04-17

-- ============================================================================
-- 1. ALTER USERS TABLE - Add gamification columns
-- ============================================================================

ALTER TABLE users ADD COLUMN IF NOT EXISTS points INT DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS level TEXT DEFAULT 'bronze';

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_points ON users(points DESC);
CREATE INDEX IF NOT EXISTS idx_users_level ON users(level);

-- Add constraint for valid levels
ALTER TABLE users ADD CONSTRAINT check_valid_level 
  CHECK (level IN ('bronze', 'silver', 'gold', 'platinum', 'diamond'));

-- ============================================================================
-- 2. POINTS LEDGER TABLE - Append-only audit log
-- ============================================================================

CREATE TABLE IF NOT EXISTS points_ledger (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL CHECK (event_type IN ('publish', 'validate', 'use', 'report_valid', 'report_false')),
  points INT NOT NULL,
  reference_id UUID,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_points_ledger_user_id ON points_ledger(user_id);
CREATE INDEX IF NOT EXISTS idx_points_ledger_created_at ON points_ledger(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_points_ledger_user_created ON points_ledger(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_points_ledger_event_type ON points_ledger(event_type);

-- Comment for documentation
COMMENT ON TABLE points_ledger IS 'Append-only audit log of all point transactions';
COMMENT ON COLUMN points_ledger.event_type IS 'Type of event: publish, validate, use, report_valid, report_false';
COMMENT ON COLUMN points_ledger.reference_id IS 'Optional reference to related entity (promotion_id, validation_id, etc)';

-- ============================================================================
-- 3. BADGES TABLE - Static catalog of all badges
-- ============================================================================

CREATE TABLE IF NOT EXISTS badges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('general', 'loyalty')),
  unlock_condition JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_badges_code ON badges(code);
CREATE INDEX IF NOT EXISTS idx_badges_category ON badges(category);

-- Comments
COMMENT ON TABLE badges IS 'Static catalog of all available badges';
COMMENT ON COLUMN badges.code IS 'Unique identifier code for the badge';
COMMENT ON COLUMN badges.unlock_condition IS 'JSONB object defining unlock criteria';

-- ============================================================================
-- 4. USER BADGES TABLE - Tracks unlocked badges per user
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_badges (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  badge_id UUID NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  unlocked_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, badge_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_user_badges_user_id ON user_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_user_badges_unlocked_at ON user_badges(unlocked_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_badges_badge_id ON user_badges(badge_id);

-- Comments
COMMENT ON TABLE user_badges IS 'Tracks which badges each user has unlocked';

-- ============================================================================
-- 5. COMMERCE LOYALTY TABLE - Per-user per-commerce tracking
-- ============================================================================

CREATE TABLE IF NOT EXISTS commerce_loyalty (
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  commerce_id UUID NOT NULL REFERENCES commerces(id) ON DELETE CASCADE,
  purchase_count INT DEFAULT 0,
  loyalty_level TEXT DEFAULT 'none' CHECK (loyalty_level IN ('none', 'customer', 'frequent', 'loyal', 'vip')),
  last_purchase_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (user_id, commerce_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_commerce_loyalty_user_id ON commerce_loyalty(user_id);
CREATE INDEX IF NOT EXISTS idx_commerce_loyalty_commerce_id ON commerce_loyalty(commerce_id);
CREATE INDEX IF NOT EXISTS idx_commerce_loyalty_purchase_count ON commerce_loyalty(purchase_count DESC);
CREATE INDEX IF NOT EXISTS idx_commerce_loyalty_level ON commerce_loyalty(loyalty_level);

-- Comments
COMMENT ON TABLE commerce_loyalty IS 'Tracks user loyalty levels per commerce';
COMMENT ON COLUMN commerce_loyalty.loyalty_level IS 'Loyalty tier: none (0-4), customer (5-9), frequent (10-24), loyal (25-49), vip (50+)';

-- ============================================================================
-- 6. MATERIALIZED VIEWS - Leaderboards
-- ============================================================================

-- Weekly Leaderboard (last 7 days)
CREATE MATERIALIZED VIEW IF NOT EXISTS leaderboard_weekly AS
SELECT
  u.id as user_id,
  u.name as username,
  COALESCE(SUM(pl.points), 0) as weekly_points,
  ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(pl.points), 0) DESC) as rank
FROM users u
LEFT JOIN points_ledger pl ON pl.user_id = u.id
  AND pl.created_at > now() - interval '7 days'
WHERE u.name IS NOT NULL
GROUP BY u.id, u.name
ORDER BY weekly_points DESC
LIMIT 100;

CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_weekly_user_id ON leaderboard_weekly(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_weekly_rank ON leaderboard_weekly(rank);

COMMENT ON MATERIALIZED VIEW leaderboard_weekly IS 'Top 100 users by points earned in last 7 days';

-- Monthly Leaderboard (last 30 days)
CREATE MATERIALIZED VIEW IF NOT EXISTS leaderboard_monthly AS
SELECT
  u.id as user_id,
  u.name as username,
  COALESCE(SUM(pl.points), 0) as monthly_points,
  ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(pl.points), 0) DESC) as rank
FROM users u
LEFT JOIN points_ledger pl ON pl.user_id = u.id
  AND pl.created_at > now() - interval '30 days'
WHERE u.name IS NOT NULL
GROUP BY u.id, u.name
ORDER BY monthly_points DESC
LIMIT 100;

CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_monthly_user_id ON leaderboard_monthly(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_monthly_rank ON leaderboard_monthly(rank);

COMMENT ON MATERIALIZED VIEW leaderboard_monthly IS 'Top 100 users by points earned in last 30 days';

-- Yearly Leaderboard (last 365 days)
CREATE MATERIALIZED VIEW IF NOT EXISTS leaderboard_yearly AS
SELECT
  u.id as user_id,
  u.name as username,
  COALESCE(SUM(pl.points), 0) as yearly_points,
  ROW_NUMBER() OVER (ORDER BY COALESCE(SUM(pl.points), 0) DESC) as rank
FROM users u
LEFT JOIN points_ledger pl ON pl.user_id = u.id
  AND pl.created_at > now() - interval '365 days'
WHERE u.name IS NOT NULL
GROUP BY u.id, u.name
ORDER BY yearly_points DESC
LIMIT 100;

CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_yearly_user_id ON leaderboard_yearly(user_id);
CREATE INDEX IF NOT EXISTS idx_leaderboard_yearly_rank ON leaderboard_yearly(rank);

COMMENT ON MATERIALIZED VIEW leaderboard_yearly IS 'Top 100 users by points earned in last 365 days';

-- ============================================================================
-- 7. HELPER FUNCTIONS
-- ============================================================================

-- Function to get points needed for next level
CREATE OR REPLACE FUNCTION get_points_to_next_level(current_points INT)
RETURNS INT AS $$
BEGIN
  RETURN CASE
    WHEN current_points < 100 THEN 100 - current_points
    WHEN current_points < 500 THEN 500 - current_points
    WHEN current_points < 2000 THEN 2000 - current_points
    WHEN current_points < 5000 THEN 5000 - current_points
    ELSE 0 -- Already at max level
  END;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_points_to_next_level IS 'Calculate points needed to reach next level';

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================

-- Made with Bob
