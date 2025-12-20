import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { createClient } from '@supabase/supabase-js';
import path from 'path';
import { fileURLToPath } from 'url';

// Obtener __dirname en ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// IMPORTANTE: Cargar .env desde la raíz del proyecto
const envPath = path.resolve(__dirname, '../../../.env');
console.log('🔍 Buscando .env en:', envPath);
dotenv.config({ path: envPath });

const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(cors({
    origin: 'http://localhost:3000',
    credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Debug: Mostrar todas las variables de entorno relevantes
console.log('\n🎵 =================================');
console.log('🎵 PartiturasApp Backend API');
console.log('🎵 =================================\n');

console.log('🔧 Variables de entorno cargadas:');
console.log('- NODE_ENV:', process.env.NODE_ENV || 'development');
console.log('- PORT:', PORT);
console.log('- VITE_SUPABASE_URL:', process.env.VITE_SUPABASE_URL ? '✅' : '❌');
console.log('- NEXT_PUBLIC_SUPABASE_URL:', process.env.NEXT_PUBLIC_SUPABASE_URL ? '✅' : '❌');
console.log('- SUPABASE_SERVICE_ROLE_KEY:', process.env.SUPABASE_SERVICE_ROLE_KEY ? '✅' : '❌');

// Configurar Supabase
const supabaseUrl = process.env.VITE_SUPABASE_URL || process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

let supabase = null;
if (supabaseUrl && supabaseServiceKey) {
    supabase = createClient(supabaseUrl, supabaseServiceKey);
    console.log('\n✅ Supabase cliente inicializado');
} else {
    console.log('\n⚠️  No se pudo inicializar Supabase - faltan credenciales');
}

// ============================================
// RUTAS DE LA API
// ============================================

// Health check - siempre disponible
app.get('/api/health', (req, res) => {
    res.json({
        status: 'ok',
        service: 'PartiturasApp API',
        version: '1.0.0',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        supabase: {
            configured: !!supabase,
            url: supabaseUrl || 'No configurada'
        }
    });
});

// Test de conexión a Supabase
app.get('/api/test-supabase', async (req, res) => {
    if (!supabase) {
        return res.status(500).json({
            error: 'Supabase no configurado',
            message: 'Faltan credenciales de Supabase'
        });
    }

    try {
        // Intentar una consulta simple
        const { data, error } = await supabase
            .from('usuarios')
            .select('count', { count: 'exact', head: true });

        if (error) {
            // Si la tabla no existe, eso está bien - al menos nos conectamos
            if (error.code === '42P01') {
                return res.json({
                    status: 'connected',
                    message: 'Conexión exitosa a Supabase (tabla usuarios no existe aún)',
                    error: error.message
                });
            }
            throw error;
        }

        res.json({
            status: 'connected',
            message: 'Conexión exitosa a Supabase',
            tableExists: true,
            count: data
        });
    } catch (error) {
        console.error('❌ Error en test-supabase:', error);
        res.status(500).json({
            error: 'Error de conexión a Supabase',
            message: error.message
        });
    }
});

// Obtener todas las partituras
app.get('/api/partituras', async (req, res) => {
    if (!supabase) {
        return res.status(500).json({
            error: 'Supabase no configurado'
        });
    }

    try {
        const { data, error } = await supabase
            .from('partituras')
            .select('*')
            .order('fecha_creacion', { ascending: false })
            .limit(10);

        if (error) throw error;

        res.json({
            success: true,
            data: data || [],
            count: data ? data.length : 0
        });
    } catch (error) {
        console.error('❌ Error obteniendo partituras:', error);
        
        // Si la tabla no existe, devolver array vacío (esto es esperado inicialmente)
        if (error.code === '42P01') {
            return res.json({
                success: true,
                data: [],
                count: 0,
                message: 'La tabla partituras aún no existe. Ejecuta el script de inicialización.'
            });
        }
        
        res.status(500).json({
            error: 'Error obteniendo partituras',
            message: error.message
        });
    }
});

// Obtener partitura por ID
app.get('/api/partituras/:id', async (req, res) => {
    if (!supabase) {
        return res.status(500).json({
            error: 'Supabase no configurado'
        });
    }

    try {
        const { data, error } = await supabase
            .from('partituras')
            .select('*')
            .eq('id', req.params.id)
            .single();

        if (error) throw error;

        res.json({
            success: true,
            data
        });
    } catch (error) {
        console.error('❌ Error obteniendo partitura:', error);
        res.status(500).json({
            error: 'Error obteniendo partitura',
            message: error.message
        });
    }
});

// Crear nueva partitura
app.post('/api/partituras', async (req, res) => {
    if (!supabase) {
        return res.status(500).json({
            error: 'Supabase no configurado'
        });
    }

    try {
        const partitura = {
            titulo: req.body.titulo || 'Nueva Partitura',
            descripcion: req.body.descripcion || '',
            tipo: req.body.tipo || 'creada',
            compas: req.body.compas || '4/4',
            tonalidad: req.body.tonalidad || 'C',
            bpm: req.body.bpm || 120,
            datos_musicales: req.body.datos_musicales || {},
            es_publica: req.body.es_publica || false,
            usuario_id: req.body.usuario_id || 'demo-user-id' // En producción esto vendría del auth
        };

        const { data, error } = await supabase
            .from('partituras')
            .insert([partitura])
            .select()
            .single();

        if (error) throw error;

        res.json({
            success: true,
            message: 'Partitura creada exitosamente',
            data
        });
    } catch (error) {
        console.error('❌ Error creando partitura:', error);
        res.status(500).json({
            error: 'Error creando partitura',
            message: error.message
        });
    }
});

// Usuarios
app.get('/api/usuarios', async (req, res) => {
    if (!supabase) {
        return res.status(500).json({
            error: 'Supabase no configurado'
        });
    }

    try {
        const { data, error } = await supabase
            .from('usuarios')
            .select('id, email, nombre, apellido, tipo_cuenta, fecha_registro')
            .order('fecha_registro', { ascending: false })
            .limit(20);

        if (error) throw error;

        res.json({
            success: true,
            data: data || [],
            count: data ? data.length : 0
        });
    } catch (error) {
        console.error('❌ Error obteniendo usuarios:', error);
        
        // Si la tabla no existe, devolver array vacío
        if (error.code === '42P01') {
            return res.json({
                success: true,
                data: [],
                count: 0,
                message: 'La tabla usuarios aún no existe. Ejecuta el script de inicialización.'
            });
        }
        
        res.status(500).json({
            error: 'Error obteniendo usuarios',
            message: error.message
        });
    }
});

// Inicializar base de datos (solo para desarrollo)
app.post('/api/admin/init-db', async (req, res) => {
    // Proteger esta ruta en producción
    if (process.env.NODE_ENV === 'production') {
        return res.status(403).json({ error: 'No permitido en producción' });
    }

    try {
        // Aquí iría la lógica para ejecutar el SQL de inicialización
        res.json({
            success: true,
            message: 'Endpoint para inicializar BD. Usa el script scripts/init-db.sh'
        });
    } catch (error) {
        res.status(500).json({
            error: 'Error inicializando BD',
            message: error.message
        });
    }
});

// Ruta raíz
app.get('/', (req, res) => {
    res.json({
        message: 'Bienvenido a PartiturasApp API',
        version: '1.0.0',
        endpoints: {
            health: '/api/health',
            testSupabase: '/api/test-supabase',
            partituras: {
                list: 'GET /api/partituras',
                get: 'GET /api/partituras/:id',
                create: 'POST /api/partituras'
            },
            usuarios: 'GET /api/usuarios',
            admin: 'POST /api/admin/init-db (dev only)'
        },
        documentation: 'Ver README.md para más información'
    });
});

// Middleware de 404
app.use((req, res) => {
    res.status(404).json({
        error: 'Ruta no encontrada',
        path: req.path,
        method: req.method
    });
});

// Middleware de manejo de errores
app.use((err, req, res, next) => {
    console.error('❌ Error no manejado:', err);
    res.status(500).json({
        error: 'Error interno del servidor',
        message: process.env.NODE_ENV === 'development' ? err.message : 'Contacta al administrador'
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`\n🚀 Servidor iniciado en: http://localhost:${PORT}`);
    console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
    console.log(`🔗 Test Supabase: http://localhost:${PORT}/api/test-supabase`);
    console.log(`🎵 Partituras: http://localhost:${PORT}/api/partituras`);
    console.log(`👥 Usuarios: http://localhost:${PORT}/api/usuarios`);
    console.log('\n⚠️  NOTA: Si las tablas no existen, ejecuta:');
    console.log('   ./scripts/init-db.sh');
    console.log('🎵 =================================\n');
});