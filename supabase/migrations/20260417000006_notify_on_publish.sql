-- Create a notification to the publisher when their promotion goes live
-- and award points notification via in-DB create_notification function

CREATE OR REPLACE FUNCTION trigger_notify_on_publish()
RETURNS TRIGGER AS $$
BEGIN
  -- Notify the publisher that their promotion is live
  PERFORM create_notification(
    p_user_id  => NEW.created_by,
    p_title    => '¡Promoción publicada!',
    p_body     => 'Tu promoción "' || NEW.title || '" ya está activa. Ganaste 10 puntos.',
    p_type     => 'promotion_new',
    p_data     => jsonb_build_object('promotion_id', NEW.id::text, 'points_awarded', 10)
  );
  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    RAISE WARNING 'trigger_notify_on_publish error: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS notify_publisher_on_publish ON promotions;
CREATE TRIGGER notify_publisher_on_publish
  AFTER INSERT ON promotions
  FOR EACH ROW
  EXECUTE FUNCTION trigger_notify_on_publish();
