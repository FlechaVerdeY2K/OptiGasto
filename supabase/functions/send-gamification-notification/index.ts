import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const FCM_SERVER_KEY = Deno.env.get('FCM_SERVER_KEY')!

interface NotificationPayload {
  type: 'badge_unlock' | 'level_up' | 'loyalty_level_up'
  userId: string
  // badge_unlock
  badgeCode?: string
  badgeName?: string
  // level_up
  newLevel?: string
  // loyalty_level_up
  commerceId?: string
  commerceName?: string
  newLoyaltyLevel?: string
}

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 })
  }

  try {
    const payload: NotificationPayload = await req.json()

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Get user FCM tokens
    const { data: tokens, error: tokenError } = await supabase
      .from('fcm_tokens')
      .select('token')
      .eq('user_id', payload.userId)

    if (tokenError || !tokens || tokens.length === 0) {
      return new Response(
        JSON.stringify({ message: 'No FCM tokens found for user' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } },
      )
    }

    const { title, body, data } = buildNotificationContent(payload)

    // Send to all user devices
    const results = await Promise.all(
      tokens.map((t) => sendFcmNotification(t.token, title, body, data)),
    )

    return new Response(
      JSON.stringify({ sent: results.length, results }),
      { status: 200, headers: { 'Content-Type': 'application/json' } },
    )
  } catch (err) {
    console.error('Error sending gamification notification:', err)
    return new Response(
      JSON.stringify({ error: String(err) }),
      { status: 500, headers: { 'Content-Type': 'application/json' } },
    )
  }
})

function buildNotificationContent(payload: NotificationPayload): {
  title: string
  body: string
  data: Record<string, string>
} {
  switch (payload.type) {
    case 'badge_unlock':
      return {
        title: '🏆 ¡Nueva insignia desbloqueada!',
        body: `Conseguiste la insignia "${payload.badgeName}"`,
        data: {
          type: 'badge_unlock',
          badge_code: payload.badgeCode ?? '',
        },
      }
    case 'level_up':
      return {
        title: '⬆️ ¡Subiste de nivel!',
        body: `Ahora eres ${_levelName(payload.newLevel ?? 'bronze')}`,
        data: {
          type: 'level_up',
          new_level: payload.newLevel ?? '',
        },
      }
    case 'loyalty_level_up':
      return {
        title: '🛒 ¡Nuevo nivel de fidelidad!',
        body: `Ahora sos ${_loyaltyLevelName(payload.newLoyaltyLevel ?? '')} de ${payload.commerceName}`,
        data: {
          type: 'loyalty_level_up',
          commerce_id: payload.commerceId ?? '',
          commerce_name: payload.commerceName ?? '',
          new_level: payload.newLoyaltyLevel ?? '',
        },
      }
  }
}

function _levelName(level: string): string {
  const names: Record<string, string> = {
    bronze: 'Bronce',
    silver: 'Plata',
    gold: 'Oro',
    platinum: 'Platino',
    diamond: 'Diamante',
  }
  return names[level] ?? level
}

function _loyaltyLevelName(level: string): string {
  const names: Record<string, string> = {
    customer: 'Cliente',
    frequent: 'Frecuente',
    loyal: 'Fiel',
    vip: 'VIP',
  }
  return names[level] ?? level
}

async function sendFcmNotification(
  token: string,
  title: string,
  body: string,
  data: Record<string, string>,
): Promise<{ success: boolean; error?: string }> {
  try {
    const response = await fetch('https://fcm.googleapis.com/fcm/send', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `key=${FCM_SERVER_KEY}`,
      },
      body: JSON.stringify({
        to: token,
        notification: { title, body },
        data,
      }),
    })

    if (!response.ok) {
      return { success: false, error: `FCM HTTP ${response.status}` }
    }

    const result = await response.json()
    if (result.failure > 0) {
      return { success: false, error: result.results?.[0]?.error }
    }

    return { success: true }
  } catch (err) {
    return { success: false, error: String(err) }
  }
}
