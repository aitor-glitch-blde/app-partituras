#!/bin/bash
# check-status.sh - Verificar estado completo del proyecto

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}===========================================${NC}"
echo -e "${BLUE}   🔍 VERIFICACIÓN COMPLETA DEL PROYECTO  ${NC}"
echo -e "${BLUE}===========================================${NC}"

# 1. Verificar Node.js y npm
echo -e "\n${YELLOW}1. Verificando Node.js y npm...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm no está instalado${NC}"
    exit 1
fi

NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
echo -e "${GREEN}✅ Node.js: $NODE_VERSION${NC}"
echo -e "${GREEN}✅ npm: $NPM_VERSION${NC}"

# 2. Verificar estructura del proyecto
echo -e "\n${YELLOW}2. Verificando estructura del proyecto...${NC}"
required_dirs=("frontend" "backend" "scripts" "docs")
required_files=("package.json" ".env.example" "README.md")

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ Directorio $dir encontrado${NC}"
    else
        echo -e "${RED}❌ Directorio $dir no encontrado${NC}"
    fi
done

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅ Archivo $file encontrado${NC}"
    else
        echo -e "${YELLOW}⚠️  Archivo $file no encontrado${NC}"
    fi
done

# 3. Verificar archivo .env
echo -e "\n${YELLOW}3. Verificando archivo .env...${NC}"
if [ -f ".env" ]; then
    echo -e "${GREEN}✅ Archivo .env encontrado${NC}"
    
    # Verificar variables críticas
    source .env 2>/dev/null || echo -e "${YELLOW}⚠️  No se pudo cargar .env${NC}"
    
    required_vars=("NEXT_PUBLIC_SUPABASE_URL" "SUPABASE_SERVICE_ROLE_KEY" "DATABASE_URL")
    
    for var in "${required_vars[@]}"; do
        if [ -n "${!var}" ]; then
            echo -e "${GREEN}✅ Variable $var configurada${NC}"
        else
            echo -e "${RED}❌ Variable $var no configurada${NC}"
        fi
    done
    
    # Mostrar URL de Supabase
    if [ -n "$NEXT_PUBLIC_SUPABASE_URL" ]; then
        echo -e "${BLUE}Supabase URL: $NEXT_PUBLIC_SUPABASE_URL${NC}"
    fi
else
    echo -e "${RED}❌ Archivo .env no encontrado${NC}"
    echo -e "${YELLOW}Ejecuta: cp .env.example .env${NC}"
fi

# 4. Verificar dependencias
echo -e "\n${YELLOW}4. Verificando dependencias...${NC}"

check_package() {
    local dir=$1
    if [ -d "$dir" ] && [ -f "$dir/package.json" ]; then
        if [ -d "$dir/node_modules" ]; then
            echo -e "${GREEN}✅ $dir: Dependencias instaladas${NC}"
            
            # Verificar versiones de dependencias críticas
            if [ "$dir" = "frontend" ]; then
                echo -n "   React: "
                if [ -f "$dir/node_modules/react/package.json" ]; then
                    react_ver=$(cat "$dir/node_modules/react/package.json" | grep '"version"' | head -1 | cut -d'"' -f4)
                    echo -e "${BLUE}$react_ver${NC}"
                else
                    echo -e "${RED}❌ No encontrado${NC}"
                fi
                
                echo -n "   Supabase JS: "
                if [ -f "$dir/node_modules/@supabase/supabase-js/package.json" ]; then
                    supabase_ver=$(cat "$dir/node_modules/@supabase/supabase-js/package.json" | grep '"version"' | head -1 | cut -d'"' -f4)
                    echo -e "${BLUE}$supabase_ver${NC}"
                else
                    echo -e "${RED}❌ No encontrado${NC}"
                fi
            fi
            
            if [ "$dir" = "backend" ]; then
                echo -n "   Express: "
                if [ -f "$dir/node_modules/express/package.json" ]; then
                    express_ver=$(cat "$dir/node_modules/express/package.json" | grep '"version"' | head -1 | cut -d'"' -f4)
                    echo -e "${BLUE}$express_ver${NC}"
                else
                    echo -e "${RED}❌ No encontrado${NC}"
                fi
            fi
            
        else
            echo -e "${RED}❌ $dir: Dependencias NO instaladas${NC}"
            echo -e "${YELLOW}   Ejecuta: cd $dir && npm install${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  $dir: No es un proyecto Node.js válido${NC}"
    fi
}

check_package "frontend"
check_package "backend"

# 5. Verificar conexión a Supabase
echo -e "\n${YELLOW}5. Verificando conexión a Supabase...${NC}"
if [ -n "$NEXT_PUBLIC_SUPABASE_URL" ] && [ -n "$NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY" ]; then
    echo -e "${BLUE}Probando conexión a: $NEXT_PUBLIC_SUPABASE_URL${NC}"
    
    response=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "apikey: $NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY" \
        -H "Authorization: Bearer $NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY" \
        "$NEXT_PUBLIC_SUPABASE_URL/rest/v1/" 2>/dev/null || echo "000")
    
    if [ "$response" = "200" ] || [ "$response" = "401" ]; then
        echo -e "${GREEN}✅ Conexión a Supabase exitosa (HTTP $response)${NC}"
    else
        echo -e "${RED}❌ Error de conexión a Supabase (HTTP $response)${NC}"
        echo -e "${YELLOW}Verifica tus credenciales en .env${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  No se pueden verificar credenciales de Supabase${NC}"
fi

# 6. Verificar scripts
echo -e "\n${YELLOW}6. Verificando scripts...${NC}"
scripts=("start.sh" "scripts/init-db.sh" "scripts/dev.sh")

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo -e "${GREEN}✅ $script: Ejecutable${NC}"
        else
            echo -e "${YELLOW}⚠️  $script: No ejecutable (ejecuta: chmod +x $script)${NC}"
        fi
    else
        echo -e "${RED}❌ $script: No encontrado${NC}"
    fi
done

# 7. Verificar puertos
echo -e "\n${YELLOW}7. Verificando puertos...${NC}"
check_port_in_use() {
    local port=$1
    local service=$2
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; then
        echo -e "${RED}❌ Puerto $port en uso por $service${NC}"
        echo -e "${YELLOW}   Proceso: $(lsof -ti:$port)${NC}"
        return 1
    else
        echo -e "${GREEN}✅ Puerto $port libre para $service${NC}"
        return 0
    fi
}

check_port_in_use 3000 "Frontend"
check_port_in_use 3001 "Backend"

# 8. Resumen
echo -e "\n${BLUE}===========================================${NC}"
echo -e "${BLUE}   📊 RESUMEN DEL ESTADO                  ${NC}"
echo -e "${BLUE}===========================================${NC}"

echo -e "\n${YELLOW}🎯 Para iniciar la aplicación:${NC}"
echo -e "${GREEN}   ./start.sh${NC}"

echo -e "\n${YELLOW}⚙️  Para configurar la base de datos:${NC}"
echo -e "${GREEN}   ./scripts/init-db.sh${NC}"

echo -e "\n${YELLOW}🔧 Para desarrollo:${NC}"
echo -e "${GREEN}   npm run dev${NC} (desde la raíz)"
echo -e "${GREEN}   cd frontend && npm run dev${NC} (solo frontend)"
echo -e "${GREEN}   cd backend && npm run dev${NC} (solo backend)"

echo -e "\n${BLUE}===========================================${NC}"
echo -e "${GREEN}   ✅ VERIFICACIÓN COMPLETADA            ${NC}"
echo -e "${BLUE}===========================================${NC}"