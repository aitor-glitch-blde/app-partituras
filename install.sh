#!/bin/bash
# install.sh - Script de instalación automatizada de PartiturasApp

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}===========================================${NC}"
echo -e "${GREEN}   INSTALACIÓN DE PARTITURASAPP          ${NC}"
echo -e "${GREEN}===========================================${NC}"

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    echo "Por favor, instala Node.js v18 o superior desde:"
    echo "https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}❌ Se requiere Node.js v18 o superior${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js v$(node -v) instalado${NC}"

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ npm v$(npm -v) instalado${NC}"

# Instalar dependencias globales
echo -e "\n${YELLOW}Instalando dependencias globales...${NC}"
npm install -g concurrently

# Instalar dependencias frontend
echo -e "\n${YELLOW}Instalando dependencias del frontend...${NC}"
cd frontend
npm install
cd ..

# Instalar dependencias backend
echo -e "\n${YELLOW}Instalando dependencias del backend...${NC}"
cd backend
npm install
cd ..

# Copiar archivo .env de ejemplo
if [ ! -f .env ]; then
    echo -e "\n${YELLOW}Copiando archivo .env de ejemplo...${NC}"
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Por favor, configura las variables en el archivo .env${NC}"
fi

# Crear directorio de uploads
echo -e "\n${YELLOW}Creando directorios necesarios...${NC}"
mkdir -p backend/uploads
mkdir -p backend/logs
mkdir -p frontend/public

# Configurar permisos
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "\n${GREEN}===========================================${NC}"
echo -e "${GREEN}   INSTALACIÓN COMPLETADA               ${NC}"
echo -e "${GREEN}===========================================${NC}"
echo -e "\n${YELLOW}Pasos siguientes:${NC}"
echo "1. Configura las variables en el archivo .env"
echo "2. Ejecuta la base de datos con el script SQL proporcionado"
echo "3. Para iniciar el servidor de desarrollo:"
echo "   ${GREEN}npm run dev${NC}"
echo "4. Para construir para producción:"
echo "   ${GREEN}npm run build${NC}"
echo -e "\n${GREEN}¡Listo para comenzar! 🎵${NC}"
