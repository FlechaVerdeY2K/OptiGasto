# Send FCM Notification Edge Function

This Supabase Edge Function sends push notifications via Firebase Cloud Messaging (FCM) HTTP v1 API.

## Setup

### 1. Get Firebase Service Account Key

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (optigasto)
3. Go to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file securely

### 2. Set Environment Variables

Set the following secrets in your Supabase project:

```bash
# Set Firebase Project ID
supabase secrets set FIREBASE_PROJECT_ID=optigasto

# Set Firebase Service Account (entire JSON as string)
supabase secrets set FIREBASE_SERVICE_ACCOUNT='{"type":"service_account","project_id":"optigasto",...}'
```

### 3. Deploy the Function

```bash
supabase functions deploy send-fcm-notification
```

## Usage

### Call from Database Trigger

This function is designed to be called automatically via a Database Webhook when a new notification is inserted.

### Manual Call (for testing)

```bash
curl -X POST 'https://YOUR_PROJECT_REF.supabase.co/functions/v1/send-fcm-notification' \
  -H 'Authorization: Bearer YOUR_ANON_KEY' \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "user-uuid-here",
    "title": "Test Notification",
    "body": "This is a test notification",
    "data": {
      "type": "test",
      "action": "open_app"
    }
  }'
```

## Request Payload

```typescript
{
  user_id: string;        // Required: User UUID
  title: string;          // Required: Notification title
  body: string;           // Required: Notification body
  data?: {                // Optional: Custom data
    [key: string]: string;
  };
  notification_type?: string; // Optional: Type of notification
}
```

## Response

```typescript
{
  success: boolean;
  sent: number;          // Number of notifications sent successfully
  total: number;         // Total number of devices
  message: string;
}
```

## Error Handling

The function will:
- Return 400 if required fields are missing
- Return 200 with success=false if no FCM tokens found
- Return 500 if an error occurs during processing
- Log errors to Supabase Edge Function logs

## Notes

- The function automatically retrieves all FCM tokens for the specified user
- Notifications are sent to all registered devices (Android, iOS, Web)
- Failed sends are logged but don't stop other notifications
- The function uses FCM HTTP v1 API (recommended by Google)

## Monitoring

Check function logs:
```bash
supabase functions logs send-fcm-notification
```

## Security

- The function uses Supabase Service Role Key for database access
- Firebase Service Account credentials are stored as Supabase secrets
- CORS is configured to allow requests from your app

## Made with Bob