-- ============================================
-- CONFIGURACIÓN INICIAL DE LA BASE DE DATOS
-- PartiturasApp - Sistema de Gestión de Partituras
-- Compatible con Supabase
-- ============================================

-- Habilitar extensiones necesarias (Supabase ya las tiene habilitadas)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- Ya habilitado en Supabase
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto"; -- Ya habilitado en Supabase

-- ============================================
-- TABLA: usuarios
-- Almacena la información de los usuarios registrados
-- ============================================
CREATE TABLE IF NOT EXISTS usuarios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100),
    password_hash VARCHAR(255) NOT NULL,
    tipo_cuenta VARCHAR(20) DEFAULT 'gratuita' CHECK (tipo_cuenta IN ('gratuita', 'premium', 'educativa')),
    fecha_registro TIMESTAMPTZ DEFAULT NOW(),
    ultimo_acceso TIMESTAMPTZ,
    espacio_disponible_mb INTEGER DEFAULT 50, -- 50MB para cuentas gratuitas
    esta_verificado BOOLEAN DEFAULT FALSE,
    configuracion JSONB DEFAULT '{"tema": "claro", "idioma": "es", "notificaciones": true}'::jsonb,
    CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- ============================================
-- TABLA: partituras
-- Almacena las partituras creadas/subidas por usuarios
-- ============================================
CREATE TABLE IF NOT EXISTS partituras (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    tipo VARCHAR(20) DEFAULT 'creada' CHECK (tipo IN ('subida', 'creada')),
    formato_original VARCHAR(10),
    ruta_archivo VARCHAR(500),
    datos_musicales JSONB, -- Almacena notas, tempo, compás, etc. en formato JSON
    duracion_segundos INTEGER,
    compas VARCHAR(10) DEFAULT '4/4',
    tonalidad VARCHAR(10),
    bpm INTEGER DEFAULT 120,
    es_publica BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_modificacion TIMESTAMPTZ DEFAULT NOW(),
    tamanio_bytes INTEGER,
    etiquetas TEXT[],
    CONSTRAINT max_titulo_length CHECK (LENGTH(titulo) >= 3 AND LENGTH(titulo) <= 200)
);

-- ============================================
-- TABLA: elementos_musicales
-- Elementos individuales dentro de una partitura
-- ============================================
CREATE TABLE IF NOT EXISTS elementos_musicales (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    tipo_elemento VARCHAR(30) NOT NULL CHECK (tipo_elemento IN ('nota', 'silencia', 'compas', 'clave', 'armadura')),
    tiempo_inicio FLOAT, -- En segundos
    tiempo_duracion FLOAT, -- En segundos
    posicion_x INTEGER,
    posicion_y INTEGER,
    atributos JSONB, -- {nota: "C4", duracion: "negra", octava: 4, alteracion: null}
    orden INTEGER
);

-- ============================================
-- TABLA: colaboraciones
-- Permite colaboración en partituras
-- ============================================
CREATE TABLE IF NOT EXISTS colaboraciones (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    rol VARCHAR(20) DEFAULT 'lector' CHECK (rol IN ('lector', 'editor', 'propietario')),
    fecha_invitacion TIMESTAMPTZ DEFAULT NOW(),
    fecha_aceptacion TIMESTAMPTZ,
    estado VARCHAR(20) DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'aceptada', 'rechazada', 'expirada'))
);

-- ============================================
-- TABLA: historial_cambios
-- Registra cambios en partituras para control de versiones
-- ============================================
CREATE TABLE IF NOT EXISTS historial_cambios (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    tipo_cambio VARCHAR(50) NOT NULL,
    descripcion TEXT,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    fecha_cambio TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET
);

-- ============================================
-- TABLA: plantillas
-- Plantillas predefinidas para crear partituras
-- ============================================
CREATE TABLE IF NOT EXISTS plantillas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo_instrumento VARCHAR(50),
    nivel_dificultad VARCHAR(20) CHECK (nivel_dificultad IN ('principiante', 'intermedio', 'avanzado')),
    datos_plantilla JSONB NOT NULL,
    es_publica BOOLEAN DEFAULT TRUE,
    veces_usada INTEGER DEFAULT 0,
    creador_id UUID REFERENCES usuarios(id) ON DELETE SET NULL
);

-- ============================================
-- TABLA: descargas
-- Registro de descargas de partituras
-- ============================================
CREATE TABLE IF NOT EXISTS descargas (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    partitura_id UUID NOT NULL REFERENCES partituras(id) ON DELETE CASCADE,
    usuario_id UUID REFERENCES usuarios(id) ON DELETE SET NULL,
    formato VARCHAR(10) NOT NULL CHECK (formato IN ('pdf', 'midi', 'musicxml', 'png')),
    fecha_descarga TIMESTAMPTZ DEFAULT NOW(),
    ip_address INET,
    user_agent TEXT
);

