-- =====================================================
-- NOTIFICATIONS SETUP
-- =====================================================
-- This migration creates tables and functions for the notification system
-- including notifications, notification preferences, and realtime setup

-- =====================================================
-- 1. CREATE NOTIFICATIONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN (
        'promotion_nearby',
        'promotion_expiring',
        'promotion_new',
        'badge_unlocked',
        'level_up',
        'commerce_new',
        'system'
    )),
    data JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);

-- =====================================================
-- 2. CREATE NOTIFICATION PREFERENCES TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS notification_preferences (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    enable_promotion_nearby BOOLEAN DEFAULT TRUE,
    enable_promotion_expiring BOOLEAN DEFAULT TRUE,
    enable_promotion_new BOOLEAN DEFAULT TRUE,
    enable_badge_unlocked BOOLEAN DEFAULT TRUE,
    enable_level_up BOOLEAN DEFAULT TRUE,
    enable_commerce_new BOOLEAN DEFAULT TRUE,
    enable_system BOOLEAN DEFAULT TRUE,
    radius_km DECIMAL(10, 2) DEFAULT 5.0,
    enabled_categories TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on notifications table
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "Users can view their own notifications"
    ON notifications
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own notifications (for system-generated ones)
CREATE POLICY "Users can insert their own notifications"
    ON notifications
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own notifications (mark as read, etc.)
CREATE POLICY "Users can update their own notifications"
    ON notifications
    FOR UPDATE
    USING (auth.uid() = user_id);

-- Users can delete their own notifications
CREATE POLICY "Users can delete their own notifications"
    ON notifications
    FOR DELETE
    USING (auth.uid() = user_id);

-- Enable RLS on notification_preferences table
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- Users can view their own preferences
CREATE POLICY "Users can view their own notification preferences"
    ON notification_preferences
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own preferences
CREATE POLICY "Users can insert their own notification preferences"
    ON notification_preferences
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own preferences
CREATE POLICY "Users can update their own notification preferences"
    ON notification_preferences
    FOR UPDATE
    USING (auth.uid() = user_id);

-- =====================================================
-- 4. FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for notifications table
CREATE TRIGGER update_notifications_updated_at_trigger
    BEFORE UPDATE ON notifications
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- Trigger for notification_preferences table
CREATE TRIGGER update_notification_preferences_updated_at_trigger
    BEFORE UPDATE ON notification_preferences
    FOR EACH ROW
    EXECUTE FUNCTION update_notifications_updated_at();

-- =====================================================
-- 5. FUNCTION TO CREATE NOTIFICATION
-- =====================================================

CREATE OR REPLACE FUNCTION create_notification(
    p_user_id UUID,
    p_title TEXT,
    p_body TEXT,
    p_type TEXT,
    p_data JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
    v_preferences RECORD;
BEGIN
    -- Get user preferences
    SELECT * INTO v_preferences
    FROM notification_preferences
    WHERE user_id = p_user_id;

    -- If no preferences exist, create default ones
    IF NOT FOUND THEN
        INSERT INTO notification_preferences (user_id)
        VALUES (p_user_id);
        
        SELECT * INTO v_preferences
        FROM notification_preferences
        WHERE user_id = p_user_id;
    END IF;

    -- Check if notification type is enabled
    IF (p_type = 'promotion_nearby' AND NOT v_preferences.enable_promotion_nearby) OR
       (p_type = 'promotion_expiring' AND NOT v_preferences.enable_promotion_expiring) OR
       (p_type = 'promotion_new' AND NOT v_preferences.enable_promotion_new) OR
       (p_type = 'badge_unlocked' AND NOT v_preferences.enable_badge_unlocked) OR
       (p_type = 'level_up' AND NOT v_preferences.enable_level_up) OR
       (p_type = 'commerce_new' AND NOT v_preferences.enable_commerce_new) OR
       (p_type = 'system' AND NOT v_preferences.enable_system) THEN
        RETURN NULL;
    END IF;

    -- Create notification
    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES (p_user_id, p_title, p_body, p_type, p_data)
    RETURNING id INTO v_notification_id;

    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. FUNCTION TO GET UNREAD COUNT
-- =====================================================

CREATE OR REPLACE FUNCTION get_unread_notifications_count(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO v_count
    FROM notifications
    WHERE user_id = p_user_id AND is_read = FALSE;

    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 7. FUNCTION TO MARK ALL AS READ
-- =====================================================

CREATE OR REPLACE FUNCTION mark_all_notifications_read(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE notifications
    SET is_read = TRUE, read_at = NOW()
    WHERE user_id = p_user_id AND is_read = FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 8. ENABLE REALTIME FOR NOTIFICATIONS
-- =====================================================

-- Enable realtime for notifications table
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;

-- =====================================================
-- 9. CREATE DEFAULT PREFERENCES FOR EXISTING USERS
-- =====================================================

-- Insert default preferences for existing users who don't have them
INSERT INTO notification_preferences (user_id)
SELECT id FROM users
WHERE id NOT IN (SELECT user_id FROM notification_preferences)
ON CONFLICT (user_id) DO NOTHING;

-- =====================================================
-- 10. COMMENTS FOR DOCUMENTATION
-- =====================================================

COMMENT ON TABLE notifications IS 'Stores user notifications from various sources';
COMMENT ON TABLE notification_preferences IS 'Stores user notification preferences and settings';
COMMENT ON FUNCTION create_notification IS 'Creates a new notification if user preferences allow it';
COMMENT ON FUNCTION get_unread_notifications_count IS 'Returns the count of unread notifications for a user';
COMMENT ON FUNCTION mark_all_notifications_read IS 'Marks all notifications as read for a user';

-- Made with Bob
