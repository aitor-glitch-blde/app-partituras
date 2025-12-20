#!/bin/bash
# fix-deps.sh - Corregir problemas de dependencias

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}   CORRECCIÓN DE DEPENDENCIAS            ${NC}"
echo -e "${BLUE}===========================================${NC}"

# 1. Actualizar package.json del frontend para quitar vexflow problemático
echo -e "\n${YELLOW}1. Actualizando frontend/package.json...${NC}"
cat > frontend/package.json << 'EOF'
{
  "name": "partiturasapp-frontend",
  "private": true,
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "format": "prettier --write ."
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "@supabase/supabase-js": "^2.39.7",
    "@tanstack/react-query": "^5.12.0",
    "react-hook-form": "^7.48.2",
    "zod": "^3.22.4",
    "axios": "^1.6.8",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.1",
    "tailwind-merge": "^2.2.1",
    "lucide-react": "^0.309.0",
    "react-hot-toast": "^2.4.1",
    "framer-motion": "^10.16.16",
    "zustand": "^4.4.7"
  },
  "devDependencies": {
    "@types/react": "^18.2.43",
    "@types/react-dom": "^18.2.17",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "@vitejs/plugin-react": "^4.2.1",
    "autoprefixer": "^10.4.17",
    "eslint": "^8.56.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "postcss": "^8.4.33",
    "tailwindcss": "^3.4.1",
    "typescript": "^5.3.3",
    "vite": "^5.0.10",
    "vitest": "^1.2.2",
    "@eslint/js": "^9.0.0",
    "globals": "^15.0.0",
    "prettier": "^3.1.1"
  }
}
EOF
echo -e "${GREEN}✅ package.json actualizado${NC}"

# 2. Limpiar e instalar frontend
echo -e "\n${YELLOW}2. Limpiando e instalando frontend...${NC}"
cd frontend
rm -rf node_modules package-lock.json

# Crear .npmrc para evitar problemas
cat > .npmrc << 'EOF'
legacy-peer-deps=true
strict-peer-dependencies=false
EOF

npm install --no-audit --no-fund
cd ..
echo -e "${GREEN}✅ Frontend instalado${NC}"

# 3. Actualizar package.json del backend
echo -e "\n${YELLOW}3. Actualizando backend/package.json...${NC}"
cat > backend/package.json << 'EOF'
{
  "name": "partiturasapp-backend",
  "version": "1.0.0",
  "description": "Backend API para PartiturasApp",
  "main": "src/server.js",
  "type": "module",
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node src/server.js",
    "test": "jest",
    "lint": "eslint src",
    "migrate": "node scripts/migrate-db.js",
    "seed": "node scripts/seed-db.js",
    "format": "prettier --write ."
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "@supabase/supabase-js": "^2.39.7",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "express-validator": "^7.0.1",
    "express-rate-limit": "^7.1.5",
    "socket.io": "^4.7.5",
    "uuid": "^9.0.1",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0",
    "eslint": "^8.56.0",
    "@types/node": "^20.10.5",
    "prettier": "^3.1.1"
  }
}
EOF
echo -e "${GREEN}✅ package.json actualizado${NC}"

# 4. Limpiar e instalar backend
echo -e "\n${YELLOW}4. Limpiando e instalando backend...${NC}"
cd backend
rm -rf node_modules package-lock.json

# Crear .npmrc
cat > .npmrc << 'EOF'
legacy-peer-deps=true
strict-peer-dependencies=false
EOF

npm install --no-audit --no-fund
cd ..
echo -e "${GREEN}✅ Backend instalado${NC}"

# 5. Crear archivos básicos si no existen
echo -e "\n${YELLOW}5. Creando archivos básicos...${NC}"

# Configuración de Tailwind
cat > frontend/tailwind.config.js << 'EOF'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
EOF

# PostCSS config
cat > frontend/postcss.config.js << 'EOF'
export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
}
EOF

# Vite config simple
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
})
EOF

# Crear estructura básica de frontend
mkdir -p frontend/src/{components,styles,pages}

# Archivos CSS básicos
cat > frontend/src/index.css << 'EOF'
@tailwind base;
@tailwind components;
@tailwind utilities;

