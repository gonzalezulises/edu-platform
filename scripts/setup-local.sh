#!/bin/bash

# =============================================================================
# EduPlatform - Setup Local Configuration
# =============================================================================
# Este script genera CLAUDE.local.md desde el template con tus valores
# =============================================================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}  EduPlatform - Setup Local Config   ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""

# Detectar directorio del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}Directorio del proyecto detectado:${NC}"
echo "  $PROJECT_DIR"
echo ""

# Verificar que existe el template
TEMPLATE_FILE="$PROJECT_DIR/CLAUDE.local.example.md"
OUTPUT_FILE="$PROJECT_DIR/CLAUDE.local.md"

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}Error: No se encontro el template CLAUDE.local.example.md${NC}"
    exit 1
fi

# Verificar si ya existe CLAUDE.local.md
if [ -f "$OUTPUT_FILE" ]; then
    echo -e "${YELLOW}CLAUDE.local.md ya existe.${NC}"
    read -p "Deseas sobrescribirlo? (s/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Ss]$ ]]; then
        echo "Cancelado."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Por favor, proporciona los siguientes valores:${NC}"
echo ""

# Obtener PROJECT_PATH
echo -e "${GREEN}1. Ruta del proyecto${NC}"
echo "   (Presiona Enter para usar: $PROJECT_DIR)"
read -p "   PROJECT_PATH: " input_project_path
PROJECT_PATH="${input_project_path:-$PROJECT_DIR}"

# Obtener CREDENTIALS_PATH
echo ""
echo -e "${GREEN}2. Ruta del archivo de credenciales${NC}"
echo "   Donde guardaras tus credenciales de Supabase"
echo "   (Presiona Enter para usar: ~/.edu-platform-credentials)"
read -p "   CREDENTIALS_PATH: " input_credentials_path
CREDENTIALS_PATH="${input_credentials_path:-~/.edu-platform-credentials}"

# Obtener SUPABASE_PROJECT_REF
echo ""
echo -e "${GREEN}3. Supabase Project Reference ID${NC}"
echo "   Encuéntralo en: Supabase Dashboard > Project Settings > General"
echo "   Ejemplo: abcdefghijklmnop"
read -p "   SUPABASE_PROJECT_REF: " SUPABASE_PROJECT_REF

if [ -z "$SUPABASE_PROJECT_REF" ]; then
    echo -e "${YELLOW}Advertencia: No proporcionaste el project ref.${NC}"
    echo "   Puedes editarlo despues en CLAUDE.local.md"
    SUPABASE_PROJECT_REF="{{SUPABASE_PROJECT_REF}}"
fi

# Obtener GITHUB_USERNAME (opcional)
echo ""
echo -e "${GREEN}4. Tu usuario de GitHub (opcional)${NC}"
echo "   Para el URL del repositorio si hiciste fork"
read -p "   GITHUB_USERNAME (Enter para omitir): " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    GITHUB_USERNAME="[tu-usuario]"
fi

# Generar CLAUDE.local.md
echo ""
echo -e "${BLUE}Generando CLAUDE.local.md...${NC}"

# Leer template y reemplazar placeholders
sed -e "s|{{PROJECT_PATH}}|$PROJECT_PATH|g" \
    -e "s|{{CREDENTIALS_PATH}}|$CREDENTIALS_PATH|g" \
    -e "s|{{SUPABASE_PROJECT_REF}}|$SUPABASE_PROJECT_REF|g" \
    -e "s|{{GITHUB_USERNAME}}|$GITHUB_USERNAME|g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo -e "${GREEN}CLAUDE.local.md creado exitosamente!${NC}"

# Preguntar si crear archivo de credenciales
echo ""
echo -e "${BLUE}Archivo de credenciales${NC}"
echo ""

# Expandir ~ en la ruta
EXPANDED_CREDS_PATH="${CREDENTIALS_PATH/#\~/$HOME}"

if [ -f "$EXPANDED_CREDS_PATH" ]; then
    echo -e "${YELLOW}El archivo de credenciales ya existe en: $CREDENTIALS_PATH${NC}"
else
    read -p "Deseas crear el archivo de credenciales con estructura vacia? (S/n): " create_creds
    if [[ ! "$create_creds" =~ ^[Nn]$ ]]; then
        cat > "$EXPANDED_CREDS_PATH" << 'CREDS_EOF'
# =============================================================================
# EduPlatform Credentials
# =============================================================================
# NO compartir ni subir a repositorios
# Agrega este archivo a tu .gitignore global
# =============================================================================

# Supabase
export NEXT_PUBLIC_SUPABASE_URL=""
export NEXT_PUBLIC_SUPABASE_ANON_KEY=""
export SUPABASE_SERVICE_ROLE_KEY=""
export SUPABASE_ACCESS_TOKEN=""

# Project Info
export SUPABASE_PROJECT_REF=""

# =============================================================================
# Instrucciones:
# 1. Completa los valores de arriba con tus credenciales de Supabase
# 2. Encuéntralas en: Supabase Dashboard > Project Settings > API
# 3. Para usar: source ~/.edu-platform-credentials
# =============================================================================
CREDS_EOF

        chmod 600 "$EXPANDED_CREDS_PATH"
        echo -e "${GREEN}Archivo de credenciales creado en: $CREDENTIALS_PATH${NC}"
        echo -e "${YELLOW}IMPORTANTE: Edita el archivo y agrega tus credenciales de Supabase${NC}"
    fi
fi

# Resumen final
echo ""
echo -e "${BLUE}=====================================${NC}"
echo -e "${BLUE}          Setup Completado           ${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo -e "${GREEN}Archivos creados/modificados:${NC}"
echo "  - $OUTPUT_FILE"
if [ -f "$EXPANDED_CREDS_PATH" ]; then
    echo "  - $CREDENTIALS_PATH"
fi
echo ""
echo -e "${YELLOW}Proximos pasos:${NC}"
echo "  1. Edita $CREDENTIALS_PATH con tus credenciales de Supabase"
echo "  2. Copia el contenido a .env.local:"
echo "     cp $CREDENTIALS_PATH .env.local"
echo "  3. Linkea el proyecto de Supabase:"
echo "     source .env.local && supabase link --project-ref \$SUPABASE_PROJECT_REF"
echo ""
echo -e "${GREEN}Listo para usar con Claude Code!${NC}"
echo ""
