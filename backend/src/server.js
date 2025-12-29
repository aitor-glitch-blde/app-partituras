const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const dotenv = require('dotenv');
const path = require('path');

// Cargar variables de entorno
dotenv.config();

// Importar rutas
const authRoutes = require('./routes/auth.routes');
const partiturasRoutes = require('./routes/partituras.routes');
const usuariosRoutes = require('./routes/usuarios.routes');
const colaboracionesRoutes = require('./routes/colaboraciones.routes');

// Inicializar Express
const app = express();
const PORT = process.env.PORT || 3001;

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:3000',
  credentials: true
}));
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir archivos estáticos
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Rutas de API
app.use('/api/auth', authRoutes);
app.use('/api/partituras', partiturasRoutes);
app.use('/api/usuarios', usuariosRoutes);
app.use('/api/colaboraciones', colaboracionesRoutes);

// Ruta de health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    service: 'PartiturasApp API'
  });
});

// Manejo de errores 404
app.use('*', (req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Middleware de manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Error interno del servidor'
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor backend corriendo en http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/api/health`);
});

module.exports = app;
