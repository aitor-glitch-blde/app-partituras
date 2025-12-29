const express = require('express');
const router = express.Router();
const colaboracionesController = require('../controllers/colaboraciones.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

// Gestión de colaboraciones
router.get('/invitaciones', colaboracionesController.getInvitaciones);
router.get('/partitura/:partituraId', colaboracionesController.getColaboradores);
router.post('/invitar', colaboracionesController.invitarColaborador);
router.put('/:id/aceptar', colaboracionesController.aceptarInvitacion);
router.put('/:id/rechazar', colaboracionesController.rechazarInvitacion);
router.put('/:id/rol', colaboracionesController.cambiarRol);
router.delete('/:id', colaboracionesController.eliminarColaborador);

module.exports = router;
