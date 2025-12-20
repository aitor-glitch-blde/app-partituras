#!/bin/bash

echo "🔍 Verificación rápida del proyecto..."
echo ""

# 1. Verificar Node.js
echo "1. Node.js: $(node --version)"
echo "   npm: $(npm --version)"

# 2. Verificar .env
echo "2. Variables .env:"
if [ -f .env ]; then
    grep -E "^(VITE_SUPABASE|SUPABASE|DATABASE)" .env | head -5
    echo "   ... (más variables)"
else
    echo "   ❌ .env no encontrado"
fi

# 3. Verificar frontend
echo "3. Frontend:"
cd frontend
if [ -d "node_modules" ]; then
    echo "   ✅ node_modules existe"
    echo "   React: $(npm list react --depth=0 2>/dev/null | grep react | cut -d'@' -f2)"
else
    echo "   ❌ node_modules no encontrado"
fi
cd ..

# 4. Verificar backend
echo "4. Backend:"
cd backend
if [ -d "node_modules" ]; then
    echo "   ✅ node_modules existe"
    echo "   Express: $(npm list express --depth=0 2>/dev/null | grep express | cut -d'@' -f2)"
else
    echo "   ❌ node_modules no encontrado"
fi
cd ..

echo ""
echo "🎯 Para iniciar:"
echo "   1. cd backend && npm run dev"
echo "   2. cd frontend && npm run dev"
