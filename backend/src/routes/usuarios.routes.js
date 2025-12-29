const express = require('express');
const router = express.Router();
const usuariosController = require('../controllers/usuarios.controller');
const authMiddleware = require('../middleware/auth.middleware');

// Rutas públicas
router.get('/public/:id', usuariosController.getPublicProfile);

// Rutas protegidas
router.use(authMiddleware);
router.get('/dashboard', usuariosController.getDashboard);
router.get('/estadisticas', usuariosController.getEstadisticas);
router.put('/configuracion', usuariosController.updateConfiguracion);
router.put('/upgrade-account', usuariosController.upgradeAccount);

// Admin routes
router.get('/admin/users', authMiddleware, usuariosController.getAllUsers);
router.put('/admin/users/:id', authMiddleware, usuariosController.updateUserRole);

module.exports = router;
