#!/bin/bash
# setup-project.sh - Script de creación completa para PartiturasApp

echo "==========================================="
echo "     CREANDO PROYECTO PARTITURASAPP       "
echo "==========================================="

# ===========================================
# 1. CREAR ESTRUCTURA DE CARPETAS
# ===========================================
echo "1. Creando estructura de carpetas..."

mkdir -p frontend/{src/{components/{auth,dashboard,editor,partituras,shared},hooks,utils,styles,pages,context},public}
mkdir -p backend/{src/{controllers,middleware,routes,models,utils,config},public}
mkdir -p scripts
mkdir -p docs/{api,design}
mkdir -p tests/{unit,integration}
mkdir -p config

echo "✅ Estructura de carpetas creada"

# ===========================================
# 2. CREAR ARCHIVOS FRONTEND
# ===========================================
echo "2. Creando archivos del frontend..."

# Configuración Vite
cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@hooks': path.resolve(__dirname, './src/hooks'),
      '@utils': path.resolve(__dirname, './src/utils'),
      '@styles': path.resolve(__dirname, './src/styles'),
      '@pages': path.resolve(__dirname, './src/pages'),
      '@context': path.resolve(__dirname, './src/context'),
    },
  },
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

# Package.json frontend
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
    "test:ui": "vitest --ui"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.20.0",
    "@supabase/supabase-js": "^2.38.4",
    "@tanstack/react-query": "^5.12.0",
    "react-hook-form": "^7.47.0",
    "zod": "^3.22.4",
    "axios": "^1.6.2",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.0.0",
    "tailwind-merge": "^2.0.0",
    "lucide-react": "^0.309.0",
    "react-hot-toast": "^2.4.1",
    "framer-motion": "^10.16.4",
    "zustand": "^4.4.7"
  },
  "devDependencies": {
    "@types/react": "^18.2.37",
    "@types/react-dom": "^18.2.15",
    "@typescript-eslint/eslint-plugin": "^6.14.0",
    "@typescript-eslint/parser": "^6.14.0",
    "@vitejs/plugin-react": "^4.2.0",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.55.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.5",
    "postcss": "^8.4.32",
    "tailwindcss": "^3.3.6",
    "typescript": "^5.2.2",
    "vite": "^5.0.0",
    "vitest": "^1.0.4"
  }
}
EOF

# Archivo principal HTML
cat > frontend/index.html << 'EOF'
<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>PartiturasApp | Gestión y Creación de Partituras Musicales</title>
    <meta name="description" content="Plataforma web para gestionar y crear partituras musicales de forma digital e interactiva">
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
EOF

# Punto de entrada principal
cat > frontend/src/main.jsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './styles/index.css'

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
)
EOF

# Componente App principal
cat > frontend/src/App.jsx << 'EOF'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Toaster } from 'react-hot-toast'
import { AuthProvider } from './context/AuthContext'
import Layout from './components/shared/Layout'
import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import Dashboard from './pages/Dashboard'
import Editor from './pages/Editor'
import Partituras from './pages/Partituras'
import './App.css'

const queryClient = new QueryClient()

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <AuthProvider>
          <Toaster position="top-right" />
          <Routes>
            <Route path="/" element={<Layout />}>
              <Route index element={<Home />} />
              <Route path="login" element={<Login />} />
              <Route path="register" element={<Register />} />
              <Route path="dashboard" element={<Dashboard />} />
              <Route path="editor" element={<Editor />} />
              <Route path="editor/:id" element={<Editor />} />
              <Route path="partituras" element={<Partituras />} />
              <Route path="*" element={<Navigate to="/" replace />} />
            </Route>
          </Routes>
        </AuthProvider>
      </Router>
    </QueryClientProvider>
  )
}

export default App
EOF

# Configuración TailwindCSS
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
        secondary: {
          50: '#fdf4ff',
          100: '#fae8ff',
          200: '#f5d0fe',
          300: '#f0abfc',
          400: '#e879f9',
          500: '#d946ef',
          600: '#c026d3',
          700: '#a21caf',
          800: '#86198f',
          900: '#701a75',
        },
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Playfair Display', 'serif'],
        mono: ['Fira Code', 'monospace'],
      },
      animation: {
        'float': 'float 6s ease-in-out infinite',
        'pulse-slow': 'pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite',
      },
      keyframes: {
        float: {
          '0%, 100%': { transform: 'translateY(0)' },
          '50%': { transform: 'translateY(-10px)' },
        }
      }
    },
  },
  plugins: [],
}
EOF

