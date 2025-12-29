const supabase = require('../services/supabase.service');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');

const authController = {
  async register(req, res) {
    try {
      const { email, password, nombre, apellido } = req.body;
      
      // Validaciones básicas
      if (!email || !password || !nombre) {
        return res.status(400).json({ error: 'Faltan campos requeridos' });
      }
      
      // Verificar si usuario ya existe
      const { data: existingUser } = await supabase
        .from('usuarios')
        .select('id')
        .eq('email', email)
        .single();
        
      if (existingUser) {
        return res.status(409).json({ error: 'El email ya está registrado' });
      }
      
      // Hash de contraseña
      const saltRounds = 10;
      const passwordHash = await bcrypt.hash(password, saltRounds);
      
      // Crear usuario
      const { data: newUser, error } = await supabase
        .from('usuarios')
        .insert([{
          email,
          nombre,
          apellido,
          password_hash: passwordHash,
          tipo_cuenta: 'gratuita',
          configuracion: { tema: 'claro', idioma: 'es', notificaciones: true }
        }])
        .select()
        .single();
        
      if (error) throw error;
      
      // Generar token JWT
      const token = jwt.sign(
        { userId: newUser.id, email: newUser.email },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );
      
      res.status(201).json({
        message: 'Usuario registrado exitosamente',
        user: {
          id: newUser.id,
          email: newUser.email,
          nombre: newUser.nombre,
          tipo_cuenta: newUser.tipo_cuenta
        },
        token
      });
      
    } catch (error) {
      console.error('Error en registro:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async login(req, res) {
    try {
      const { email, password } = req.body;
      
      if (!email || !password) {
        return res.status(400).json({ error: 'Email y contraseña requeridos' });
      }
      
      // Buscar usuario
      const { data: user, error } = await supabase
        .from('usuarios')
        .select('*')
        .eq('email', email)
        .single();
        
      if (error || !user) {
        return res.status(401).json({ error: 'Credenciales inválidas' });
      }
      
      // Verificar contraseña
      const validPassword = await bcrypt.compare(password, user.password_hash);
      if (!validPassword) {
        return res.status(401).json({ error: 'Credenciales inválidas' });
      }
      
      // Actualizar último acceso
      await supabase
        .from('usuarios')
        .update({ ultimo_acceso: new Date().toISOString() })
        .eq('id', user.id);
      
      // Generar token
      const token = jwt.sign(
        { userId: user.id, email: user.email },
        process.env.JWT_SECRET,
        { expiresIn: '7d' }
      );
      
      res.json({
        message: 'Login exitoso',
        user: {
          id: user.id,
          email: user.email,
          nombre: user.nombre,
          tipo_cuenta: user.tipo_cuenta,
          configuracion: user.configuracion
        },
        token
      });
      
    } catch (error) {
      console.error('Error en login:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  async getProfile(req, res) {
    try {
      const userId = req.userId;
      
      const { data: user, error } = await supabase
        .from('usuarios')
        .select('id, email, nombre, apellido, tipo_cuenta, fecha_registro, configuracion')
        .eq('id', userId)
        .single();
        
      if (error) throw error;
      
      res.json(user);
      
    } catch (error) {
      console.error('Error obteniendo perfil:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  },
  
  logout(req, res) {
    res.json({ message: 'Logout exitoso' });
  },
  
  refreshToken(req, res) {
    // Implementar refresh token si es necesario
    res.json({ message: 'Refresh token endpoint' });
  },
  
  forgotPassword(req, res) {
    // Implementar recuperación de contraseña
    res.json({ message: 'Forgot password endpoint' });
  },
  
  resetPassword(req, res) {
    // Implementar reset de contraseña
    res.json({ message: 'Reset password endpoint' });
  },
  
  async updateProfile(req, res) {
    try {
      const userId = req.userId;
      const { nombre, apellido, configuracion } = req.body;
      
      const updates = {};
      if (nombre) updates.nombre = nombre;
      if (apellido) updates.apellido = apellido;
      if (configuracion) updates.configuracion = configuracion;
      
      const { data: updatedUser, error } = await supabase
        .from('usuarios')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
        
      if (error) throw error;
      
      res.json({
        message: 'Perfil actualizado exitosamente',
        user: updatedUser
      });
      
    } catch (error) {
      console.error('Error actualizando perfil:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    }
  }
};

module.exports = authController;
