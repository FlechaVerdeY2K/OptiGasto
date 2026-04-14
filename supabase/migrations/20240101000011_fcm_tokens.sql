-- Migration: FCM Tokens Table
-- Description: Create table to store Firebase Cloud Messaging tokens for push notifications
-- Author: Bob
-- Date: 2024-01-01

-- Create fcm_tokens table
CREATE TABLE IF NOT EXISTS public.fcm_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    token TEXT NOT NULL,
    platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Ensure unique combination of user_id and token
    UNIQUE(user_id, token)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_user_id ON public.fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_token ON public.fcm_tokens(token);
CREATE INDEX IF NOT EXISTS idx_fcm_tokens_platform ON public.fcm_tokens(platform);

-- Enable Row Level Security
ALTER TABLE public.fcm_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policies for fcm_tokens
-- Users can only view their own tokens
CREATE POLICY "Users can view own FCM tokens"
    ON public.fcm_tokens
    FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own tokens
CREATE POLICY "Users can insert own FCM tokens"
    ON public.fcm_tokens
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own tokens
CREATE POLICY "Users can update own FCM tokens"
    ON public.fcm_tokens
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tokens
CREATE POLICY "Users can delete own FCM tokens"
    ON public.fcm_tokens
    FOR DELETE
    USING (auth.uid() = user_id);

-- Service role can manage all tokens (for admin operations)
CREATE POLICY "Service role can manage all FCM tokens"
    ON public.fcm_tokens
    FOR ALL
    USING (auth.jwt()->>'role' = 'service_role');

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_fcm_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at
CREATE TRIGGER update_fcm_tokens_updated_at
    BEFORE UPDATE ON public.fcm_tokens
    FOR EACH ROW
    EXECUTE FUNCTION public.update_fcm_tokens_updated_at();

-- Function to clean up old/inactive tokens (optional, can be called periodically)
CREATE OR REPLACE FUNCTION public.cleanup_old_fcm_tokens(days_old INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM public.fcm_tokens
    WHERE updated_at < NOW() - (days_old || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.fcm_tokens TO authenticated;
GRANT ALL ON public.fcm_tokens TO service_role;

-- Add comment to table
COMMENT ON TABLE public.fcm_tokens IS 'Stores Firebase Cloud Messaging tokens for push notifications';
COMMENT ON COLUMN public.fcm_tokens.user_id IS 'Reference to the user who owns this token';
COMMENT ON COLUMN public.fcm_tokens.token IS 'FCM device token';
COMMENT ON COLUMN public.fcm_tokens.platform IS 'Platform type: android, ios, or web';
COMMENT ON COLUMN public.fcm_tokens.created_at IS 'Timestamp when token was first registered';
COMMENT ON COLUMN public.fcm_tokens.updated_at IS 'Timestamp when token was last updated';

-- Made with Bob