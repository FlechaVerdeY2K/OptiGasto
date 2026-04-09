-- Migration: Notification Webhook for FCM
-- Description: Create database webhook to trigger FCM push notifications
-- Author: Bob
-- Date: 2024-01-01

-- Create function to call Edge Function for FCM notifications
CREATE OR REPLACE FUNCTION public.trigger_fcm_notification()
RETURNS TRIGGER AS $$
DECLARE
    webhook_url TEXT;
    service_role_key TEXT;
    payload JSONB;
BEGIN
    -- Only trigger for new notifications that haven't been sent via FCM yet
    IF TG_OP = 'INSERT' THEN
        -- Build payload for Edge Function
        payload := jsonb_build_object(
            'user_id', NEW.user_id::TEXT,
            'title', NEW.title,
            'body', NEW.message,
            'data', jsonb_build_object(
                'notification_id', NEW.id::TEXT,
                'type', NEW.type,
                'created_at', NEW.created_at::TEXT
            ),
            'notification_type', NEW.type
        );

        -- Note: The actual webhook URL and service role key should be set via
        -- Supabase Dashboard > Database > Webhooks
        -- This function is a placeholder for the webhook logic
        
        -- Log the notification for debugging
        RAISE NOTICE 'FCM notification triggered for user %: %', NEW.user_id, NEW.title;
        
        -- In production, this will be handled by a Database Webhook configured in Supabase Dashboard
        -- The webhook will POST to: https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-fcm-notification
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger on notifications table
DROP TRIGGER IF EXISTS on_notification_created_trigger_fcm ON public.notifications;
CREATE TRIGGER on_notification_created_trigger_fcm
    AFTER INSERT ON public.notifications
    FOR EACH ROW
    EXECUTE FUNCTION public.trigger_fcm_notification();

-- Add comment
COMMENT ON FUNCTION public.trigger_fcm_notification() IS 
'Trigger function to send FCM push notifications when a new notification is created. 
Configure the actual webhook in Supabase Dashboard > Database > Webhooks to call the send-fcm-notification Edge Function.';

-- Instructions for manual webhook setup (to be done in Supabase Dashboard):
-- 
-- 1. Go to Supabase Dashboard > Database > Webhooks
-- 2. Click "Create a new hook"
-- 3. Configure:
--    - Name: send-fcm-on-notification-insert
--    - Table: notifications
--    - Events: INSERT
--    - Type: HTTP Request
--    - Method: POST
--    - URL: https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-fcm-notification
--    - HTTP Headers:
--      * Authorization: Bearer YOUR_SERVICE_ROLE_KEY
--      * Content-Type: application/json
--    - HTTP Params: (leave empty)
--    - Payload:
--      {
--        "user_id": "{{ record.user_id }}",
--        "title": "{{ record.title }}",
--        "body": "{{ record.message }}",
--        "data": {
--          "notification_id": "{{ record.id }}",
--          "type": "{{ record.type }}",
--          "created_at": "{{ record.created_at }}"
--        },
--        "notification_type": "{{ record.type }}"
--      }
-- 4. Click "Create webhook"
--
-- Alternative: Use pg_net extension for HTTP requests from PostgreSQL
-- (This requires enabling pg_net extension in Supabase)

-- Made with Bob