# ===========================================
# 3. CREAR ARCHIVOS BACKEND
# ===========================================
echo "3. Creando archivos del backend..."

# Package.json backend
cat > backend/package.json << 'EOF'
{
  "name": "partiturasapp-backend",
  "version": "1.0.0",
  "description": "Backend API para PartiturasApp",
  "main": "src/server.js",
  "scripts": {
    "dev": "nodemon src/server.js",
    "start": "node src/server.js",
    "test": "jest",
    "lint": "eslint src",
    "migrate": "node scripts/migrate-db.js",
    "seed": "node scripts/seed-db.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "cors": "^2.8.5",
    "helmet": "^7.0.0",
    "compression": "^1.7.4",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1",
    "pg": "^8.11.3",
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    "multer": "^1.4.5-lts.1",
    "express-validator": "^7.0.1",
    "express-rate-limit": "^7.1.5",
    "express-session": "^1.17.3",
    "connect-pg-simple": "^9.0.1",
    "socket.io": "^4.7.2",
    "uuid": "^9.0.1",
    "winston": "^3.11.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.2",
    "jest": "^29.7.0",
    "supertest": "^6.3.3",
    "eslint": "^8.55.0",
    "@types/jest": "^29.5.8",
    "@types/node": "^20.10.0"
  }
}
EOF

# Configuración principal del servidor
cat > backend/src/server.js << 'EOF'
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

// Importar rutas
import authRoutes from './routes/auth.routes.js';
import partiturasRoutes from './routes/partituras.routes.js';
import userRoutes from './routes/user.routes.js';
import editorRoutes from './routes/editor.routes.js';

// Configuración de entorno
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;

// Middlewares básicos
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'", process.env.VITE_SUPABASE_URL]
    },
  },
}));
app.use(compression());
app.use(morgan('combined'));
app.use(cors({
  origin: process.env.NODE_ENV === 'production' 
    ? process.env.FRONTEND_URL 
    : 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// Rutas de la API
app.use('/api/auth', authRoutes);
app.use('/api/partituras', partiturasRoutes);
app.use('/api/users', userRoutes);
app.use('/api/editor', editorRoutes);

// Servir archivos estáticos en producción
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, '../../frontend/dist')));
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../../frontend/dist/index.html'));
  });
}

// Middleware de manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Error interno del servidor',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// Ruta de salud
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'PartiturasApp API',
    version: '1.0.0'
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
  console.log(`📚 Documentación API disponible en http://localhost:${PORT}/api-docs`);
});
EOF

# ===========================================
# 4. CREAR ARCHIVOS DE CONFIGURACIÓN
# ===========================================
echo "4. Creando archivos de configuración..."

# Archivo .env de ejemplo
cat > .env.example << 'EOF'
# ===========================================
# CONFIGURACIÓN SUPABASE
# ===========================================
VITE_SUPABASE_URL=https://qroeyukbrangbqlaxdnl.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_tgm8fV1eI7X48T3UxxGEgA_7Ldb1OAj
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyb2V5dWticmFuZ2JxbGF4ZG5sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjE5MzUxNSwiZXhwIjoyMDgxNzY5NTE1fQ.fH7wX9HsFLV4NkDPQ43DyZ1_x7cO6dSnEaUYEDh9tuU

# ===========================================
# CONFIGURACIÓN BACKEND
# ===========================================
NODE_ENV=development
PORT=3001
SESSION_SECRET=your_session_secret_here_change_this_in_production

# ===========================================
# CONFIGURACIÓN BASE DE DATOS
# ===========================================
DATABASE_URL=postgresql://postgres:your_password@localhost:5432/partiturasapp
DB_HOST=localhost
DB_PORT=5432
DB_NAME=partiturasapp
DB_USER=postgres
DB_PASSWORD=your_password

