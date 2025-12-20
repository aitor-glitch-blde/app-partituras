#!/bin/bash
# Script para construir la aplicación para producción

set -e

echo "🔨 Construyendo PartiturasApp para producción..."

# Construir frontend
echo "📦 Construyendo frontend..."
cd frontend
npm run build
cd ..

# Construir backend
echo "⚙️  Construyendo backend..."
cd backend
npm run build
cd ..

echo "✅ Construcción completada!"
echo "📁 Los archivos de producción están en:"
echo "   - Frontend: frontend/dist/"
echo "   - Backend: backend/dist/"
