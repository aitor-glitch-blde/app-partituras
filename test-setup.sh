#!/bin/bash

set -e

echo "🧪 Probando configuración de PartiturasApp..."

# Verificar variables de entorno
echo "1. Verificando variables de entorno..."
if [ -f .env ]; then
    source .env
    echo "✅ .env cargado"
    
    # Verificar variables críticas
    if [ -z "$VITE_SUPABASE_URL" ]; then
        echo "❌ VITE_SUPABASE_URL no configurada"
        exit 1
    fi
    if [ -z "$VITE_SUPABASE_ANON_KEY" ]; then
        echo "❌ VITE_SUPABASE_ANON_KEY no configurada"
        exit 1
    fi
    echo "✅ Variables de Supabase configuradas"
else
    echo "❌ Archivo .env no encontrado"
    exit 1
fi

# Verificar estructura
echo "2. Verificando estructura del proyecto..."
if [ ! -d "frontend" ]; then
    echo "❌ Directorio frontend no encontrado"
    exit 1
fi

if [ ! -d "backend" ]; then
    echo "❌ Directorio backend no encontrado"
    exit 1
fi

echo "✅ Estructura básica OK"

# Verificar dependencias del frontend
echo "3. Verificando dependencias del frontend..."
cd frontend
if [ ! -d "node_modules" ]; then
    echo "❌ node_modules no encontrado en frontend"
    echo "Ejecuta: cd frontend && npm install"
    exit 1
fi

# Verificar que React esté instalado
if ! npm list react 2>/dev/null | grep -q "react@"; then
    echo "❌ React no instalado en frontend"
    exit 1
fi

echo "✅ Frontend: React instalado"

# Verificar Supabase client
if ! npm list @supabase/supabase-js 2>/dev/null | grep -q "@supabase/supabase-js@"; then
    echo "⚠️  Supabase client no instalado en frontend"
fi

cd ..

# Verificar dependencias del backend
echo "4. Verificando dependencias del backend..."
cd backend
if [ ! -d "node_modules" ]; then
    echo "❌ node_modules no encontrado en backend"
    echo "Ejecuta: cd backend && npm install"
    exit 1
fi

# Verificar que Express esté instalado
if ! npm list express 2>/dev/null | grep -q "express@"; then
    echo "❌ Express no instalado en backend"
    exit 1
fi

echo "✅ Backend: Express instalado"
cd ..

# Verificar que los puertos estén libres
echo "5. Verificando puertos..."
if lsof -ti:3000 > /dev/null; then
    echo "⚠️  Puerto 3000 (frontend) en uso"
else
    echo "✅ Puerto 3000 disponible"
fi

if lsof -ti:3001 > /dev/null; then
    echo "⚠️  Puerto 3001 (backend) en uso"
else
    echo "✅ Puerto 3001 disponible"
fi

# Probar conexión a Supabase
echo "6. Probando conexión a Supabase..."
if [ -n "$VITE_SUPABASE_URL" ] && [ -n "$VITE_SUPABASE_ANON_KEY" ]; then
    curl -s -o /dev/null -w "%{http_code}" "$VITE_SUPABASE_URL/rest/v1/" > /tmp/supabase_test.txt
    STATUS=$(cat /tmp/supabase_test.txt)
    
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "401" ]; then
        echo "✅ Supabase respondió (HTTP $STATUS)"
    else
        echo "⚠️  No se pudo conectar a Supabase (HTTP $STATUS)"
    fi
fi

echo ""
echo "🎉 ¡Configuración básica verificada!"
echo ""
echo "📋 Para iniciar la aplicación:"
echo "   Opción 1: Usar el script start.sh"
echo "   Opción 2: Ejecutar manualmente:"
echo "     Terminal 1: cd backend && npm run dev"
echo "     Terminal 2: cd frontend && npm run dev"
echo ""
echo "🌐 URLs esperadas:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:3001"
echo "   Health check: http://localhost:3001/api/health"
