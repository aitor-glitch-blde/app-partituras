import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware básico
app.use(cors());
app.use(express.json());

// Ruta de salud mejorada
app.get('/api/health', (req, res) => {
  const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
  const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY || process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY;
  const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  
  res.json({
    status: 'ok',
    service: 'PartiturasApp API',
    version: '1.0.0',
    port: PORT,
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    supabase: {
      configured: !!(supabaseUrl && supabaseAnonKey),
      url: supabaseUrl ? '✅ Configurado' : '❌ No configurado',
      hasAnonKey: !!supabaseAnonKey,
      hasServiceRoleKey: !!supabaseServiceKey
    },
    database: {
      url: process.env.DATABASE_URL ? '✅ Configurado' : '❌ No configurado',
      type: 'Supabase PostgreSQL'
    }
  });
});

// Ruta de prueba
app.get('/api/test', (req, res) => {
  res.json({
    message: 'API funcionando correctamente',
    endpoints: ['/api/health', '/api/test', '/api/status']
  });
});

// Ruta de estado detallado
app.get('/api/status', (req, res) => {
  res.json({
    system: 'PartiturasApp',
    version: '1.0.0',
    status: 'running',
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    database: {
      type: 'Supabase PostgreSQL',
      status: 'connected'
    }
  });
});

// Ruta principal
app.get('/', (req, res) => {
  res.json({
    message: '🎵 Bienvenido a PartiturasApp API',
    description: 'API para la gestión y creación de partituras musicales',
    endpoints: {
      health: '/api/health',
      status: '/api/status',
      test: '/api/test'
    },
    documentation: 'Ver /api/health para estado del servicio'
  });
});

app.listen(PORT, () => {
  console.log('🎵 =================================');
  console.log('🎵 PartiturasApp Backend API');
  console.log(`🎵 Puerto: ${PORT}`);
  console.log(`🎵 Entorno: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🎵 Health: http://localhost:${PORT}/api/health`);
  console.log('🎵 =================================');
});