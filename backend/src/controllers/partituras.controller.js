const supabase = require('../services/supabase.service');

const partiturasController = {
  async getAllPartituras(req, res) {
    try {
      const userId = req.userId;
      const { tipo, pagina = 1, limite = 20 } = req.query;
      
      let query = supabase
        .from('partituras')
        .select('*')
        .eq('usuario_id', userId)
        .order('fecha_creacion', { ascending: false });
      
      if (tipo) {
        query = query.eq('tipo', tipo);
      }
      
      // Paginación
      const desde = (pagina - 1) * limite;
      const hasta = desde + limite - 1;
      query = query.range(desde, hasta);
      
      const { data: partituras, error, count } = await query;
      
      if (error) throw error;
      
      res.json({
        partituras,
        paginacion: {
          pagina: parseInt(pagina),
          limite: parseInt(limite),
          total: count || partituras.length,
          totalPaginas: count ? Math.ceil(count / limite) : 1
        }
      });
      
    } catch (error) {
      console.error('Error obteniendo partituras:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async getPartituraById(req, res) {
    try {
      const { id } = req.params;
      const userId = req.userId;
      
      const { data: partitura, error } = await supabase
        .from('partituras')
        .select(`
          *,
          usuarios:usuario_id (id, nombre, email),
          colaboraciones:colaboraciones!partitura_id (*)
        `)
        .eq('id', id)
        .single();
      
      if (error) {
        if (error.code === 'PGRST116') {
          return res.status(404).json({ error: 'Partitura no encontrada' });
        }
        throw error;
      }
      
      // Verificar permisos
      const esPropietario = partitura.usuario_id === userId;
      const esPublica = partitura.es_publica;
      const esColaborador = partitura.colaboraciones?.some(
        colab => colab.usuario_id === userId && colab.estado === 'aceptada'
      );
      
      if (!esPropietario && !esPublica && !esColaborador) {
        return res.status(403).json({ error: 'No tienes permiso para ver esta partitura' });
      }
      
      // Obtener elementos musicales si existe
      let elementos = [];
      if (partitura.tipo === 'creada') {
        const { data: elementosData } = await supabase
          .from('elementos_musicales')
          .select('*')
          .eq('partitura_id', id)
          .order('orden');
        
        elementos = elementosData || [];
      }
      
      res.json({
        ...partitura,
        elementos
      });
      
    } catch (error) {
      console.error('Error obteniendo partitura:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async createPartitura(req, res) {
    try {
      const userId = req.userId;
      const { titulo, descripcion, compas, tonalidad, bpm, elementos } = req.body;
      
      if (!titulo) {
        return res.status(400).json({ error: 'El título es requerido' });
      }
      
      // Crear partitura
      const nuevaPartitura = {
        usuario_id: userId,
        titulo,
        descripcion: descripcion || '',
        tipo: 'creada',
        compas: compas || '4/4',
        tonalidad: tonalidad || 'C',
        bpm: bpm || 120,
        datos_musicales: {
          compas: compas || '4/4',
          tonalidad: tonalidad || 'C',
          bpm: bpm || 120,
          elementos: elementos || []
        },
        es_publica: false,
        tamanio_bytes: 0
      };
      
      const { data: partituraCreada, error } = await supabase
        .from('partituras')
        .insert([nuevaPartitura])
        .select()
        .single();
        
      if (error) throw error;
      
      // Registrar en historial
      await supabase
        .from('historial_cambios')
        .insert([{
          partitura_id: partituraCreada.id,
          usuario_id: userId,
          tipo_cambio: 'creacion',
          descripcion: 'Partitura creada desde cero',
          datos_nuevos: nuevaPartitura.datos_musicales
        }]);
      
      res.status(201).json({
        message: 'Partitura creada exitosamente',
        partitura: partituraCreada
      });
      
    } catch (error) {
      console.error('Error creando partitura:', error);
      
      // Verificar si es error de límite
      if (error.message && error.message.includes('Límite de partituras')) {
        return res.status(400).json({ error: error.message });
      }
      
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async uploadPartitura(req, res) {
    try {
      const userId = req.userId;
      const file = req.file;
      
      if (!file) {
        return res.status(400).json({ error: 'No se subió ningún archivo' });
      }
      
      const { titulo, descripcion } = req.body;
      
      if (!titulo) {
        return res.status(400).json({ error: 'El título es requerido' });
      }
      
      // Crear registro en base de datos
      const nuevaPartitura = {
        usuario_id: userId,
        titulo,
        descripcion: descripcion || '',
        tipo: 'subida',
        formato_original: file.mimetype,
        ruta_archivo: file.path,
        tamanio_bytes: file.size,
        es_publica: false
      };
      
      const { data: partituraCreada, error } = await supabase
        .from('partituras')
        .insert([nuevaPartitura])
        .select()
        .single();
        
      if (error) throw error;
      
      res.status(201).json({
        message: 'Partitura subida exitosamente',
        partitura: partituraCreada,
        file: {
          originalname: file.originalname,
          filename: file.filename,
          size: file.size,
          mimetype: file.mimetype
        }
      });
      
    } catch (error) {
      console.error('Error subiendo partitura:', error);
      
      // Limpiar archivo si hubo error
      if (req.file) {
        const fs = require('fs');
        fs.unlink(req.file.path, (err) => {
          if (err) console.error('Error eliminando archivo temporal:', err);
        });
      }
      
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async updatePartitura(req, res) {
    try {
      const { id } = req.params;
      const userId = req.userId;
      const updates = req.body;
      
      // Verificar que la partitura exista y el usuario tenga permisos
      const { data: partituraExistente, error: fetchError } = await supabase
        .from('partituras')
        .select('usuario_id')
        .eq('id', id)
        .single();
        
      if (fetchError || !partituraExistente) {
        return res.status(404).json({ error: 'Partitura no encontrada' });
      }
      
      if (partituraExistente.usuario_id !== userId) {
        return res.status(403).json({ error: 'No tienes permiso para editar esta partitura' });
      }
      
      // Guardar datos anteriores para historial
      const { data: datosAnteriores } = await supabase
        .from('partituras')
        .select('datos_musicales')
        .eq('id', id)
        .single();
      
      // Actualizar partitura
      const { data: partituraActualizada, error } = await supabase
        .from('partituras')
        .update({
          ...updates,
          fecha_modificacion: new Date().toISOString()
        })
        .eq('id', id)
        .select()
        .single();
        
      if (error) throw error;
      
      // Registrar en historial
      await supabase
        .from('historial_cambios')
        .insert([{
          partitura_id: id,
          usuario_id: userId,
          tipo_cambio: 'actualizacion',
          descripcion: 'Partitura actualizada',
          datos_anteriores: datosAnteriores?.datos_musicales || {},
          datos_nuevos: updates.datos_musicales || updates
        }]);
      
      res.json({
        message: 'Partitura actualizada exitosamente',
        partitura: partituraActualizada
      });
      
    } catch (error) {
      console.error('Error actualizando partitura:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async deletePartitura(req, res) {
    try {
      const { id } = req.params;
      const userId = req.userId;
      
      // Verificar que la partitura exista y el usuario tenga permisos
      const { data: partitura, error: fetchError } = await supabase
        .from('partituras')
        .select('usuario_id, ruta_archivo')
        .eq('id', id)
        .single();
        
      if (fetchError || !partitura) {
        return res.status(404).json({ error: 'Partitura no encontrada' });
      }
      
      if (partitura.usuario_id !== userId) {
        return res.status(403).json({ error: 'No tienes permiso para eliminar esta partitura' });
      }
      
      // Eliminar archivo físico si existe
      if (partitura.ruta_archivo) {
        const fs = require('fs');
        if (fs.existsSync(partitura.ruta_archivo)) {
          fs.unlinkSync(partitura.ruta_archivo);
        }
      }
      
      // Eliminar de la base de datos (CASCADE eliminará elementos relacionados)
      const { error } = await supabase
        .from('partituras')
        .delete()
        .eq('id', id);
        
      if (error) throw error;
      
      res.json({ message: 'Partitura eliminada exitosamente' });
      
    } catch (error) {
      console.error('Error eliminando partitura:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async getPartiturasPublicas(req, res) {
    try {
      const { pagina = 1, limite = 20, instrumento, nivel } = req.query;
      
      let query = supabase
        .from('partituras')
        .select(`
          *,
          usuarios:usuario_id (id, nombre, email)
        `)
        .eq('es_publica', true)
        .order('fecha_creacion', { ascending: false });
      
      // Filtros opcionales
      if (instrumento) {
        query = query.ilike('datos_musicales->>instrumento', `%${instrumento}%`);
      }
      
      if (nivel) {
        query = query.eq('datos_musicales->>nivel', nivel);
      }
      
      // Paginación
      const desde = (pagina - 1) * limite;
      const hasta = desde + limite - 1;
      query = query.range(desde, hasta);
      
      const { data: partituras, error, count } = await query;
      
      if (error) throw error;
      
      res.json({
        partituras,
        paginacion: {
          pagina: parseInt(pagina),
          limite: parseInt(limite),
          total: count || partituras.length,
          totalPaginas: count ? Math.ceil(count / limite) : 1
        }
      });
      
    } catch (error) {
      console.error('Error obteniendo partituras públicas:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  // Métodos para elementos musicales
  async getElementos(req, res) {
    try {
      const { id } = req.params;
      
      const { data: elementos, error } = await supabase
        .from('elementos_musicales')
        .select('*')
        .eq('partitura_id', id)
        .order('orden');
        
      if (error) throw error;
      
      res.json(elementos || []);
      
    } catch (error) {
      console.error('Error obteniendo elementos:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async addElemento(req, res) {
    try {
      const { id } = req.params;
      const userId = req.userId;
      const elemento = req.body;
      
      // Verificar permisos
      const { data: partitura } = await supabase
        .from('partituras')
        .select('usuario_id')
        .eq('id', id)
        .single();
        
      if (!partitura || partitura.usuario_id !== userId) {
        return res.status(403).json({ error: 'No tienes permiso para modificar esta partitura' });
      }
      
      const nuevoElemento = {
        partitura_id: id,
        ...elemento
      };
      
      const { data: elementoCreado, error } = await supabase
        .from('elementos_musicales')
        .insert([nuevoElemento])
        .select()
        .single();
        
      if (error) throw error;
      
      res.status(201).json(elementoCreado);
      
    } catch (error) {
      console.error('Error añadiendo elemento:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  }
};

module.exports = partiturasController;