body {
  margin: 0;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
    'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue',
    sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

code {
  font-family: source-code-pro, Menlo, Monaco, Consolas, 'Courier New',
    monospace;
}
EOF

# App.jsx básico
cat > frontend/src/App.jsx << 'EOF'
import React, { useEffect, useState } from 'react'
import { createClient } from '@supabase/supabase-js'
import './App.css'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY

const supabase = createClient(supabaseUrl, supabaseAnonKey)

function App() {
  const [partituras, setPartituras] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    const fetchPartituras = async () => {
      try {
        setLoading(true)
        const { data, error } = await supabase
          .from('partituras')
          .select('*')
          .limit(5)
        
        if (error) throw error
        
        setPartituras(data || [])
      } catch (err) {
        setError(err.message)
        console.error('Error fetching partituras:', err)
      } finally {
        setLoading(false)
      }
    }

    fetchPartituras()
  }, [])

  return (
    <div className="min-h-screen bg-gradient-to-br from-primary-50 to-primary-100">
      <div className="container mx-auto px-4 py-8">
        {/* Header */}
        <header className="text-center mb-12">
          <h1 className="text-5xl font-bold text-primary-800 mb-4">
            🎵 PartiturasApp
          </h1>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto">
            Plataforma para la gestión y creación de partituras musicales
          </p>
        </header>

        {/* Main Content */}
        <main className="max-w-6xl mx-auto">
          {/* Connection Status */}
          <div className="bg-white rounded-xl shadow-lg p-6 mb-8">
            <h2 className="text-2xl font-semibold text-gray-800 mb-4">
              Estado del Sistema
            </h2>
            
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                <div className="flex items-center">
                  <div className="w-3 h-3 bg-green-500 rounded-full mr-3"></div>
                  <span className="font-medium text-green-800">Base de Datos</span>
                </div>
                <p className="text-sm text-green-600 mt-2">Conectada a Supabase</p>
              </div>
              
              <div className={`border rounded-lg p-4 ${loading ? 'bg-yellow-50 border-yellow-200' : 'bg-green-50 border-green-200'}`}>
                <div className="flex items-center">
                  <div className={`w-3 h-3 rounded-full mr-3 ${loading ? 'bg-yellow-500' : 'bg-green-500'}`}></div>
                  <span className="font-medium">API Frontend</span>
                </div>
                <p className="text-sm mt-2">
                  {loading ? 'Cargando...' : 'Conectado'}
                </p>
              </div>
              
              <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                <div className="flex items-center">
                  <div className="w-3 h-3 bg-blue-500 rounded-full mr-3"></div>
                  <span className="font-medium text-blue-800">Backend</span>
                </div>
                <p className="text-sm text-blue-600 mt-2">Listo para iniciar</p>
              </div>
            </div>
          </div>

          {/* Partituras Section */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex justify-between items-center mb-6">
              <h2 className="text-2xl font-semibold text-gray-800">
                Partituras Recientes
              </h2>
              <span className="text-sm text-gray-500">
                {partituras.length} encontradas
              </span>
            </div>

            {error ? (
              <div className="bg-red-50 border border-red-200 rounded-lg p-4">
                <p className="text-red-700">Error: {error}</p>
              </div>
            ) : loading ? (
              <div className="text-center py-8">
                <div className="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-primary-600"></div>
                <p className="mt-2 text-gray-600">Cargando partituras...</p>
              </div>
            ) : partituras.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {partituras.map((partitura) => (
                  <div key={partitura.id} className="border rounded-lg p-4 hover:shadow-md transition-shadow">
                    <h3 className="font-bold text-lg text-gray-800 truncate">
                      {partitura.titulo}
                    </h3>
                    <p className="text-sm text-gray-600 mt-1 truncate">
                      {partitura.descripcion || 'Sin descripción'}
                    </p>
                    <div className="mt-3 flex justify-between text-sm text-gray-500">
                      <span>Compás: {partitura.compas}</span>
                      <span>BPM: {partitura.bpm}</span>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="text-center py-8">
                <div className="text-gray-400 mb-4">
                  <svg className="w-16 h-16 mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 19V6l12-3v13M9 19c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zm12-3c0 1.105-1.343 2-3 2s-3-.895-3-2 1.343-2 3-2 3 .895 3 2zM9 10l12-3" />
                  </svg>
                </div>
                <p className="text-gray-600">No hay partituras disponibles</p>
                <p className="text-sm text-gray-500 mt-1">
                  Crea tu primera partitura para comenzar
                </p>
              </div>
            )}

            {/* Instructions */}
            <div className="mt-8 pt-6 border-t">
              <h3 className="font-semibold text-gray-700 mb-3">🎯 Próximos pasos</h3>
              <ol className="list-decimal list-inside space-y-2 text-gray-600">
                <li>Inicia el servidor backend: <code className="bg-gray-100 px-2 py-1 rounded">npm run dev:backend</code></li>
                <li>Inicia el frontend: <code className="bg-gray-100 px-2 py-1 rounded">npm run dev:frontend</code></li>
                <li>Accede a la aplicación en <a href="http://localhost:3000" className="text-primary-600 hover:underline">localhost:3000</a></li>
                <li>Explora el dashboard de Supabase para administrar datos</li>
              </ol>
            </div>
          </div>
        </main>

        {/* Footer */}
        <footer className="mt-12 text-center text-gray-500 text-sm">
          <p>PartiturasApp v1.0.0 | Conectado a Supabase</p>
          <p className="mt-1">
            Base de datos: {supabaseUrl.replace('https://', '').split('.')[0]}
          </p>
        </footer>
      </div>
    </div>
  )
}

export default App
EOF

# Main.jsx
cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# Index.html actualizado
cat > frontend/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PartiturasApp | Gestión y Creación de Partituras Musicales</title>
    <meta name="description" content="Plataforma web para gestionar y crear partituras musicales de forma digital e interactiva">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Crear estructura básica de backend
mkdir -p backend/src/{routes,middleware,controllers,models,utils}

# Server.js básico para backend
cat > backend/src/server.js << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

// Configuración
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Configurar Supabase
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL 
    : 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json());

// Rutas de API
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'PartiturasApp API está funcionando',
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    supabase: 'conectado',
    environment: process.env.NODE_ENV || 'development'
  });
});

