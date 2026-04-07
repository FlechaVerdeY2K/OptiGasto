#!/bin/bash

# ============================================
# Script de Configuración Rápida de Supabase
# OptiGasto
# ============================================

set -e

echo "🚀 Configurando Supabase para OptiGasto..."
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar si Supabase CLI está instalado
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Supabase CLI no está instalado${NC}"
    echo ""
    echo "Instálalo con:"
    echo "  macOS/Linux: brew install supabase/tap/supabase"
    echo "  Windows: scoop install supabase"
    exit 1
fi

echo -e "${GREEN}✅ Supabase CLI encontrado${NC}"
echo ""

# Verificar si Docker está corriendo
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker no está corriendo${NC}"
    echo "Por favor inicia Docker Desktop y vuelve a ejecutar este script"
    exit 1
fi

echo -e "${GREEN}✅ Docker está corriendo${NC}"
echo ""

# Preguntar si es primera vez
echo -e "${BLUE}¿Es la primera vez que configuras Supabase para este proyecto? (s/n)${NC}"
read -r first_time

if [ "$first_time" = "s" ] || [ "$first_time" = "S" ]; then
    echo ""
    echo "📦 Iniciando Supabase por primera vez..."
    echo "Esto puede tomar unos minutos..."
    echo ""
    
    supabase start
    
    echo ""
    echo -e "${GREEN}✅ Supabase iniciado correctamente${NC}"
    echo ""
    echo "📝 Guarda estas credenciales:"
    echo ""
    supabase status
    echo ""
    
    echo "🌐 Accede a Supabase Studio en: http://localhost:54323"
    echo ""
    
    echo -e "${BLUE}¿Deseas cargar datos de prueba? (s/n)${NC}"
    read -r load_seed
    
    if [ "$load_seed" = "s" ] || [ "$load_seed" = "S" ]; then
        echo ""
        echo "📊 Cargando datos de prueba..."
        supabase db reset
        echo -e "${GREEN}✅ Datos de prueba cargados${NC}"
    fi
else
    echo ""
    echo "🔄 Reiniciando Supabase..."
    supabase stop
    supabase start
    echo -e "${GREEN}✅ Supabase reiniciado${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✨ Configuración completada${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Próximos pasos:"
echo "1. Actualiza lib/core/config/supabase_config.dart con las credenciales locales"
echo "2. Ejecuta: flutter pub get"
echo "3. Ejecuta: flutter run"
echo ""
echo "Comandos útiles:"
echo "  supabase status  - Ver estado de Supabase"
echo "  supabase stop    - Detener Supabase"
echo "  supabase logs    - Ver logs en tiempo real"
echo ""

# Made with Bob