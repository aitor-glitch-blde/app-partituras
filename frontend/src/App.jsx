import React, { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import './App.css';

// Crear cliente Supabase
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;
const BACKEND_PORT = 3001;

const supabase = supabaseUrl && supabaseAnonKey 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

function App() {
  const [healthStatus, setHealthStatus] = useState(null);
  const [loading, setLoading] = useState(true);
  const [supabaseStatus, setSupabaseStatus] = useState(null);

  useEffect(() => {
    // Verificar salud del backend
    fetch(`http://localhost:${BACKEND_PORT}/api/health`)
      .then(response => response.json())
      .then(data => {
        setHealthStatus(data);
        setLoading(false);
      })
      .catch(error => {
        console.error('Error checking health:', error);
        setHealthStatus({ status: 'error', message: 'No se pudo conectar al backend' });
        setLoading(false);
      });

    // Verificar conexión a Supabase
    if (supabase) {
      supabase.from('usuarios').select('count', { count: 'exact', head: true })
        .then(() => {
          setSupabaseStatus({ connected: true });
        })
        .catch(error => {
          console.log('Supabase connection test (expected error for missing table):', error.message);
          setSupabaseStatus({ connected: false, error: error.message });
        });
    }
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-purple-100">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center">
                <span className="text-white text-2xl">🎵</span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-gray-900">PartiturasApp</h1>
                <p className="text-sm text-gray-600">Gestión y creación de partituras musicales</p>
              </div>
            </div>
            <div className="flex space-x-4">
              <button className="px-4 py-2 text-sm font-medium text-blue-600 hover:text-blue-800">
                Iniciar Sesión
              </button>
              <button className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700">
                Registrarse
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 py-12">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            Crea, comparte y aprende música
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            Una plataforma web completa para músicos, compositores y estudiantes
          </p>
        </div>

        {/* Status Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          {/* Frontend Status */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Frontend</h3>
              <span className="px-3 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800">
                ✅ Activo
              </span>
            </div>
            <p className="text-gray-600 mb-4">Aplicación React en ejecución</p>
            <div className="text-sm text-gray-500">
              <p>• React 18</p>
              <p>• Vite</p>
              <p>• Tailwind CSS</p>
            </div>
            <div className="mt-4 pt-4 border-t border-gray-100">
              <p className="text-xs text-gray-400">URL: http://localhost:3000</p>
            </div>
          </div>

          {/* Backend Status */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Backend API</h3>
              {loading ? (
                <span className="px-3 py-1 text-xs font-medium rounded-full bg-yellow-100 text-yellow-800">
                  ⏳ Verificando...
                </span>
              ) : healthStatus?.status === 'ok' ? (
                <span className="px-3 py-1 text-xs font-medium rounded-full bg-green-100 text-green-800">
                  ✅ Activo
                </span>
              ) : (
                <span className="px-3 py-1 text-xs font-medium rounded-full bg-red-100 text-red-800">
                  ❌ Error
                </span>
              )}
            </div>
            <p className="text-gray-600 mb-4">Servidor Node.js + Express</p>
            {healthStatus && (
              <div className="text-sm">
                <p className="text-gray-500">Estado: {healthStatus.status}</p>
                {healthStatus.version && (
                  <p className="text-gray-500">Versión: {healthStatus.version}</p>
                )}
                {healthStatus.message && (
                  <p className="text-gray-500">Mensaje: {healthStatus.message}</p>
                )}
              </div>
            )}
            <div className="mt-4 pt-4 border-t border-gray-100">
              <a
                href={`http://localhost:${BACKEND_PORT}/api/health`}
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs text-blue-500 hover:underline"
              >
                Ver endpoint de salud
              </a>
            </div>
          </div>

          {/* Database Status */}
          <div className="bg-white rounded-xl shadow-lg p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-semibold text-gray-900">Base de Datos</h3>
              <span className="px-3 py-1 text-xs font-medium rounded-full bg-blue-100 text-blue-800">
                🔗 Supabase
              </span>
            </div>
            <p className="text-gray-600 mb-4">PostgreSQL en la nube</p>
            <div className="text-sm text-gray-500">
              <p>• PostgreSQL 15</p>
              <p>• Row Level Security</p>
              <p>• Autenticación integrada</p>
              {supabaseStatus && (
                <p className={`mt-2 ${supabaseStatus.connected ? 'text-green-600' : 'text-yellow-600'}`}>
                  {supabaseStatus.connected ? '✅ Conectado' : '⚠️ Tablas no inicializadas'}
                </p>
              )}
            </div>
            <div className="mt-4 pt-4 border-t border-gray-100">
              <a
                href={import.meta.env.VITE_SUPABASE_URL || '#'}
                target="_blank"
                rel="noopener noreferrer"
                className="text-xs text-blue-500 hover:underline"
              >
                Panel de Supabase
              </a>
            </div>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="bg-gradient-to-r from-blue-500 to-purple-600 rounded-xl shadow-lg p-8 mb-12">
          <div className="flex flex-col md:flex-row items-center justify-between">
            <div className="text-white mb-6 md:mb-0 md:mr-8">
              <h3 className="text-2xl font-bold mb-2">¡Configuración inicial exitosa!</h3>
              <p className="opacity-90">Tu entorno de PartiturasApp está listo para usar</p>
            </div>
            <div className="flex flex-col sm:flex-row gap-4">
              <button
                onClick={() => window.open(`http://localhost:${BACKEND_PORT}/api/health`, '_blank')}
                className="bg-white text-blue-600 hover:bg-gray-100 font-semibold py-3 px-6 rounded-lg shadow transition duration-200 flex items-center justify-center"
              >
                <span className="mr-2">📊</span>
                Ver estado de la API
              </button>
              <button
                onClick={() => {
                  if (supabaseUrl) {
                    window.open(supabaseUrl, '_blank');
                  }
                }}
                className="bg-transparent border-2 border-white text-white hover:bg-white hover:text-blue-600 font-semibold py-3 px-6 rounded-lg transition duration-200 flex items-center justify-center"
              >
                <span className="mr-2">⚙️</span>
                Configurar base de datos
              </button>
            </div>
          </div>
        </div>

        {/* Features */}
        <div className="bg-white rounded-xl shadow-lg p-8">
          <h3 className="text-2xl font-bold text-gray-900 mb-6 text-center">
            Características principales
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: '📤', title: 'Subida de partituras', desc: 'PDF e imágenes' },
              { icon: '🎼', title: 'Creación desde cero', desc: 'Editor interactivo' },
              { icon: '👁️', title: 'Visualización', desc: 'Pentagrama dinámico' },
              { icon: '✏️', title: 'Edición', desc: 'Modifica partituras existentes' },
              { icon: '🤝', title: 'Colaboración', desc: 'Trabajo en equipo' },
              { icon: '📱', title: 'Responsive', desc: 'Funciona en todos los dispositivos' },
            ].map((feature, index) => (
              <div key={index} className="flex items-start space-x-4 p-4 hover:bg-gray-50 rounded-lg">
                <div className="text-3xl">{feature.icon}</div>
                <div>
                  <h4 className="font-semibold text-gray-900">{feature.title}</h4>
                  <p className="text-gray-600 text-sm">{feature.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Next Steps */}
        <div className="mt-12 bg-yellow-50 border-l-4 border-yellow-400 p-6 rounded-lg">
          <div className="flex">
            <div className="flex-shrink-0">
              <span className="text-2xl">🚀</span>
            </div>
            <div className="ml-3">
              <h3 className="text-lg font-medium text-yellow-800">Próximos pasos</h3>
              <div className="mt-2 text-yellow-700">
                <p className="text-sm">Para comenzar a usar PartiturasApp completamente:</p>
                <ul className="list-disc ml-5 mt-2 space-y-1">
                  <li>Ejecuta el script de inicialización de la base de datos</li>
                  <li>Configura la autenticación de usuarios</li>
                  <li>Prueba el editor de partituras</li>
                  <li>Explora las plantillas predefinidas</li>
                </ul>
              </div>
              <div className="mt-4">
                <a
                  href="#"
                  onClick={(e) => {
                    e.preventDefault();
                    console.log('Inicializar BD');
                  }}
                  className="inline-flex items-center text-sm font-medium text-yellow-800 hover:text-yellow-900"
                >
                  Ver documentación completa
                  <span className="ml-1">→</span>
                </a>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-900 text-white mt-12">
        <div className="max-w-7xl mx-auto px-4 py-8">
          <div className="text-center">
            <p className="text-gray-400">
              PartiturasApp © 2024 - Plataforma para la gestión y creación de partituras musicales
            </p>
            <p className="text-gray-500 text-sm mt-2">
              Desarrollado con ❤️ para músicos, compositores y estudiantes
            </p>
            <div className="mt-4 flex justify-center space-x-6">
              <a href="#" className="text-gray-400 hover:text-white">
                GitHub
              </a>
              <a href="#" className="text-gray-400 hover:text-white">
                Documentación
              </a>
              <a href="#" className="text-gray-400 hover:text-white">
                Soporte
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;