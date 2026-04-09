#!/bin/bash

# Script para configurar el webhook de FCM en Supabase
# Autor: Bob
# Fecha: 2024-01-01

set -e

echo "🔧 Configurando Webhook de FCM en Supabase..."
echo ""

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar que tenemos las variables necesarias
if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo -e "${RED}❌ Error: SUPABASE_PROJECT_REF no está configurado${NC}"
    echo ""
    echo "Por favor, configura tu Project Reference:"
    echo "export SUPABASE_PROJECT_REF=xbdvrhzthyyqjyshzehg"
    exit 1
fi

if [ -z "$SUPABASE_ACCESS_TOKEN" ]; then
    echo -e "${RED}❌ Error: SUPABASE_ACCESS_TOKEN no está configurado${NC}"
    echo ""
    echo "Obtén tu Access Token en: https://supabase.com/dashboard/account/tokens"
    echo "Luego ejecuta:"
    echo "export SUPABASE_ACCESS_TOKEN=tu_token_aqui"
    exit 1
fi

# Obtener el Service Role Key desde los secrets
echo "📋 Obteniendo Service Role Key..."
SERVICE_ROLE_KEY=$(supabase secrets get SUPABASE_SERVICE_ROLE_KEY 2>/dev/null || echo "")

if [ -z "$SERVICE_ROLE_KEY" ]; then
    echo -e "${YELLOW}⚠️  No se pudo obtener SUPABASE_SERVICE_ROLE_KEY desde secrets${NC}"
    echo "Por favor, ingresa tu Service Role Key manualmente:"
    read -s SERVICE_ROLE_KEY
fi

# Configuración del webhook
WEBHOOK_NAME="send-fcm-on-notification-insert"
FUNCTION_URL="https://${SUPABASE_PROJECT_REF}.supabase.co/functions/v1/send-fcm-notification"

echo ""
echo "📝 Configuración del Webhook:"
echo "   Nombre: $WEBHOOK_NAME"
echo "   URL: $FUNCTION_URL"
echo "   Tabla: notifications"
echo "   Evento: INSERT"
echo ""

# Crear el webhook usando la API de Supabase Management
# Nota: Esta es una aproximación, ya que la API de webhooks puede variar
echo "🚀 Creando webhook..."

WEBHOOK_PAYLOAD=$(cat <<EOF
{
  "name": "$WEBHOOK_NAME",
  "type": "HTTP",
  "method": "POST",
  "url": "$FUNCTION_URL",
  "schema": "public",
  "table": "notifications",
  "events": ["INSERT"],
  "headers": {
    "Authorization": "Bearer $SERVICE_ROLE_KEY",
    "Content-Type": "application/json"
  },
  "body": {
    "user_id": "{{ record.user_id }}",
    "title": "{{ record.title }}",
    "body": "{{ record.message }}",
    "data": {
      "notification_id": "{{ record.id }}",
      "type": "{{ record.type }}",
      "created_at": "{{ record.created_at }}"
    },
    "notification_type": "{{ record.type }}"
  }
}
EOF
)

# Intentar crear el webhook
# Nota: La API exacta puede variar según la versión de Supabase
RESPONSE=$(curl -s -X POST \
  "https://api.supabase.com/v1/projects/${SUPABASE_PROJECT_REF}/database/webhooks" \
  -H "Authorization: Bearer ${SUPABASE_ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "$WEBHOOK_PAYLOAD")

# Verificar respuesta
if echo "$RESPONSE" | grep -q "error"; then
    echo -e "${RED}❌ Error al crear el webhook${NC}"
    echo ""
    echo "Respuesta de la API:"
    echo "$RESPONSE"
    echo ""
    echo -e "${YELLOW}💡 Solución alternativa:${NC}"
    echo "Configura el webhook manualmente en el Dashboard:"
    echo "https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/database/webhooks"
    echo ""
    echo "Usa la configuración en: WEBHOOK_CONFIGURATION_GUIDE.md"
    exit 1
else
    echo -e "${GREEN}✅ Webhook creado exitosamente!${NC}"
    echo ""
    echo "Respuesta:"
    echo "$RESPONSE"
fi

echo ""
echo -e "${GREEN}🎉 Configuración completada!${NC}"
echo ""
echo "Para verificar el webhook:"
echo "1. Ve a: https://supabase.com/dashboard/project/${SUPABASE_PROJECT_REF}/database/webhooks"
echo "2. Deberías ver: $WEBHOOK_NAME"
echo ""
echo "Para probar:"
echo "INSERT INTO notifications (user_id, title, message, type)"
echo "VALUES ('53916b2f-d79a-45c7-a0b0-d954176a33e9', 'Test', 'Prueba', 'system');"

# Made with Bob
