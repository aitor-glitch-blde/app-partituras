const express = require('express');
const router = express.Router();
const partiturasController = require('../controllers/partituras.controller');
const authMiddleware = require('../middleware/auth.middleware');
const uploadMiddleware = require('../middleware/upload.middleware');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// Rutas CRUD
router.get('/', partiturasController.getAllPartituras);
router.get('/publicas', partiturasController.getPartiturasPublicas);
router.get('/:id', partiturasController.getPartituraById);
router.post('/', partiturasController.createPartitura);
router.post('/upload', uploadMiddleware.single('partitura'), partiturasController.uploadPartitura);
router.put('/:id', partiturasController.updatePartitura);
router.delete('/:id', partiturasController.deletePartitura);

// Acciones específicas
router.post('/:id/clone', partiturasController.clonePartitura);
router.post('/:id/share', partiturasController.sharePartitura);
router.get('/:id/export/pdf', partiturasController.exportToPDF);
router.get('/:id/export/midi', partiturasController.exportToMIDI);

// Elementos musicales
router.get('/:id/elementos', partiturasController.getElementos);
router.post('/:id/elementos', partiturasController.addElemento);
router.put('/:id/elementos/:elementoId', partiturasController.updateElemento);
router.delete('/:id/elementos/:elementoId', partiturasController.deleteElemento);

module.exports = router;
