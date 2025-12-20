#!/bin/bash
# start-simple.sh - Script de inicio simplificado para PartiturasApp

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}   🎵 INICIANDO PARTITURASAPP            ${NC}"
echo -e "${BLUE}===========================================${NC}"

# ========== PASO 1: Verificar que .env existe ==========
echo -e "\n${YELLOW}1. Verificando archivo .env...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}❌ Error: Archivo .env no encontrado${NC}"
    echo -e "${YELLOW}Creando archivo .env de ejemplo...${NC}"
    cat > .env << 'EOF'
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://qroeyukbrangbqlaxdnl.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY=sb_publishable_tgm8fV1eI7X48T3UxxGEgA_7Ldb1OAj
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyb2V5dWticmFuZ2JxbGF4ZG5sIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NjE5MzUxNSwiZXhwIjoyMDgxNzY5NTE1fQ.fH7wX9HsFLV4NkDPQ43DyZ1_x7cO6dSnEaUYEDh9tuU
DATABASE_URL=postgresql://postgres:AfxcXzmASFb@db.qroeyukbrangbqlaxdnl.supabase.co:5432/postgres

# Backend Configuration
NODE_ENV=development
PORT=3001
SESSION_SECRET=tu_clave_secreta_aqui_cambiala

# Frontend Configuration
VITE_PORT=3000

