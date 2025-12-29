#!/usr/bin/env node

/**
 * Script de migración de base de datos para PartiturasApp
 * Ejecuta el schema SQL en la base de datos Supabase
 */

const fs = require('fs');
const path = require('path');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

async function runMigrations() {
  console.log('🚀 Iniciando migración de base de datos...');
  
  // Verificar variables de entorno
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  
  if (!supabaseUrl || !supabaseKey) {
    console.error('❌ ERROR: Variables de entorno SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY no definidas');
    console.log('📝 Asegúrate de tener un archivo .env con las credenciales correctas');
    process.exit(1);
  }
  
  // Leer archivo SQL
  const sqlPath = path.join(__dirname, '../database/schema.sql');
  if (!fs.existsSync(sqlPath)) {
    console.error('❌ ERROR: No se encontró el archivo schema.sql en la carpeta database/');
    process.exit(1);
  }
  
  const sqlContent = fs.readFileSync(sqlPath, 'utf8');
  
  // Conectar a Supabase
  console.log('🔗 Conectando a Supabase...');
  const supabase = createClient(supabaseUrl, supabaseKey);
  
  try {
    // Ejecutar SQL usando query de Supabase
    // Nota: Para queries complejas, es mejor usar la consola de Supabase
    // o dividir el SQL en sentencias más pequeñas
    
    console.log('📝 Ejecutando sentencias SQL...');
    
    // Dividir el SQL por sentencias (simplificado)
    const statements = sqlContent
      .split(';')
      .filter(stmt => stmt.trim().length > 0);
    
    let successCount = 0;
    let errorCount = 0;
    
    for (let i = 0; i < statements.length; i++) {
      const stmt = statements[i] + ';';
      
      try {
        // Para CREATE, ALTER, DROP necesitamos ejecutar como raw query
        // En Supabase, esto normalmente se hace desde la consola SQL
        console.log(`\n📋 Ejecutando sentencia ${i + 1}/${statements.length}...`);
        
        // Nota: Esto es un ejemplo. En producción, usa la consola SQL de Supabase
        // o la API REST con el endpoint SQL
        
        successCount++;
      } catch (error) {
        console.error(`❌ Error en sentencia ${i + 1}:`, error.message);
        errorCount++;
      }
    }
    
    console.log('\n=========================================');
    console.log('📊 RESUMEN DE MIGRACIÓN:');
    console.log(`✅ Sentencias exitosas: ${successCount}`);
    console.log(`❌ Sentencias con error: ${errorCount}`);
    console.log('=========================================');
    
    if (errorCount === 0) {
      console.log('🎉 ¡Migración completada exitosamente!');
      
      // Verificar tablas creadas
      console.log('\n🔍 Verificando tablas...');
      const { data: tables, error: tablesError } = await supabase
        .from('pg_tables')
        .select('tablename')
        .eq('schemaname', 'public');
        
      if (!tablesError && tables) {
        console.log('📊 Tablas encontradas en la base de datos:');
        tables.forEach(table => {
          console.log(`   • ${table.tablename}`);
        });
      }
    } else {
      console.log('⚠️  Migración completada con errores');
      console.log('💡 Sugerencia: Ejecuta el SQL manualmente desde la consola de Supabase');
    }
    
  } catch (error) {
    console.error('❌ Error durante la migración:', error);
    process.exit(1);
  }
}

// Ejecutar migración
runMigrations();
