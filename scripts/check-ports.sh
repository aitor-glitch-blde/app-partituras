#!/bin/bash

echo "🔍 Verificando puertos disponibles..."

check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo "❌ Puerto $port ($service) está en uso"
        return 1
    else
        echo "✅ Puerto $port ($service) está disponible"
        return 0
    fi
}

# Verificar puertos principales
check_port 3000 "Frontend (Vite)"
check_port 3001 "Backend (Express)"
check_port 5432 "PostgreSQL"

echo ""
echo "💡 Si algún puerto está en uso, puedes:"
echo "   1. Cambiar el puerto en .env (backend) o vite.config.js (frontend)"
echo "   2. Terminar el proceso que usa el puerto:"
echo "      lsof -ti:3000 | xargs kill -9  # Para el puerto 3000"
