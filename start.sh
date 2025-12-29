#!/bin/bash

# Script de inicio para PartiturasApp
# Inicia tanto el backend como el frontend

echo "🎵 Iniciando PartiturasApp..."
echo "==============================="

# Verificar que .env exista
if [ ! -f .env ]; then
    echo "⚠️  Advertencia: No se encontró el archivo .env"
    echo "📝 Creando archivo .env desde plantilla..."
    
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ .env creado desde plantilla"
        echo "⚠️  Recuerda configurar las variables en .env antes de continuar"
        exit 1
    else
        echo "❌ No se encontró .env.example"
        echo "📝 Creando .env básico..."
        cat > .env << 'ENVFILE'
# ===========================================
# CONFIGURACIÓN SUPABASE (para Frontend - Vite)
# ===========================================
VITE_SUPABASE_URL=https://qroeyukbrangbqlaxdnl.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_tgm8fV1eI7X48T3UxxGEgA_7Ldb1OAj

# ===========================================
# CONFIGURACIÓN SUPABASE (para Backend)
# ===========================================
SUPABASE_URL=https://qroeyukbrangbqlaxdnl.supabase.co
SUPABASE_ANON_KEY=sb_publishable_tgm8fV1eI7X48T3UxxGEgA_7Ldb1OAj
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyb2V5dWticmFuZ2JxbGF4ZG5sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjE5MzUxNSwiZXhwIjoyMDgxNzY5NTE1fQ.fH7wX9HsFLV4NkDPQ43DyZ1_x7cO6dSnEaUYEDh9tuU

# ===========================================
# CONFIGURACIÓN BASE DE DATOS
# ===========================================
DATABASE_URL=postgresql://postgres:AjviKjfqHcz@db.qroeyukbrangbqlaxdnl.supabase.co:5432/postgres

# ===========================================
# CONFIGURACIÓN BACKEND
# ===========================================
NODE_ENV=development
PORT=3001
FRONTEND_URL=http://localhost:3000
SESSION_SECRET=partiturasapp_secret_key_2024_change_this_in_production

# ===========================================
# CONFIGURACIÓN JWT
# ===========================================
JWT_SECRET=CUxncshgiaaBSyJU5WFxLRXTP7Vvah1LOviRhLnxlh8WuiCSskvxbUuCI8Af+boIWrjMDiY1xNDX6uqEAasVCQ==

# ===========================================
# CONFIGURACIÓN STORAGE
# ===========================================
MAX_FILE_SIZE=52428800
ALLOWED_FILE_TYPES=image/*,application/pdf
UPLOAD_PATH=./uploads
ENVFILE
        echo "✅ .env creado con configuración básica"
        echo "⚠️  Recuerda verificar las credenciales de Supabase"
    fi
fi

# Verificar Node.js y npm
echo "🔍 Verificando dependencias..."
if ! command -v node &> /dev/null; then
    echo "❌ Node.js no encontrado. Por favor instala Node.js 18 o superior."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "❌ npm no encontrado. Por favor instala npm."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ Node.js versión $NODE_VERSION encontrada. Se requiere versión 18 o superior."
    exit 1
fi

echo "✅ Node.js $(node -v) y npm $(npm -v) encontrados"

# Instalar dependencias si es necesario
echo "📦 Instalando/Verificando dependencias..."

if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias root..."
    npm install
fi

if [ ! -d "backend/node_modules" ]; then
    echo "📦 Instalando dependencias backend..."
    cd backend && npm install && cd ..
fi

if [ ! -d "frontend/node_modules" ]; then
    echo "📦 Instalando dependencias frontend..."
    cd frontend && npm install && cd ..
fi

# Crear directorios necesarios
echo "📁 Creando directorios necesarios..."
mkdir -p backend/uploads
mkdir -p uploads

# Iniciar servicios
echo "🚀 Iniciando servicios..."
echo "==============================="

# Usar concurrently para iniciar ambos servicios
npx concurrently \
    --names "BACKEND,FRONTEND" \
    --prefix "{name}" \
    --prefix-colors "bgBlue.bold,bgGreen.bold" \
    "cd backend && npm run dev" \
    "cd frontend && npm run dev"

echo " "
echo "🎉 PartiturasApp iniciado exitosamente!"
echo "🌐 Frontend: http://localhost:3000"
echo "🔧 Backend API: http://localhost:3001"
echo "📊 Health check: http://localhost:3001/api/health"
