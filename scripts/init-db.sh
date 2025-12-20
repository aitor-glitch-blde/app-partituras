#!/bin/bash
# Script para inicializar la base de datos de PartiturasApp con Supabase

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}   INICIALIZACIÓN BD PARTITURASAPP        ${NC}"
echo -e "${BLUE}===========================================${NC}"

# Verificar si existe archivo .env
if [ ! -f .env ]; then
    echo -e "${RED}❌ Archivo .env no encontrado${NC}"
    echo -e "${YELLOW}Por favor, crea un archivo .env basado en .env.example${NC}"
    exit 1
fi

# Cargar variables del entorno
source .env 2>/dev/null || echo -e "${YELLOW}⚠️  No se pudo cargar .env completamente${NC}"

# Usar variables de tu .env (con diferentes nombres)
SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL:-$VITE_SUPABASE_URL}"
SUPABASE_ANON_KEY="${NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY:-$VITE_SUPABASE_ANON_KEY}"

# Verificar credenciales de Supabase
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_SERVICE_ROLE_KEY" ]; then
    echo -e "${RED}❌ Faltan credenciales de Supabase en .env${NC}"
    echo -e "${YELLOW}Variables encontradas:${NC}"
    echo "NEXT_PUBLIC_SUPABASE_URL: $NEXT_PUBLIC_SUPABASE_URL"
    echo "NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY: $NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY"
    echo "SUPABASE_SERVICE_ROLE_KEY: $SUPABASE_SERVICE_ROLE_KEY"
    echo -e "\n${YELLOW}Asegúrate de tener:${NC}"
    echo "NEXT_PUBLIC_SUPABASE_URL=..."
    echo "SUPABASE_SERVICE_ROLE_KEY=..."
    exit 1
fi

# Extraer información de la URL de Supabase
SUPABASE_PROJECT_ID=$(echo "$SUPABASE_URL" | grep -o 'https://[^.]*' | cut -d'/' -f3 | cut -d'.' -f1)

echo -e "${GREEN}✅ Credenciales de Supabase encontradas${NC}"
echo -e "${BLUE}Proyecto:${NC} $SUPABASE_PROJECT_ID"
echo -e "${BLUE}URL:${NC} $SUPABASE_URL"
echo -e "${BLUE}Anon Key:${NC} ${SUPABASE_ANON_KEY:0:20}..."
echo -e "${BLUE}Service Role Key:${NC} ${SUPABASE_SERVICE_ROLE_KEY:0:20}..."

# Verificar si jq está instalado para parsear JSON
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  Instalando jq para parsear JSON...${NC}"
    sudo apt-get update && sudo apt-get install -y jq 2>/dev/null || \
    brew install jq 2>/dev/null || \
    echo -e "${YELLOW}⚠️  jq no está instalado. Algunas funciones pueden no funcionar.${NC}"
fi

# Mostrar opciones
echo -e "\n${YELLOW}¿Qué acción deseas realizar?${NC}"
echo "1) Ejecutar solo el esquema (recomendado)"
echo "2) Ejecutar esquema + datos iniciales"
echo "3) Solo datos iniciales (esquema ya existe)"
echo "4) Ver estado de la base de datos"
echo "5) Reiniciar completamente (¡CUIDADO!)"
echo "6) Usar Supabase CLI (recomendado si está instalado)"
read -p "Selecciona una opción (1-6): " -n 1 -r
echo

case $REPLY in
    1)
        ACTION="schema"
        ;;
    2)
        ACTION="full"
        ;;
    3)
        ACTION="seed"
        ;;
    4)
        ACTION="status"
        ;;
    5)
        ACTION="reset"
        ;;
    6)
        ACTION="cli"
        ;;
    *)
        echo -e "${RED}❌ Opción inválida${NC}"
        exit 1
        ;;
esac

# Función para ejecutar SQL usando la API de Supabase
execute_sql_api() {
    local sql_file=$1
    local sql_content
    
    # Leer y escapar el contenido SQL
    sql_content=$(cat "$sql_file" | sed ':a;N;$!ba;s/\n/ /g' | sed 's/"/\\"/g')
    
    echo -e "\n${BLUE}📝 Ejecutando: $sql_file${NC}"
    echo -e "${YELLOW}SQL (primeras 200 chars): ${sql_content:0:200}...${NC}"
    
    # Intentar usar el endpoint SQL de Supabase
    response=$(curl -s -X POST \
        -H "apikey: $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Authorization: Bearer $SUPABASE_SERVICE_ROLE_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"$sql_content\"}" \
        "$SUPABASE_URL/rest/v1/rpc/exec_sql" 2>/dev/null || echo "ERROR")
    
    if [[ "$response" == "ERROR" ]] || [[ "$response" == *"error"* ]]; then
        echo -e "${YELLOW}⚠️  API directa no funcionó, intentando método alternativo...${NC}"
        return 1
    else
        echo -e "${GREEN}✅ SQL ejecutado correctamente${NC}"
        return 0
    fi
}

