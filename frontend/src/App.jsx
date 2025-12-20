import React, { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import './App.css';

// Inicializar Supabase
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || import.meta.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || import.meta.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY;

const supabase = supabaseUrl && supabaseAnonKey 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

function App() {
  const [health, setHealth] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchHealth();
  }, []);

  const fetchHealth = async () => {
    try {
      const response = await fetch('http://localhost:3001/api/health');
      const data = await response.json();
      setHealth(data);
    } catch (err) {
      setError('No se pudo conectar al backend');
      console.error('Error:', err);
    } finally {
      setLoading(false);
    }
  };

  const testSupabase = async () => {
    if (!supabase) {
      alert('Supabase no está configurado');
      return;
    }
    
    try {
      const { data, error } = await supabase.from('usuarios').select('*').limit(1);
      if (error) throw error;
      alert(`Supabase conectado. ${data?.length || 0} usuarios encontrados`);
    } catch (err) {
      alert(`Error con Supabase: ${err.message}`);
    }
  };

  return (
    <div className="App">
      <header className="bg-primary-600 text-white p-6 shadow-lg">
        <h1 className="text-4xl font-bold text-center">
          🎵 PartiturasApp
        </h1>
        <p className="text-center text-primary-100 mt-2">
          Plataforma para la gestión y creación de partituras musicales
        </p>
      </header>

      <main className="max-w-6xl mx-auto p-6">
        {/* Panel de estado */}
        <div className="bg-white rounded-xl shadow-lg p-6 mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">📊 Estado del Sistema</h2>
          
          {loading ? (
            <div className="flex items-center justify-center p-8">
              <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600"></div>
              <span className="ml-4 text-gray-600">Cargando...</span>
            </div>
          ) : error ? (
            <div className="bg-red-50 border border-red-200 rounded-lg p-4">
              <p className="text-red-700">❌ {error}</p>
            </div>
          ) : health ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="bg-gray-50 p-4 rounded-lg">
                <h3 className="font-semibold text-gray-700 mb-2">Backend API</h3>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Estado:</span>
                    <span className={`font-semibold ${health.status === 'ok' ? 'text-green-600' : 'text-red-600'}`}>
                      {health.status === 'ok' ? '✅ Conectado' : '❌ Error'}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>Puerto:</span>
                    <span className="font-mono">{health.port}</span>
                  </div>
                  <div className="flex justify-between">
                    <span>Versión:</span>
                    <span>{health.version}</span>
                  </div>
                </div>
              </div>

              <div className="bg-gray-50 p-4 rounded-lg">
                <h3 className="font-semibold text-gray-700 mb-2">Supabase</h3>
                <div className="space-y-2">
                  <div className="flex justify-between">
                    <span>Configuración:</span>
                    <span className={health.supabase.configured ? 'text-green-600' : 'text-yellow-600'}>
                      {health.supabase.configured ? '✅ Configurado' : '⚠️ Parcial'}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>URL:</span>
                    <span className={health.supabase.url.includes('✅') ? 'text-green-600' : 'text-red-600'}>
                      {health.supabase.url}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span>Claves:</span>
                    <span className={health.supabase.hasAnonKey && health.supabase.hasServiceRoleKey ? 'text-green-600' : 'text-yellow-600'}>
                      {health.supabase.hasAnonKey && health.supabase.hasServiceRoleKey ? '✅ Ambas' : '⚠️ Faltan'}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          ) : null}
        </div>

        {/* Panel de acciones */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <button
            onClick={fetchHealth}
            className="bg-primary-500 hover:bg-primary-600 text-white font-semibold py-3 px-6 rounded-lg shadow transition duration-200 flex items-center justify-center"
          >
            🔄 Actualizar Estado
          </button>
          
          <button
            onClick={testSupabase}
            className="bg-green-500 hover:bg-green-600 text-white font-semibold py-3 px-6 rounded-lg shadow transition duration-200 flex items-center justify-center"
            disabled={!supabase}
          >
            🗄️ Probar Supabase
          </button>
          
          <a
            href="http://localhost:3001/api/health"
            target="_blank"
            rel="noopener noreferrer"
            className="bg-blue-500 hover:bg-blue-600 text-white font-semibold py-3 px-6 rounded-lg shadow transition duration-200 flex items-center justify-center"
          >
            🔗 Ver API JSON
          </a>
        </div>

        {/* Información de características */}
        <div className="bg-gradient-to-r from-primary-50 to-blue-50 rounded-xl shadow-lg p-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-6">✨ Características de PartiturasApp</h2>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[
              { icon: '🎼', title: 'Crear Partituras', desc: 'Editor visual para componer música' },
              { icon: '📤', title: 'Subir Archivos', desc: 'PDF e imágenes de partituras existentes' },
              { icon: '👁️', title: 'Visualización', desc: 'Pentagrama interactivo en tiempo real' },
              { icon: '✏️', title: 'Edición', desc: 'Modificar partituras creadas' },
              { icon: '🤝', title: 'Colaboración', desc: 'Trabajar en equipo en partituras' },
              { icon: '📱', title: 'Responsive', desc: 'Funciona en móviles y desktop' },
            ].map((feature, index) => (
              <div key={index} className="bg-white p-5 rounded-lg shadow-sm border border-gray-100">
                <div className="text-3xl mb-3">{feature.icon}</div>
                <h3 className="font-bold text-gray-800 mb-2">{feature.title}</h3>
                <p className="text-gray-600">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Panel de configuración */}
        <div className="mt-8 bg-yellow-50 border border-yellow-200 rounded-lg p-6">
          <h3 className="text-lg font-bold text-yellow-800 mb-3">⚙️ Configuración Requerida</h3>
          <ul className="space-y-2 text-yellow-700">
            <li className="flex items-center">
              {health?.supabase.configured ? '✅' : '⚠️'}
              <span className="ml-2">Configurar Supabase en <code className="bg-yellow-100 px-2 py-1 rounded">.env</code></span>
            </li>
            <li className="flex items-center">
              {health?.database.url?.includes('✅') ? '✅' : '⚠️'}
              <span className="ml-2">Inicializar base de datos con <code className="bg-yellow-100 px-2 py-1 rounded">./scripts/init-db.sh</code></span>
            </li>
            <li className="flex items-center">
              ✅
              <span className="ml-2">Backend funcionando en puerto {PORT || 3001}</span>
            </li>
          </ul>
        </div>
      </main>

      <footer className="bg-gray-800 text-white p-6 mt-12">
        <div className="max-w-6xl mx-auto text-center">
          <p className="mb-2">🎵 PartiturasApp v1.0.0</p>
          <p className="text-gray-400 text-sm">
            Plataforma para la gestión y creación de partituras musicales
          </p>
          <div className="mt-4 flex justify-center space-x-4">
            <a href="http://localhost:3001/api/health" className="text-blue-300 hover:text-blue-100">
              API Status
            </a>
            <a href="https://qroeyukbrangbqlaxdnl.supabase.co" className="text-blue-300 hover:text-blue-100">
              Supabase
            </a>
            <a href="http://localhost:3001/api/docs" className="text-blue-300 hover:text-blue-100">
              Documentación
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}

export default App;