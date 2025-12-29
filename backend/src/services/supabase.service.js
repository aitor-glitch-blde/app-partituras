const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

// Configurar cliente de Supabase
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ ERROR: SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY no definidos en .env');
  console.error('📋 Verifica que tu archivo .env tenga las variables correctas');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

// Verificar conexión
supabase.from('usuarios').select('count', { count: 'exact', head: true })
  .then(({ error }) => {
    if (error) {
      console.error('❌ Error conectando a Supabase:', error.message);
      console.error('💡 Verifica:');
      console.error('   1. Tu conexión a internet');
      console.error('   2. Las credenciales en .env');
      console.error('   3. Que el proyecto Supabase esté activo');
    } else {
      console.log('✅ Conectado a Supabase correctamente');
    }
  })
  .catch(err => {
    console.error('❌ Error inesperado conectando a Supabase:', err);
  });

module.exports = supabase;