# Función para ejecutar SQL usando psql con DATABASE_URL
execute_sql_psql() {
    local sql_file=$1
    
    if [ -z "$DATABASE_URL" ]; then
        echo -e "${RED}❌ DATABASE_URL no configurada en .env${NC}"
        return 1
    fi
    
    if ! command -v psql &> /dev/null; then
        echo -e "${RED}❌ psql no está instalado${NC}"
        echo -e "${YELLOW}Instala PostgreSQL client o usa otra opción${NC}"
        return 1
    fi
    
    echo -e "\n${BLUE}📝 Ejecutando con psql: $sql_file${NC}"
    
    # Extraer componentes de DATABASE_URL
    DB_HOST=$(echo "$DATABASE_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    DB_PORT=$(echo "$DATABASE_URL" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')
    DB_USER=$(echo "$DATABASE_URL" | sed -n 's/.*\/\/\([^:]*\):.*/\1/p')
    DB_PASS=$(echo "$DATABASE_URL" | sed -n 's/.*\/\/[^:]*:\([^@]*\)@.*/\1/p')
    
    # Ejecutar SQL con psql
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$sql_file"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SQL ejecutado correctamente con psql${NC}"
        return 0
    else
        echo -e "${RED}❌ Error ejecutando SQL con psql${NC}"
        return 1
    fi
}

# Función para usar Supabase CLI
execute_sql_supabase_cli() {
    local sql_file=$1
    
    if ! command -v supabase &> /dev/null; then
        echo -e "${YELLOW}⚠️  Instalando Supabase CLI...${NC}"
        npm install -g supabase
    fi
    
    echo -e "\n${BLUE}📝 Ejecutando con Supabase CLI: $sql_file${NC}"
    
    # Iniciar sesión con Supabase CLI
    echo "$SUPABASE_SERVICE_ROLE_KEY" | supabase login
    
    # Ejecutar SQL
    supabase db push --db-url "$DATABASE_URL" --password "$SUPABASE_SERVICE_ROLE_KEY" || \
    supabase db reset --db-url "$DATABASE_URL" --password "$SUPABASE_SERVICE_ROLE_KEY"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SQL ejecutado correctamente con Supabase CLI${NC}"
        return 0
    else
        echo -e "${RED}❌ Error con Supabase CLI${NC}"
        return 1
    fi
}

# Función para verificar estado
check_status() {
    echo -e "\n${BLUE}📊 Verificando estado de la base de datos...${NC}"
    
    # Verificar conexión a la API REST
    echo -e "${YELLOW}Probando conexión API REST...${NC}"
    response=$(curl -s -X GET \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
        "$SUPABASE_URL/rest/v1/")
    
    if echo "$response" | jq -e . >/dev/null 2>&1; then
        echo -e "${GREEN}✅ API REST funcionando${NC}"
        echo "$response" | jq '. | {tables: .}'
    else
        echo -e "${YELLOW}⚠️  No se pudo conectar a API REST${NC}"
    fi
    
    # Verificar tablas existentes si psql está disponible
    if [ -n "$DATABASE_URL" ] && command -v psql &> /dev/null; then
        echo -e "\n${YELLOW}Tablas en la base de datos:${NC}"
        DB_HOST=$(echo "$DATABASE_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
        DB_PORT=$(echo "$DATABASE_URL" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
        DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')
        DB_USER=$(echo "$DATABASE_URL" | sed -n 's/.*\/\/\([^:]*\):.*/\1/p')
        DB_PASS=$(echo "$DATABASE_URL" | sed -n 's/.*\/\/[^:]*:\([^@]*\)@.*/\1/p')
        
        PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "\dt" 2>/dev/null || \
        echo -e "${YELLOW}⚠️  No se pudo listar tablas${NC}"
    fi
}

# Función principal para ejecutar SQL
execute_sql() {
    local sql_file=$1
    
    if [ ! -f "$sql_file" ]; then
        echo -e "${RED}❌ Archivo SQL no encontrado: $sql_file${NC}"
        return 1
    fi
    
    # Intentar con psql primero (más confiable)
    if [ -n "$DATABASE_URL" ]; then
        execute_sql_psql "$sql_file" && return 0
    fi
    
    # Intentar con Supabase CLI
    execute_sql_supabase_cli "$sql_file" && return 0
    
    # Intentar con API como último recurso
    execute_sql_api "$sql_file" && return 0
    
    echo -e "${RED}❌ No se pudo ejecutar SQL con ningún método${NC}"
    return 1
}

# Procesar la acción seleccionada
case $ACTION in
    "schema")
        echo -e "\n${YELLOW}🚀 Ejecutando esquema de base de datos...${NC}"
        execute_sql "scripts/sql/schema.sql"
        echo -e "${GREEN}✅ Esquema ejecutado correctamente${NC}"
        ;;
    "full")
        echo -e "\n${YELLOW}🚀 Ejecutando esquema + datos iniciales...${NC}"
        execute_sql "scripts/sql/schema.sql"
        sleep 2
        execute_sql "scripts/sql/seed.sql"
        echo -e "${GREEN}✅ Base de datos completa inicializada${NC}"
        ;;
    "seed")
        echo -e "\n${YELLOW}🚀 Insertando datos iniciales...${NC}"
        execute_sql "scripts/sql/seed.sql"
        echo -e "${GREEN}✅ Datos iniciales insertados${NC}"
        ;;
    "status")
        check_status
        ;;
    "reset")
        echo -e "\n${RED}⚠️  ⚠️  ⚠️  ADVERTENCIA ⚠️  ⚠️  ⚠️${NC}"
        echo -e "${RED}Esto eliminará TODOS los datos de la base de datos${NC}"
        read -p "¿Estás seguro? (escribe 'CONFIRMAR' para continuar): " -r
        if [[ $REPLY != "CONFIRMAR" ]]; then
            echo -e "${YELLOW}❌ Operación cancelada${NC}"
            exit 0
        fi
        
        # Crear script de reinicio temporal
        cat > /tmp/reset_db.sql << 'EOF'
