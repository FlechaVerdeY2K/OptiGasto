// Supabase Edge Function: send-fcm-notification
// Description: Sends push notifications via Firebase Cloud Messaging (FCM) HTTP v1 API
// Author: Bob
// Date: 2024-01-01

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// CORS headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface NotificationPayload {
  user_id: string;
  title: string;
  body: string;
  data?: Record<string, string>;
  notification_type?: string;
}

interface FCMMessage {
  message: {
    token: string;
    notification: {
      title: string;
      body: string;
    };
    data?: Record<string, string>;
    android?: {
      priority: string;
      notification: {
        sound: string;
        channel_id: string;
      };
    };
    apns?: {
      payload: {
        aps: {
          sound: string;
          badge?: number;
        };
      };
    };
  };
}

// Get Firebase access token using service account
async function getAccessToken(): Promise<string> {
  const serviceAccount = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
  if (!serviceAccount) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT environment variable not set");
  }

  const serviceAccountJson = JSON.parse(serviceAccount);
  
  // Create JWT for Google OAuth2
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: serviceAccountJson.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  // Note: In production, you should use a proper JWT library
  // For now, we'll use Google's OAuth2 endpoint directly
  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: await createJWT(header, payload, serviceAccountJson.private_key),
    }),
  });

  if (!response.ok) {
    throw new Error(`Failed to get access token: ${await response.text()}`);
  }

  const data = await response.json();
  return data.access_token;
}

// Simple JWT creation (in production, use a proper library)
async function createJWT(
  header: Record<string, string>,
  payload: Record<string, any>,
  privateKey: string
): Promise<string> {
  // This is a simplified version
  // In production, use a proper JWT library like jose
  const encoder = new TextEncoder();
  const headerB64 = btoa(JSON.stringify(header));
  const payloadB64 = btoa(JSON.stringify(payload));
  const signatureInput = `${headerB64}.${payloadB64}`;
  
  // For now, return a placeholder
  // You'll need to implement proper RSA signing
  return `${signatureInput}.signature`;
}

// Send FCM notification
async function sendFCMNotification(
  token: string,
  title: string,
  body: string,
  data?: Record<string, string>
): Promise<boolean> {
  try {
    const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
    if (!projectId) {
      throw new Error("FIREBASE_PROJECT_ID environment variable not set");
    }

    const accessToken = await getAccessToken();
    
    const message: FCMMessage = {
      message: {
        token,
        notification: {
          title,
          body,
        },
        data: data || {},
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channel_id: "optigasto_fcm_channel",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
            },
          },
        },
      },
    };

    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify(message),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      console.error(`FCM send failed: ${error}`);
      return false;
    }

    return true;
  } catch (error) {
    console.error("Error sending FCM notification:", error);
    return false;
  }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // Get Supabase client
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Parse request body
    const payload: NotificationPayload = await req.json();
    const { user_id, title, body, data, notification_type } = payload;

    if (!user_id || !title || !body) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: user_id, title, body" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Get user's FCM tokens
    const { data: tokens, error: tokensError } = await supabase
      .from("fcm_tokens")
      .select("token, platform")
      .eq("user_id", user_id);

    if (tokensError) {
      throw tokensError;
    }

    if (!tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ 
          success: false, 
          message: "No FCM tokens found for user" 
        }),
        {
          status: 200,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // Send notification to all user's devices
    const results = await Promise.all(
      tokens.map((tokenData) =>
        sendFCMNotification(tokenData.token, title, body, data)
      )
    );

    const successCount = results.filter((r) => r).length;

    return new Response(
      JSON.stringify({
        success: true,
        sent: successCount,
        total: tokens.length,
        message: `Sent ${successCount} of ${tokens.length} notifications`,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("Error in send-fcm-notification function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});

// Made with Bob