-- ============================================
-- ÍNDICES PARA MEJOR PERFORMANCE
-- ============================================

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_partituras_usuario ON partituras(usuario_id);
CREATE INDEX IF NOT EXISTS idx_partituras_fecha ON partituras(fecha_creacion DESC);
CREATE INDEX IF NOT EXISTS idx_partituras_publicas ON partituras(es_publica) WHERE es_publica = TRUE;
CREATE INDEX IF NOT EXISTS idx_partituras_titulo ON partituras USING gin(to_tsvector('spanish', titulo));

CREATE INDEX IF NOT EXISTS idx_elementos_partitura ON elementos_musicales(partitura_id);
CREATE INDEX IF NOT EXISTS idx_colaboraciones_partitura ON colaboraciones(partitura_id);
CREATE INDEX IF NOT EXISTS idx_colaboraciones_usuario ON colaboraciones(usuario_id);

CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_tipo_cuenta ON usuarios(tipo_cuenta);

-- ============================================
-- FUNCIONES Y TRIGGERS
-- ============================================

-- Función para actualizar fecha_modificacion automáticamente
CREATE OR REPLACE FUNCTION actualizar_fecha_modificacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_modificacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para partituras
CREATE OR REPLACE TRIGGER trigger_actualizar_fecha_partitura
    BEFORE UPDATE ON partituras
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_fecha_modificacion();

-- Función para verificar límite de partituras gratuitas
CREATE OR REPLACE FUNCTION verificar_limite_partituras()
RETURNS TRIGGER AS $$
DECLARE
    cuenta_tipo VARCHAR;
    conteo_partituras INTEGER;
    limite_partituras INTEGER;
BEGIN
    -- Obtener tipo de cuenta del usuario
    SELECT tipo_cuenta INTO cuenta_tipo
    FROM usuarios WHERE id = NEW.usuario_id;
    
    -- Definir límites según tipo de cuenta
    IF cuenta_tipo = 'gratuita' THEN
        limite_partituras := 10; -- 5 subidas + 5 creadas
    ELSIF cuenta_tipo = 'premium' THEN
        limite_partituras := 1000; -- Sin límite práctico
    ELSIF cuenta_tipo = 'educativa' THEN
        limite_partituras := 100;
    ELSE
        limite_partituras := 10;
    END IF;
    
    -- Contar partituras existentes del usuario
    SELECT COUNT(*) INTO conteo_partituras
    FROM partituras
    WHERE usuario_id = NEW.usuario_id;
    
    -- Verificar límite
    IF conteo_partituras >= limite_partituras THEN
        RAISE EXCEPTION 'Límite de partituras alcanzado para tu tipo de cuenta (%)', cuenta_tipo;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para verificar límite al insertar partituras
CREATE OR REPLACE TRIGGER trigger_verificar_limite_partituras
    BEFORE INSERT ON partituras
    FOR EACH ROW
    EXECUTE FUNCTION verificar_limite_partituras();

-- ============================================
-- VISTAS ÚTILES
-- ============================================

-- Vista para dashboard de usuario
CREATE OR REPLACE VIEW vista_dashboard_usuario AS
SELECT 
    u.id as usuario_id,
    u.nombre,
    u.email,
    u.tipo_cuenta,
    u.espacio_disponible_mb,
    COUNT(p.id) as total_partituras,
    COUNT(CASE WHEN p.tipo = 'creada' THEN 1 END) as partituras_creadas,
    COUNT(CASE WHEN p.tipo = 'subida' THEN 1 END) as partituras_subidas,
    COALESCE(SUM(p.tamanio_bytes), 0) as espacio_usado_bytes,
    MAX(p.fecha_creacion) as ultima_partitura_fecha
FROM usuarios u
LEFT JOIN partituras p ON u.id = p.usuario_id
GROUP BY u.id, u.nombre, u.email, u.tipo_cuenta, u.espacio_disponible_mb;

-- Vista para partituras públicas con información del creador
CREATE OR REPLACE VIEW vista_partituras_publicas AS
SELECT 
    p.*,
    u.nombre as creador_nombre,
    u.email as creador_email,
    COUNT(d.id) as total_descargas
FROM partituras p
JOIN usuarios u ON p.usuario_id = u.id
LEFT JOIN descargas d ON p.id = d.partitura_id
WHERE p.es_publica = TRUE
GROUP BY p.id, u.id;

-- ============================================
-- COMENTARIOS DE DOCUMENTACIÓN
-- ============================================

COMMENT ON TABLE usuarios IS 'Tabla principal de usuarios del sistema PartiturasApp';
COMMENT ON TABLE partituras IS 'Almacena todas las partituras creadas o subidas por usuarios';
COMMENT ON TABLE elementos_musicales IS 'Elementos individuales que componen una partitura';
COMMENT ON TABLE colaboraciones IS 'Registra colaboraciones entre usuarios en partituras';
COMMENT ON TABLE historial_cambios IS 'Historial de cambios para control de versiones';
COMMENT ON TABLE plantillas IS 'Plantillas predefinidas para facilitar la creación de partituras';
COMMENT ON TABLE descargas IS 'Registro de descargas de partituras en diferentes formatos';

-- ============================================
-- FIN DEL ESQUEMA
-- ============================================