-- Eliminar todas las tablas en orden correcto
DROP TABLE IF EXISTS descargas CASCADE;
DROP TABLE IF EXISTS plantillas CASCADE;
DROP TABLE IF EXISTS historial_cambios CASCADE;
DROP TABLE IF EXISTS colaboraciones CASCADE;
DROP TABLE IF EXISTS elementos_musicales CASCADE;
DROP TABLE IF EXISTS partituras CASCADE;
DROP TABLE IF EXISTS usuarios CASCADE;

-- Eliminar vistas
DROP VIEW IF EXISTS vista_dashboard_usuario CASCADE;
DROP VIEW IF EXISTS vista_partituras_publicas CASCADE;

-- Eliminar funciones
DROP FUNCTION IF EXISTS actualizar_fecha_modificacion CASCADE;
DROP FUNCTION IF EXISTS verificar_limite_partituras CASCADE;
EOF
        
        execute_sql "/tmp/reset_db.sql"
        execute_sql "scripts/sql/schema.sql"
        execute_sql "scripts/sql/seed.sql"
        echo -e "${GREEN}✅ Base de datos reiniciada completamente${NC}"
        ;;
    "cli")
        echo -e "\n${YELLOW}🚀 Usando Supabase CLI...${NC}"
        
        # Instalar Supabase CLI si no está instalado
        if ! command -v supabase &> /dev/null; then
            echo -e "${YELLOW}Instalando Supabase CLI...${NC}"
            npm install -g supabase
        fi
        
        # Iniciar sesión
        echo -e "${YELLOW}Iniciando sesión en Supabase...${NC}"
        echo "$SUPABASE_SERVICE_ROLE_KEY" | supabase login
        
        # Conectar y ejecutar
        echo -e "${YELLOW}Conectando al proyecto...${NC}"
        supabase link --project-ref "$SUPABASE_PROJECT_ID"
        
        # Ejecutar esquema
        echo -e "${YELLOW}Ejecutando esquema...${NC}"
        supabase db push
        
        echo -e "${GREEN}✅ Base de datos inicializada con Supabase CLI${NC}"
        ;;
esac

echo -e "\n${BLUE}===========================================${NC}"
echo -e "${GREEN}   OPERACIÓN COMPLETADA                   ${NC}"
echo -e "${BLUE}===========================================${NC}"

# Mostrar URLs útiles
echo -e "\n${YELLOW}📊 URLs de Supabase:${NC}"
echo -e "Dashboard: ${BLUE}https://app.supabase.com/project/$SUPABASE_PROJECT_ID${NC}"
echo -e "API REST: ${BLUE}$SUPABASE_URL/rest/v1/${NC}"

# Mostrar información de conexión
if [ -n "$DATABASE_URL" ]; then
    echo -e "\n${YELLOW}🔗 Información de conexión:${NC}"
    DB_HOST=$(echo "$DATABASE_URL" | sed -n 's/.*@\([^:]*\):.*/\1/p')
    DB_PORT=$(echo "$DATABASE_URL" | sed -n 's/.*:\([0-9]*\)\/.*/\1/p')
    DB_NAME=$(echo "$DATABASE_URL" | sed -n 's/.*\/\([^?]*\).*/\1/p')
    echo -e "Host: ${BLUE}$DB_HOST${NC}"
    echo -e "Puerto: ${BLUE}$DB_PORT${NC}"
    echo -e "Base de datos: ${BLUE}$DB_NAME${NC}"
    
    echo -e "\n${YELLOW}🔧 Comando psql:${NC}"
    echo -e "${BLUE}PGPASSWORD='AfxcXzmASFb' psql -h $DB_HOST -p $DB_PORT -U postgres -d $DB_NAME${NC}"
fi

echo -e "\n${YELLOW}🎯 Para probar la conexión manualmente:${NC}"
echo -e "${BLUE}curl -X GET \\${NC}"
echo -e "${BLUE}  -H 'apikey: $SUPABASE_ANON_KEY' \\${NC}"
echo -e "${BLUE}  -H 'Authorization: Bearer $SUPABASE_ANON_KEY' \\${NC}"
echo -e "${BLUE}  '$SUPABASE_URL/rest/v1/'${NC}"

echo -e "\n${GREEN}✅ Base de datos configurada exitosamente!${NC}"