# Storage Configuration
MAX_FILE_SIZE=52428800 # 50MB
ALLOWED_FILE_TYPES=image/*,application/pdf

# JWT Configuration
JWT_SECRET=sb_secret_fIrH_kPyJDINoCIF9TGTCQ_4ez-_WFK
EOF
    echo -e "${YELLOW}⚠️  Por favor, revisa el archivo .env creado${NC}"
fi

# Cargar variables de entorno de forma segura
echo -e "${YELLOW}Cargando variables...${NC}"
# Usar un enfoque más seguro para cargar .env
export $(grep -v '^#' .env | grep -v '^$' | xargs) 2>/dev/null || true

# Valores por defecto
export PORT=${PORT:-3001}
export VITE_PORT=${VITE_PORT:-3000}
export NODE_ENV=${NODE_ENV:-development}

echo -e "${GREEN}✅ Variables cargadas${NC}"

# ========== PASO 2: Verificar Node.js y npm ==========
echo -e "\n${YELLOW}2. Verificando Node.js y npm...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm no está instalado${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Node.js $(node -v)${NC}"
echo -e "${GREEN}✅ npm $(npm -v)${NC}"

# ========== PASO 3: Verificar dependencias ==========
echo -e "\n${YELLOW}3. Verificando dependencias...${NC}"

# Backend
if [ ! -d "backend/node_modules" ]; then
    echo -e "${YELLOW}Instalando dependencias del backend...${NC}"
    cd backend
    npm install --silent
    cd ..
fi

# Frontend
if [ ! -d "frontend/node_modules" ]; then
    echo -e "${YELLOW}Instalando dependencias del frontend...${NC}"
    cd frontend
    npm install --silent
    cd ..
fi

echo -e "${GREEN}✅ Dependencias verificadas${NC}"

# ========== PASO 4: Crear archivos esenciales ==========
echo -e "\n${YELLOW}4. Preparando archivos esenciales...${NC}"

# Crear directorios necesarios
mkdir -p backend/logs backend/uploads backend/src
mkdir -p frontend/src

# Backend - server.js
if [ ! -f "backend/src/server.js" ]; then
    cat > backend/src/server.js << 'EOF'
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Configurar Supabase
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

// Middleware
app.use(cors());
app.use(express.json());

// Ruta de salud
app.get('/api/health', async (req, res) => {
    try {
        // Verificar conexión a Supabase
        const { data, error } = await supabase.from('usuarios').select('count', { count: 'exact', head: true });
        
        res.json({
            status: 'ok',
            message: 'PartiturasApp API funcionando',
            timestamp: new Date().toISOString(),
            version: '1.0.0',
            environment: process.env.NODE_ENV || 'development',
            port: PORT,
            supabase: error ? 'error' : 'connected',
            database: error ? 'error' : 'connected'
        });
    } catch (error) {
        res.json({
            status: 'ok',
            message: 'PartiturasApp API funcionando (sin conexión a BD)',
            timestamp: new Date().toISOString(),
            version: '1.0.0',
            environment: process.env.NODE_ENV || 'development',
            port: PORT,
            supabase: 'error',
            database: 'error',
            error: error.message
        });
    }
});

// Ruta de prueba de Supabase
app.get('/api/test-db', async (req, res) => {
    try {
        const { data, error } = await supabase.from('usuarios').select('*').limit(5);
        
        if (error) {
            res.status(500).json({ 
                error: 'Error de base de datos', 
                details: error.message,
                suggestion: 'Ejecuta ./scripts/init-db.sh para crear las tablas'
            });
        } else {
            res.json({
                message: 'Conexión a Supabase exitosa',
                table: 'usuarios',
                count: data?.length || 0,
                data: data
            });
        }
    } catch (error) {
        res.status(500).json({ 
            error: 'Error interno', 
            details: error.message 
        });
    }
});

// Ruta para crear tabla de ejemplo
app.post('/api/setup-db', async (req, res) => {
    try {
        // Crear tabla usuarios si no existe
        const { error } = await supabase.rpc('create_users_table_if_not_exists');
        
        if (error) {
            res.json({ 
                message: 'Tabla no creada (puede que ya exista)',
                error: error.message 
            });
        } else {
            res.json({ 
                message: 'Tabla usuarios creada/verificada',
                status: 'success' 
            });
        }
    } catch (error) {
        res.status(500).json({ 
            error: 'Error creando tabla', 
            details: error.message 
        });
    }
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        message: 'Bienvenido a PartiturasApp API',
        endpoints: {
            health: '/api/health',
            testDb: '/api/test-db',
            setupDb: '/api/setup-db (POST)'
        },
        documentation: 'Ver README.md para más información'
    });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🗄️  Test DB: http://localhost:${PORT}/api/test-db`);
    console.log(`🔗 Supabase URL: ${supabaseUrl}`);
});
EOF
    echo -e "${GREEN}✅ server.js creado${NC}"
fi

# Frontend - archivos esenciales
if [ ! -f "frontend/vite.config.js" ]; then
    cat > frontend/vite.config.js << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: process.env.VITE_PORT || 3000,
    host: true,
    proxy: {
      '/api': {
        target: 'http://localhost:' + (process.env.PORT || 3001),
        changeOrigin: true,
      },
    },
  },
})
EOF
fi

if [ ! -f "frontend/src/App.jsx" ]; then
    mkdir -p frontend/src
    cat > frontend/src/App.jsx << 'EOF'
import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [status, setStatus] = useState({ backend: 'checking', supabase: 'checking' });
  const [healthInfo, setHealthInfo] = useState(null);
  const [dbTest, setDbTest] = useState(null);

  useEffect(() => {
    // Verificar backend
    fetch('/api/health')
      .then(res => res.json())
      .then(data => {
        setHealthInfo(data);
        setStatus(prev => ({ ...prev, backend: 'connected' }));
      })
      .catch(() => {
        setStatus(prev => ({ ...prev, backend: 'error' }));
      });
  }, []);

  const testDatabase = () => {
    setDbTest({ loading: true });
    fetch('/api/test-db')
      .then(res => res.json())
      .then(data => {
        setDbTest({ ...data, loading: false });
        setStatus(prev => ({ ...prev, supabase: data.error ? 'error' : 'connected' }));
      })
      .catch(error => {
        setDbTest({ error: error.message, loading: false });
        setStatus(prev => ({ ...prev, supabase: 'error' }));
      });
  };

  const setupDatabase = () => {
    fetch('/api/setup-db', { method: 'POST' })
      .then(res => res.json())
      .then(data => {
        alert(data.message || 'Operación completada');
      })
      .catch(error => {
        alert('Error: ' + error.message);
      });
  };

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1>🎵 PartiturasApp</h1>
        <p>Plataforma de gestión de partituras musicales</p>
      </header>

      <main style={styles.main}>
        <div style={styles.card}>
          <h2>Estado del Sistema</h2>
          
          <div style={styles.statusGrid}>
            <div style={styles.statusItem}>
              <h3>Backend API</h3>
              <div style={{
                ...styles.statusDot,
                backgroundColor: status.backend === 'connected' ? '#10B981' : 
                               status.backend === 'checking' ? '#F59E0B' : '#EF4444'
              }} />
              <span>{status.backend === 'connected' ? '✅ Conectado' : 
                    status.backend === 'checking' ? '🔄 Verificando...' : '❌ Error'}</span>
            </div>
            
            <div style={styles.statusItem}>
              <h3>Supabase</h3>
              <div style={{
                ...styles.statusDot,
                backgroundColor: status.supabase === 'connected' ? '#10B981' : 
                               status.supabase === 'checking' ? '#F59E0B' : '#EF4444'
              }} />
              <span>{status.supabase === 'connected' ? '✅ Conectado' : 
                    status.supabase === 'checking' ? '🔍 No verificado' : '❌ Error'}</span>
            </div>
          </div>

          {healthInfo && (
            <div style={styles.info}>
              <h3>Información del Backend</h3>
              <p><strong>Versión:</strong> {healthInfo.version}</p>
              <p><strong>Puerto:</strong> {healthInfo.port}</p>
              <p><strong>Entorno:</strong> {healthInfo.environment}</p>
              <p><strong>Base de datos:</strong> {healthInfo.database === 'connected' ? '✅ Conectada' : '❌ No conectada'}</p>
            </div>
          )}

          <div style={styles.actions}>
            <button style={styles.button} onClick={testDatabase} disabled={dbTest?.loading}>
              {dbTest?.loading ? 'Probando...' : 'Probar Base de Datos'}
            </button>
            <button style={{...styles.button, backgroundColor: '#4F46E5'}} onClick={setupDatabase}>
              Configurar BD
            </button>
            <button style={{...styles.button, backgroundColor: '#6B7280'}} onClick={() => window.location.reload()}>
              Actualizar
            </button>
          </div>

          {dbTest && !dbTest.loading && (
            <div style={styles.dbResult}>
              <h3>Resultado de Base de Datos:</h3>
              {dbTest.error ? (
                <div style={styles.error}>
                  <p><strong>Error:</strong> {dbTest.error}</p>
                  {dbTest.suggestion && <p>{dbTest.suggestion}</p>}
                </div>
              ) : (
                <div style={styles.success}>
                  <p><strong>✅ {dbTest.message}</strong></p>
                  <p>Tabla: {dbTest.table}</p>
                  <p>Registros encontrados: {dbTest.count}</p>
                  {dbTest.data && dbTest.data.length > 0 && (
                    <div style={styles.dataPreview}>
                      <p><strong>Datos de ejemplo:</strong></p>
                      <pre>{JSON.stringify(dbTest.data.slice(0, 2), null, 2)}</pre>
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
        </div>

        <div style={styles.instructions}>
          <h3>Próximos pasos:</h3>
          <ol>
            <li>Verifica que el backend esté funcionando (arriba)</li>
            <li>Prueba la conexión a Supabase con el botón "Probar Base de Datos"</li>
            <li>Si hay errores, ejecuta: <code>./scripts/init-db.sh</code></li>
            <li>Desarrolla las funcionalidades específicas de partituras</li>
          </ol>
        </div>
      </main>

      <footer style={styles.footer}>
        <p>PartiturasApp © 2024 - Sistema de gestión de partituras musicales</p>
        <p>Backend: http://localhost:{healthInfo?.port || '3001'} | Frontend: http://localhost:{process.env.VITE_PORT || '3000'}</p>
      </footer>
    </div>
  );
}

const styles = {
  container: {
    minHeight: '100vh',
    backgroundColor: '#f8fafc',
    fontFamily: 'system-ui, -apple-system, sans-serif',
  },
  header: {
    background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
    color: 'white',
    padding: '2rem',
    textAlign: 'center',
  },
  main: {
    maxWidth: '800px',
    margin: '2rem auto',
    padding: '0 1rem',
  },
  card: {
    backgroundColor: 'white',
    borderRadius: '10px',
    padding: '2rem',
    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
    marginBottom: '2rem',
  },
  statusGrid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
    gap: '1rem',
    margin: '2rem 0',
  },
  statusItem: {
    textAlign: 'center',
    padding: '1rem',
    backgroundColor: '#f1f5f9',
    borderRadius: '8px',
  },
  statusDot: {
    width: '20px',
    height: '20px',
    borderRadius: '50%',
    margin: '0 auto 10px',
  },
  info: {
    margin: '2rem 0',
    padding: '1rem',
    backgroundColor: '#f0f9ff',
    borderRadius: '8px',
  },
  actions: {
    display: 'flex',
    gap: '1rem',
    justifyContent: 'center',
    margin: '2rem 0',
  },
  button: {
    padding: '0.75rem 1.5rem',
    backgroundColor: '#10b981',
    color: 'white',
    border: 'none',
    borderRadius: '6px',
    fontSize: '1rem',
    cursor: 'pointer',
    fontWeight: 'bold',
  },
  dbResult: {
    marginTop: '2rem',
    padding: '1rem',
    borderRadius: '8px',
  },
  error: {
    backgroundColor: '#fef2f2',
    color: '#dc2626',
    padding: '1rem',
    borderRadius: '6px',
  },
  success: {
    backgroundColor: '#f0fdf4',
    color: '#166534',
    padding: '1rem',
    borderRadius: '6px',
  },
  dataPreview: {
    marginTop: '1rem',
    backgroundColor: '#1e293b',
    color: '#f1f5f9',
    padding: '1rem',
    borderRadius: '6px',
    overflow: 'auto',
  },
  instructions: {
    backgroundColor: 'white',
    padding: '2rem',
    borderRadius: '10px',
    boxShadow: '0 4px 6px rgba(0,0,0,0.1)',
  },
  footer: {
    textAlign: 'center',
    padding: '2rem',
    backgroundColor: '#f1f5f9',
    color: '#64748b',
    marginTop: '2rem',
  },
};

export default App;
EOF
fi

if [ ! -f "frontend/src/main.jsx" ]; then
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
fi

if [ ! -f "frontend/src/index.css" ]; then
    cat > frontend/src/index.css << 'EOF'
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
}

pre {
  font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
  font-size: 14px;
}
EOF
fi

if [ ! -f "frontend/index.html" ]; then
    cat > frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PartiturasApp | Gestión de Partituras Musicales</title>
  <style>
    body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, sans-serif; }
  </style>
</head>
<body>
  <div id="root"></div>
  <script type="module" src="/src/main.jsx"></script>
</body>
</html>
EOF
fi

echo -e "${GREEN}✅ Archivos preparados${NC}"

# ========== PASO 5: Iniciar backend ==========
echo -e "\n${YELLOW}5. Iniciando backend...${NC}"
echo -e "Puerto: ${PORT}"

# Crear .env para backend
cat > backend/.env << EOF
PORT=$PORT
NODE_ENV=$NODE_ENV
NEXT_PUBLIC_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_ROLE_KEY
DATABASE_URL=$DATABASE_URL
EOF

cd backend

# Iniciar backend en segundo plano
node src/server.js > backend.log 2>&1 &
BACKEND_PID=$!

# Esperar a que inicie
sleep 3

# Verificar si está corriendo
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Error al iniciar backend${NC}"
    echo -e "${YELLOW}Últimas líneas del log:${NC}"
    tail -20 backend.log
    exit 1
fi

echo -e "${GREEN}✅ Backend iniciado (PID: $BACKEND_PID)${NC}"

# Verificar conexión
echo -e "${YELLOW}Verificando conexión...${NC}"
for i in {1..10}; do
    if curl -s http://localhost:$PORT/api/health >/dev/null; then
        echo -e "${GREEN}✅ Backend respondiendo${NC}"
        HEALTH=$(curl -s http://localhost:$PORT/api/health | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        echo -e "Mensaje: $HEALTH"
        break
    fi
    sleep 1
    if [ $i -eq 10 ]; then
        echo -e "${YELLOW}⚠️  Backend no responde, pero el proceso está activo${NC}"
    fi
done

cd ..

# ========== PASO 6: Iniciar frontend ==========
echo -e "\n${YELLOW}6. Iniciando frontend...${NC}"
echo -e "Puerto: ${VITE_PORT}"

# Crear .env para frontend
cat > frontend/.env << EOF
VITE_PORT=$VITE_PORT
VITE_SUPABASE_URL=$NEXT_PUBLIC_SUPABASE_URL
VITE_SUPABASE_ANON_KEY=$NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY
VITE_API_URL=http://localhost:$PORT/api
EOF

cd frontend

# Iniciar frontend en segundo plano
npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!

# Esperar a que inicie
sleep 5

# Verificar si está corriendo
if ! kill -0 $FRONTEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Error al iniciar frontend${NC}"
    echo -e "${YELLOW}Últimas líneas del log:${NC}"
    tail -20 frontend.log
    echo -e "${YELLOW}Continuando solo con backend...${NC}"
    FRONTEND_PID=""
else
    echo -e "${GREEN}✅ Frontend iniciado (PID: $FRONTEND_PID)${NC}"
fi

cd ..

# ========== PASO 7: Mostrar información final ==========
echo -e "\n${BLUE}===========================================${NC}"
echo -e "${GREEN}   🎵 PARTITURASAPP INICIADA           ${NC}"
echo -e "${BLUE}===========================================${NC}"

echo -e "\n${YELLOW}🌐 URLs de acceso:${NC}"
echo -e "  ${GREEN}Backend API:${NC}  http://localhost:$PORT/api/health"
if [ -n "$FRONTEND_PID" ]; then
    echo -e "  ${GREEN}Frontend:${NC}      http://localhost:$VITE_PORT"
else
    echo -e "  ${YELLOW}Frontend:${NC}      No iniciado (ver frontend.log)"
fi

echo -e "\n${YELLOW}📊 Supabase Dashboard:${NC}"
echo -e "  ${BLUE}https://app.supabase.com/project/qroeyukbrangbqlaxdnl${NC}"

echo -e "\n${YELLOW}🔍 Comandos útiles:${NC}"
echo -e "  Ver logs backend:   ${GREEN}tail -f backend/backend.log${NC}"
echo -e "  Ver logs frontend:  ${GREEN}tail -f frontend/frontend.log${NC}"
echo -e "  Probar API:         ${GREEN}curl http://localhost:$PORT/api/health${NC}"
echo -e "  Inicializar BD:     ${GREEN}./scripts/init-db.sh${NC}"

echo -e "\n${YELLOW}🛑 Para detener:${NC}"
echo -e "  Presiona ${RED}Ctrl+C${NC} o ejecuta: ${GREEN}kill $BACKEND_PID $FRONTEND_PID 2>/dev/null${NC}"

echo -e "\n${GREEN}🎵 ¡La aplicación está funcionando!${NC}"

# ========== PASO 8: Mantener script activo y manejar cierre ==========
cleanup() {
    echo -e "\n${YELLOW}🛑 Deteniendo aplicación...${NC}"
    
    if [ -n "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null && echo -e "${GREEN}✅ Frontend detenido${NC}" || true
    fi
    
    kill $BACKEND_PID 2>/dev/null && echo -e "${GREEN}✅ Backend detenido${NC}" || true
    
    echo -e "${GREEN}✅ Aplicación detenida correctamente${NC}"
    exit 0
}

trap cleanup INT TERM

# Mostrar logs en tiempo real
echo -e "\n${BLUE}------------------------------------------------${NC}"
echo -e "${YELLOW}Mostrando logs combinados:${NC}"
echo -e "${BLUE}------------------------------------------------${NC}"
echo -e "${YELLOW}(Presiona Ctrl+C para salir)${NC}\n"

# Usar tail para mostrar logs
tail -f backend/backend.log 2>/dev/null | sed 's/^/[BACKEND] /' &
tail -f frontend/frontend.log 2>/dev/null | sed 's/^/[FRONTEND] /' &

# Esperar a que termine el backend (o Ctrl+C)
wait $BACKEND_PID 2>/dev/null

# Limpiar al salir
cleanup