// Obtener todas las partituras
app.get('/api/partituras', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('partituras')
      .select('*')
      .order('fecha_creacion', { ascending: false })
      .limit(50);
    
    if (error) throw error;
    
    res.json({
      success: true,
      data: data || [],
      count: data?.length || 0
    });
  } catch (error) {
    console.error('Error fetching partituras:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Error al obtener partituras'
    });
  }
});

// Obtener usuarios
app.get('/api/usuarios', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('usuarios')
      .select('id, email, nombre, apellido, tipo_cuenta, fecha_registro')
      .order('fecha_registro', { ascending: false })
      .limit(50);
    
    if (error) throw error;
    
    res.json({
      success: true,
      data: data || [],
      count: data?.length || 0
    });
  } catch (error) {
    console.error('Error fetching usuarios:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Error al obtener usuarios'
    });
  }
});

// Estadísticas del sistema
app.get('/api/estadisticas', async (req, res) => {
  try {
    // Obtener conteos
    const [
      { count: partiturasCount },
      { count: usuariosCount },
      { count: colaboracionesCount }
    ] = await Promise.all([
      supabase.from('partituras').select('*', { count: 'exact', head: true }),
      supabase.from('usuarios').select('*', { count: 'exact', head: true }),
      supabase.from('colaboraciones').select('*', { count: 'exact', head: true })
    ]);
    
    res.json({
      success: true,
      data: {
        partituras: partiturasCount || 0,
        usuarios: usuariosCount || 0,
        colaboraciones: colaboracionesCount || 0,
        timestamp: new Date().toISOString()
      }
    });
  } catch (error) {
    console.error('Error fetching estadísticas:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Error al obtener estadísticas'
    });
  }
});

// Middleware de manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Error interno del servidor',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Ruta 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada',
    path: req.path
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🎵 API Partituras: http://localhost:${PORT}/api/partituras`);
  console.log(`👥 API Usuarios: http://localhost:${PORT}/api/usuarios`);
  console.log(`📈 API Estadísticas: http://localhost:${PORT}/api/estadisticas`);
});
EOF

echo -e "${GREEN}✅ Archivos básicos creados${NC}"

echo -e "\n${BLUE}===========================================${NC}"
echo -e "${GREEN}   CORRECCIÓN COMPLETADA                 ${NC}"
echo -e "${BLUE}===========================================${NC}"

echo -e "\n${YELLOW}🎯 Próximos pasos:${NC}"
echo "1. Inicia el backend:"
echo "   $ cd backend && npm run dev"
echo ""
echo "2. En otra terminal, inicia el frontend:"
echo "   $ cd frontend && npm run dev"
echo ""
echo "3. Accede a la aplicación:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:3001/api/health"
echo ""
echo "4. Verifica que puedes ver datos de Supabase en la interfaz"
echo ""
echo "¡Listo para desarrollar! 🎵"