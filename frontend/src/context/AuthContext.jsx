import { createContext, useState, useContext, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { supabase } from '../services/supabase';
import api from '../services/api';

const AuthContext = createContext({});

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    // Verificar sesión al cargar
    checkSession();
    
    // Escuchar cambios de autenticación
    const { data: authListener } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        if (session) {
          setUser(session.user);
          // Configurar token en API
          api.defaults.headers.common['Authorization'] = `Bearer ${session.access_token}`;
        } else {
          setUser(null);
          delete api.defaults.headers.common['Authorization'];
        }
        setLoading(false);
      }
    );

    return () => {
      authListener?.subscription.unsubscribe();
    };
  }, []);

  const checkSession = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      if (session) {
        setUser(session.user);
        api.defaults.headers.common['Authorization'] = `Bearer ${session.access_token}`;
      }
    } catch (error) {
      console.error('Error verificando sesión:', error);
    } finally {
      setLoading(false);
    }
  };

  const login = async (email, password) => {
    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      
      if (error) throw error;
      return { success: true, data };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const register = async (email, password, userData) => {
    try {
      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: userData,
        },
      });
      
      if (error) throw error;
      return { success: true, data };
    } catch (error) {
      return { success: false, error: error.message };
    }
  };

  const logout = async () => {
    try {
      await supabase.auth.signOut();
      setUser(null);
      navigate('/login');
    } catch (error) {
      console.error('Error cerrando sesión:', error);
    }
  };

  const value = {
    user,
    loading,
    login,
    register,
    logout,
    isAuthenticated: !!user,
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};
