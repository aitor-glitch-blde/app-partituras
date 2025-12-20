#!/bin/bash
# Script para iniciar servidores de desarrollo

echo "🚀 Iniciando PartiturasApp en modo desarrollo..."

# Iniciar backend y frontend simultáneamente
concurrently \
  "cd backend && npm run dev" \
  "cd frontend && npm run dev"

echo "✅ Servidores iniciados. Visita http://localhost:3000"