# ===========================================
# CONFIGURACIÓN STORAGE
# ===========================================
MAX_FILE_SIZE=52428800 # 50MB
ALLOWED_FILE_TYPES=image/*,application/pdf
UPLOAD_PATH=./uploads

# ===========================================
# CONFIGURACIÓN JWT
# ===========================================
JWT_SECRET=your_jwt_secret_key_change_this_in_production
JWT_EXPIRES_IN=7d
JWT_REFRESH_SECRET=your_refresh_secret_key
JWT_REFRESH_EXPIRES_IN=30d

# ===========================================
# CONFIGURACIÓN CORREO
# ===========================================
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password
EMAIL_FROM=PartiturasApp <noreply@partiturasapp.com>
EOF

# Script de instalación automatizada
cat > install.sh << 'EOF'
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
EOF

# Script de desarrollo
cat > scripts/dev.sh << 'EOF'
#!/bin/bash
# Script para iniciar servidores de desarrollo

echo "🚀 Iniciando PartiturasApp en modo desarrollo..."

# Iniciar backend y frontend simultáneamente
concurrently \
  "cd backend && npm run dev" \
  "cd frontend && npm run dev"

echo "✅ Servidores iniciados. Visita http://localhost:3000"
EOF

# Script de construcción
cat > scripts/build.sh << 'EOF'
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
EOF

# ===========================================
# 5. CREAR SCRIPTS DE BASE DE DATOS
# ===========================================
echo "5. Creando scripts de base de datos..."

# Script para inicializar la base de datos
cat > scripts/init-db.sh << 'EOF'
#!/bin/bash
# Script para inicializar la base de datos de PartiturasApp

set -e

echo "🗄️  Inicializando base de datos PartiturasApp..."

# Verificar si psql está instalado
if ! command -v psql &> /dev/null; then
    echo "❌ PostgreSQL no está instalado o psql no está en el PATH"
    exit 1
fi

# Preguntar por credenciales si no están en .env
if [ -f .env ]; then
    source .env
fi

DB_NAME=${DB_NAME:-"partiturasapp"}
DB_USER=${DB_USER:-"postgres"}
DB_PASSWORD=${DB_PASSWORD:-""}
DB_HOST=${DB_HOST:-"localhost"}
DB_PORT=${DB_PORT:-"5432"}

echo "🔑 Credenciales de base de datos:"
echo "   Host: $DB_HOST"
echo "   Puerto: $DB_PORT"
echo "   Base de datos: $DB_NAME"
echo "   Usuario: $DB_USER"

read -p "¿Continuar? (s/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo "❌ Cancelado"
    exit 0
fi

# Exportar contraseña para psql
export PGPASSWORD=$DB_PASSWORD

echo "📝 Creando base de datos..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME;" || true

echo "📝 Ejecutando script SQL de inicialización..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f scripts/sql/schema.sql

echo "🌱 Insertando datos iniciales..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f scripts/sql/seed.sql

echo "✅ Base de datos inicializada correctamente!"
echo "📊 Puedes conectarte con:"
echo "   psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME"
EOF

# Crear directorio para scripts SQL
mkdir -p scripts/sql

# Guardar el esquema SQL proporcionado
cat > scripts/sql/schema.sql << 'EOF'
-- ============================================
-- CONFIGURACIÓN INICIAL DE LA BASE DE DATOS
-- PartiturasApp - Sistema de Gestión de Partituras
-- ============================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- TABLA: usuarios
-- Almacena la información de los usuarios registrados
-- ============================================
CREATE TABLE usuarios (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    tipo_cuenta VARCHAR(20) DEFAULT 'gratuita' CHECK (tipo_cuenta IN ('gratuita', 'premium', 'educativa')),
    fecha_registro TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ultimo_acceso TIMESTAMP WITH TIME ZONE,
    espacio_disponible_mb INTEGER DEFAULT 50, -- 50MB para cuentas gratuitas
    esta_verificado BOOLEAN DEFAULT FALSE,
    configuracion JSONB DEFAULT '{"tema": "claro", "idioma": "es", "notificaciones": true}'::jsonb,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- ============================================
-- TABLA: partituras
-- Almacena las partituras creadas/subidas por usuarios
-- ============================================
CREATE TABLE partituras (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(20) DEFAULT 'creada' CHECK (tipo IN ('subida', 'creada')),
    formato_original VARCHAR(10),
    ruta_archivo VARCHAR(500),
    datos_musicales JSONB, -- Almacena notas, tempo, compás, etc. en formato JSON
    duracion_segundos INTEGER,
    compas VARCHAR(10) DEFAULT '4/4',
    tonalidad VARCHAR(10),
    bpm INTEGER DEFAULT 120,
    es_publica BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_modificacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tamanio_bytes INTEGER,
    etiquetas TEXT[],
    CONSTRAINT max_titulo_length CHECK (LENGTH(titulo) >= 3 AND LENGTH(titulo) <= 200)
);

-- ============================================
-- TABLA: elementos_musicales
-- Elementos individuales dentro de una partitura
-- ============================================
CREATE TABLE elementos_musicales (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    tipo_elemento VARCHAR(30) NOT NULL CHECK (tipo_elemento IN ('nota', 'silencia', 'compas', 'clave', 'armadura')),
    tiempo_inicio FLOAT, -- En segundos
    tiempo_duracion FLOAT, -- En segundos
    posicion_x INTEGER,
    posicion_y INTEGER,
    atributos JSONB, -- {nota: "C4", duracion: "negra", octava: 4, alteracion: null}
    orden INTEGER
);

-- ============================================
-- TABLA: colaboraciones
-- Permite colaboración en partituras
-- ============================================
CREATE TABLE colaboraciones (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol VARCHAR(20) DEFAULT 'lector' CHECK (rol IN ('lector', 'editor', 'propietario')),
    fecha_invitacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_aceptacion TIMESTAMP WITH TIME ZONE,
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aceptada', 'rechazada', 'expirada'))
);

-- ============================================
-- TABLA: historial_cambios
-- Registra cambios en partituras para control de versiones
-- ============================================
CREATE TABLE historial_cambios (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    tipo_cambio VARCHAR(50) NOT NULL,
    descripcion TEXT,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    fecha_cambio TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET
);

-- ============================================
-- TABLA: plantillas
-- Plantillas predefinidas para crear partituras
-- ============================================
CREATE TABLE plantillas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_instrumento VARCHAR(50),
    nivel_dificultad VARCHAR(20) CHECK (nivel_dificultad IN ('principiante', 'intermedio', 'avanzado')),
    datos_plantilla JSONB NOT NULL,
    es_publica BOOLEAN DEFAULT TRUE,
    veces_usada INTEGER DEFAULT 0,
    creador_id UUID REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================
-- TABLA: descargas
-- Registro de descargas de partituras
-- ============================================
CREATE TABLE descargas (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    formato VARCHAR(10) NOT NULL CHECK (formato IN ('pdf', 'midi', 'musicxml', 'png')),
    fecha_descarga TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

-- ============================================
-- ÍNDICES PARA MEJOR PERFORMANCE
-- ============================================

-- Índices para búsquedas frecuentes
CREATE INDEX idx_partituras_usuario ON partituras(usuario_id);
CREATE INDEX idx_partituras_fecha ON partituras(fecha_creacion DESC);
CREATE INDEX idx_partituras_publicas ON partituras(es_publica) WHERE es_publica = TRUE;
CREATE INDEX idx_partituras_titulo ON partituras USING gin(to_tsvector('spanish', titulo));

CREATE INDEX idx_elementos_partitura ON elementos_musicales(partitura_id);
CREATE INDEX idx_colaboraciones_partitura ON colaboraciones(partitura_id);
CREATE INDEX idx_colaboraciones_usuario ON colaboraciones(usuario_id);

CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_tipo_cuenta ON usuarios(tipo_cuenta);

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar fecha_modificacion automáticamente
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para partituras
CREATE TRIGGER trigger_actualizar_fecha_partitura
    BEFORE UPDATE ON partituras
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Función para verificar límite de partituras gratuitas
CREATE OR REPLACE FUNCTION verificar_limite_partituras()
RETURNS TRIGGER AS $$
DECLARE
    cuenta_tipo VARCHAR;
    conteo_partituras INTEGER;
    limite_partituras INTEGER;
BEGIN
    -- Obtener tipo de cuenta del usuario
    SELECT tipo_cuenta INTO cuenta_tipo
    FROM usuarios WHERE id = NEW.usuario_id;
    
    -- Definir límites según tipo de cuenta
    IF cuenta_tipo = 'gratuita' THEN
        limite_partituras := 10; -- 5 subidas + 5 creadas
    ELSIF cuenta_tipo = 'premium' THEN
        limite_partituras := 1000; -- Sin límite práctico
    ELSIF cuenta_tipo = 'educativa' THEN
        limite_partituras := 100;
    ELSE
        limite_partituras := 10;
    END IF;
    
    -- Contar partituras existentes del usuario
    SELECT COUNT(*) INTO conteo_partituras
    FROM partituras
    WHERE usuario_id = NEW.usuario_id;
    
    -- Verificar límite
    IF conteo_partituras >= limite_partituras THEN
        RAISE EXCEPTION 'Límite de partituras alcanzado para tu tipo de cuenta (%)', cuenta_tipo;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar límite al insertar partituras
CREATE TRIGGER trigger_verificar_limite_partituras
    BEFORE INSERT ON partituras
    FOR EACH ROW
    EXECUTE FUNCTION verificar_limite_partituras();

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista para dashboard de usuario
CREATE OR REPLACE VIEW vista_dashboard_usuario AS
SELECT 
    u.id as usuario_id,
    u.nombre,
    u.email,
    u.tipo_cuenta,
    u.espacio_disponible_mb,
    COUNT(p.id) as total_partituras,
    COUNT(CASE WHEN p.tipo = 'creada' THEN 1 END) as partituras_creadas,
    COUNT(CASE WHEN p.tipo = 'subida' THEN 1 END) as partituras_subidas,
    COALESCE(SUM(p.tamanio_bytes), 0) as espacio_usado_bytes,
    MAX(p.fecha_creacion) as ultima_partitura_fecha
FROM usuarios u
LEFT JOIN partituras p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email, u.tipo_cuenta, u.espacio_disponible_mb;

-- Vista para partituras públicas con información del creador
CREATE OR REPLACE VIEW vista_partituras_publicas AS
SELECT 
    p.*,
    u.nombre as creador_nombre,
    u.email as creador_email,
    COUNT(d.id) as total_descargas
FROM partituras p
JOIN usuarios u ON p.usuario_id = u.id
LEFT JOIN descargas d ON p.id = d.partitura_id
WHERE p.es_publica = TRUE
GROUP BY p.id, u.id;

-- ============================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- ============================================

COMMENT ON TABLE usuarios IS 'Tabla principal de usuarios del sistema PartiturasApp';
COMMENT ON TABLE partituras IS 'Almacena todas las partituras creadas o subidas por usuarios';
COMMENT ON TABLE elementos_musicales IS 'Elementos individuales que componen una partitura';
COMMENT ON TABLE colaboraciones IS 'Registra colaboraciones entre usuarios en partituras';
COMMENT ON TABLE historial_cambios IS 'Historial de cambios para control de versiones';
COMMENT ON TABLE plantillas IS 'Plantillas predefinidas para facilitar la creación de partituras';
COMMENT ON TABLE descargas IS 'Registro de descargas de partituras en diferentes formatos';

-- ============================================
-- FIN DEL ESQUEMA
-- ============================================
EOF

# Script de datos iniciales
cat > scripts/sql/seed.sql << 'EOF'
-- ============================================
-- DATOS INICIALES PARA PARTITURASAPP
-- ============================================

-- Insertar plantillas predefinidas
INSERT INTO plantillas (nombre, descripcion, tipo_instrumento, nivel_dificultad, datos_plantilla, es_publica, veces_usada) VALUES
('Pentagrama Vacío', 'Pentagrama básico para comenzar', 'general', 'principiante', 
 '{"compas": "4/4", "tonalidad": "C", "clave": "sol", "tempo": 120}'::jsonb, 
 TRUE, 0),

('Ejercicio de Escalas - Do Mayor', 'Plantilla para practicar escalas mayores', 'piano', 'principiante', 
 '{"compas": "4/4", "tonalidad": "C", "clave": "sol", "elementos": [
   {"tipo": "nota", "nota": "C4", "duracion": "negra"},
   {"tipo": "nota", "nota": "D4", "duracion": "negra"},
   {"tipo": "nota", "nota": "E4", "duracion": "negra"},
   {"tipo": "nota", "nota": "F4", "duracion": "negra"},
   {"tipo": "nota", "nota": "G4", "duracion": "negra"},
   {"tipo": "nota", "nota": "A4", "duracion": "negra"},
   {"tipo": "nota", "nota": "B4", "duracion": "negra"},
   {"tipo": "nota", "nota": "C5", "duracion": "negra"}
 ]}'::jsonb, 
 TRUE, 0),

('Patrón Rítmico Básico', 'Ejercicio de ritmo para principiantes', 'percusion', 'principiante', 
 '{"compas": "4/4", "elementos": [
   {"tipo": "nota", "instrumento": "caja", "duracion": "negra"},
   {"tipo": "silencia", "duracion": "negra"},
   {"tipo": "nota", "instrumento": "caja", "duracion": "negra"},
   {"tipo": "silencia", "duracion": "negra"}
 ]}'::jsonb, 
 TRUE, 0),

('Melodía Simple', 'Melodía básica para iniciación musical', 'flauta', 'principiante', 
 '{"compas": "3/4", "tonalidad": "G", "clave": "sol", "elementos": [
   {"tipo": "nota", "nota": "G4", "duracion": "negra"},
   {"tipo": "nota", "nota": "A4", "duracion": "negra"},
   {"tipo": "nota", "nota": "B4", "duracion": "negra"},
   {"tipo": "nota", "nota": "C5", "duracion": "negra"},
   {"tipo": "nota", "nota": "B4", "duracion": "negra"},
   {"tipo": "nota", "nota": "A4", "duracion": "negra"}
 ]}'::jsonb, 
 TRUE, 0),

('Acordes de Guitarra', 'Progresión básica de acordes', 'guitarra', 'intermedio', 
 '{"compas": "4/4", "tonalidad": "C", "clave": "sol", "elementos": [
   {"tipo": "acorde", "acorde": "C", "posicion": "x32010", "duracion": "blanca"},
   {"tipo": "acorde", "acorde": "G", "posicion": "320003", "duracion": "blanca"},
   {"tipo": "acorde", "acorde": "Am", "posicion": "x02210", "duracion": "blanca"},
   {"tipo": "acorde", "acorde": "F", "posicion": "xx3211", "duracion": "blanca"}
 ]}'::jsonb, 
 TRUE, 0);

-- Insertar usuario administrador de ejemplo (contraseña: Admin123!)
INSERT INTO usuarios (email, nombre, apellido, password_hash, tipo_cuenta, esta_verificado, espacio_disponible_mb) VALUES
('admin@partiturasapp.com', 'Administrador', 'Sistema', 
 crypt('Admin123!', gen_salt('bf')), 'premium', TRUE, 1000);

-- Insertar usuario de prueba gratuito (contraseña: Usuario123!)
INSERT INTO usuarios (email, nombre, apellido, password_hash, tipo_cuenta, esta_verificado) VALUES
('usuario@partiturasapp.com', 'Usuario', 'Demo', 
 crypt('Usuario123!', gen_salt('bf')), 'gratuita', TRUE);

-- Insertar usuario educativo de prueba (contraseña: Educativo123!)
INSERT INTO usuarios (email, nombre, apellido, password_hash, tipo_cuenta, esta_verificado, espacio_disponible_mb) VALUES
('profesor@partiturasapp.com', 'Profesor', 'Música', 
 crypt('Educativo123!', gen_salt('bf')), 'educativa', TRUE, 200);

-- Insertar algunas partituras de ejemplo
INSERT INTO partituras (usuario_id, titulo, descripcion, tipo, compas, tonalidad, bpm, es_publica, datos_musicales) VALUES
((SELECT id FROM usuarios WHERE email = 'usuario@partiturasapp.com'), 
 'Mi primera melodía', 'Una simple melodía en Do Mayor', 'creada', '4/4', 'C', 120, TRUE,
 '{"tempo": 120, "clave": "sol", "notas": [
   {"tiempo": 0, "nota": "C4", "duracion": "negra"},
   {"tiempo": 1, "nota": "D4", "duracion": "negra"},
   {"tiempo": 2, "nota": "E4", "duracion": "negra"},
   {"tiempo": 3, "nota": "F4", "duracion": "negra"}
 ]}'::jsonb),

((SELECT id FROM usuarios WHERE email = 'profesor@partiturasapp.com'),
 'Ejercicio de escalas', 'Escala de Sol Mayor para estudiantes', 'creada', '4/4', 'G', 100, TRUE,
 '{"tempo": 100, "clave": "sol", "notas": [
   {"tiempo": 0, "nota": "G4", "duracion": "corchea"},
   {"tiempo": 0.5, "nota": "A4", "duracion": "corchea"},
   {"tiempo": 1, "nota": "B4", "duracion": "corchea"},
   {"tiempo": 1.5, "nota": "C5", "duracion": "corchea"}
 ]}'::jsonb);

-- Insertar elementos musicales para las partituras
INSERT INTO elementos_musicales (partitura_id, tipo_elemento, tiempo_inicio, tiempo_duracion, orden, atributos) 
SELECT p.id, 'clave', 0, NULL, 1, '{"clave": "sol", "posicion": 2}'::jsonb
FROM partituras p
WHERE p.titulo = 'Mi primera melodía'
UNION ALL
SELECT p.id, 'nota', 0, 1, 2, '{"nota": "C4", "duracion": "negra", "octava": 4}'::jsonb
FROM partituras p
WHERE p.titulo = 'Mi primera melodía'
UNION ALL
SELECT p.id, 'nota', 1, 1, 3, '{"nota": "D4", "duracion": "negra", "octava": 4}'::jsonb
FROM partituras p
WHERE p.titulo = 'Mi primera melodía';

-- Insertar algunas descargas de ejemplo
INSERT INTO descargas (partitura_id, usuario_id, formato, ip_address, user_agent) VALUES
((SELECT id FROM partituras WHERE titulo = 'Mi primera melodía'),
 (SELECT id FROM usuarios WHERE email = 'profesor@partiturasapp.com'),
 'pdf', '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');

-- Insertar una colaboración de ejemplo
INSERT INTO colaboraciones (partitura_id, usuario_id, rol, estado, fecha_aceptacion) VALUES
((SELECT id FROM partituras WHERE titulo = 'Mi primera melodía'),
 (SELECT id FROM usuarios WHERE email = 'profesor@partiturasapp.com'),
 'editor', 'aceptada', NOW());

-- Insertar historial de ejemplo
INSERT INTO historial_cambios (partitura_id, usuario_id, tipo_cambio, descripcion, datos_anteriores, datos_nuevos) VALUES
((SELECT id FROM partituras WHERE titulo = 'Mi primera melodía'),
 (SELECT id FROM usuarios WHERE email = 'usuario@partiturasapp.com'),
 'creacion', 'Partitura creada inicialmente', 
 NULL,
 '{"titulo": "Mi primera melodía", "compas": "4/4", "tonalidad": "C"}'::jsonb);

-- ============================================
-- CONFIGURACIÓN ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE partituras ENABLE ROW LEVEL SECURITY;
ALTER TABLE elementos_musicales ENABLE ROW LEVEL SECURITY;
ALTER TABLE colaboraciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_cambios ENABLE ROW LEVEL SECURITY;
ALTER TABLE plantillas ENABLE ROW LEVEL SECURITY;
ALTER TABLE descargas ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios (si se usa autenticación nativa)
CREATE POLICY "Usuarios ven solo su data" ON usuarios
    FOR SELECT USING (auth.uid() = id OR current_user = 'postgres');

CREATE POLICY "Usuarios actualizan solo su data" ON usuarios
    FOR UPDATE USING (auth.uid() = id OR current_user = 'postgres');

-- Políticas para partituras
CREATE POLICY "Ver partituras propias y públicas" ON partituras
    FOR SELECT USING (
        usuario_id = current_setting('app.user_id', true)::uuid OR 
        es_publica = TRUE OR
        current_user = 'postgres'
    );

CREATE POLICY "Insertar partituras propias" ON partituras
    FOR INSERT WITH CHECK (usuario_id = current_setting('app.user_id', true)::uuid);

CREATE POLICY "Actualizar partituras propias" ON partituras
    FOR UPDATE USING (usuario_id = current_setting('app.user_id', true)::uuid OR current_user = 'postgres');

CREATE POLICY "Eliminar partituras propias" ON partituras
    FOR DELETE USING (usuario_id = current_setting('app.user_id', true)::uuid OR current_user = 'postgres');

-- ============================================
-- FIN DE LOS DATOS INICIALES
-- ============================================
EOF

# ===========================================
# 6. CREAR ARCHIVOS DE DOCUMENTACIÓN
# ===========================================
echo "6. Creando archivos de documentación..."

# Documentación API
cat > docs/api/README.md << 'EOF'
# 📚 Documentación API - PartiturasApp

## Autenticación

### Registro de usuario
```http
POST /api/auth/register
Content-Type: application/json

{
  "email": "usuario@ejemplo.com",
  "password": "contraseña123",
  "nombre": "Nombre",
  "apellido": "Apellido"
}