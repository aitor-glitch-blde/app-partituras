-- ============================================
-- DATOS INICIALES PARA PARTITURASAPP
-- ============================================

-- Insertar plantillas predefinidas
INSERT INTO plantillas (nombre, descripcion, tipo_instrumento, nivel_dificultad, datos_plantilla, es_publica, veces_usada) VALUES
('Pentagrama Vacío', 'Pentagrama básico para comenzar', 'general', 'principiante', 
 '{"compas": "4/4", "tonalidad": "C", "clave": "sol", "tempo": 120}'::jsonb, 
 TRUE, 0),

('Ejercicio de Escalas - Do Mayor', 'Plantilla para practicar escalas mayores', 'piano', 'principiante', 
 '{"compas": "4/4", "tonalidad": "C", "clave": "sol", "elementos": [
   {"tipo": "nota", "nota": "C4", "duracion": "negra"},
   {"tipo": "nota", "nota": "D4", "duracion": "negra"},
   {"tipo": "nota", "nota": "E4", "duracion": "negra"},
   {"tipo": "nota", "nota": "F4", "duracion": "negra"},
   {"tipo": "nota", "nota": "G4", "duracion": "negra"},
   {"tipo": "nota", "nota": "A4", "duracion": "negra"},
   {"tipo": "nota", "nota": "B4", "duracion": "negra"},
   {"tipo": "nota", "nota": "C5", "duracion": "negra"}
 ]}'::jsonb, 
 TRUE, 0),

('Patrón Rítmico Básico', 'Ejercicio de ritmo para principiantes', 'percusion', 'principiante', 
 '{"compas": "4/4", "elementos": [
   {"tipo": "nota", "instrumento": "caja", "duracion": "negra"},
   {"tipo": "silencia", "duracion": "negra"},
   {"tipo": "nota", "instrumento": "caja", "duracion": "negra"},
   {"tipo": "silencia", "duracion": "negra"}
 ]}'::jsonb, 
 TRUE, 0),

('Melodía Simple', 'Melodía básica para iniciación musical', 'flauta', 'principiante', 
 '{"compas": "3/4", "tonalidad": "G", "clave": "sol", "elementos": [
   {"tipo": "nota", "nota": "G4", "duracion": "negra"},
   {"tipo": "nota", "nota": "A4", "duracion": "negra"},
   {"tipo": "nota", "nota": "B4", "duracion": "negra"},
   {"tipo": "nota", "nota": "C5", "duracion": "negra"},
   {"tipo": "nota", "nota": "B4", "duracion": "negra"},
   {"tipo": "nota", "nota": "A4", "duracion": "negra"}
 ]}'::jsonb, 
 TRUE, 0),

('Acordes de Guitarra', 'Progresión básica de acordes', 'guitarra', 'intermedio', 
 '{"compas": "4/4", "tonalidad": "C", "clave": "sol", "elementos": [
   {"tipo": "acorde", "acorde": "C", "posicion": "x32010", "duracion": "blanca"},
   {"tipo": "acorde", "acorde": "G", "posicion": "320003", "duracion": "blanca"},
   {"tipo": "acorde", "acorde": "Am", "posicion": "x02210", "duracion": "blanca"},
   {"tipo": "acorde", "acorde": "F", "posicion": "xx3211", "duracion": "blanca"}
 ]}'::jsonb, 
 TRUE, 0);

-- Insertar usuario administrador de ejemplo (contraseña: Admin123!)
INSERT INTO usuarios (email, nombre, apellido, password_hash, tipo_cuenta, esta_verificado, espacio_disponible_mb) VALUES
('admin@partiturasapp.com', 'Administrador', 'Sistema', 
 crypt('Admin123!', gen_salt('bf')), 'premium', TRUE, 1000);

-- Insertar usuario de prueba gratuito (contraseña: Usuario123!)
INSERT INTO usuarios (email, nombre, apellido, password_hash, tipo_cuenta, esta_verificado) VALUES
('usuario@partiturasapp.com', 'Usuario', 'Demo', 
 crypt('Usuario123!', gen_salt('bf')), 'gratuita', TRUE);

-- Insertar usuario educativo de prueba (contraseña: Educativo123!)
INSERT INTO usuarios (email, nombre, apellido, password_hash, tipo_cuenta, esta_verificado, espacio_disponible_mb) VALUES
('profesor@partiturasapp.com', 'Profesor', 'Música', 
 crypt('Educativo123!', gen_salt('bf')), 'educativa', TRUE, 200);

-- Insertar algunas partituras de ejemplo
INSERT INTO partituras (usuario_id, titulo, descripcion, tipo, compas, tonalidad, bpm, es_publica, datos_musicales) VALUES
((SELECT id FROM usuarios WHERE email = 'usuario@partiturasapp.com'), 
 'Mi primera melodía', 'Una simple melodía en Do Mayor', 'creada', '4/4', 'C', 120, TRUE,
 '{"tempo": 120, "clave": "sol", "notas": [
   {"tiempo": 0, "nota": "C4", "duracion": "negra"},
   {"tiempo": 1, "nota": "D4", "duracion": "negra"},
   {"tiempo": 2, "nota": "E4", "duracion": "negra"},
   {"tiempo": 3, "nota": "F4", "duracion": "negra"}
 ]}'::jsonb),

((SELECT id FROM usuarios WHERE email = 'profesor@partiturasapp.com'),
 'Ejercicio de escalas', 'Escala de Sol Mayor para estudiantes', 'creada', '4/4', 'G', 100, TRUE,
 '{"tempo": 100, "clave": "sol", "notas": [
   {"tiempo": 0, "nota": "G4", "duracion": "corchea"},
   {"tiempo": 0.5, "nota": "A4", "duracion": "corchea"},
   {"tiempo": 1, "nota": "B4", "duracion": "corchea"},
   {"tiempo": 1.5, "nota": "C5", "duracion": "corchea"}
 ]}'::jsonb);

-- Insertar elementos musicales para las partituras
INSERT INTO elementos_musicales (partitura_id, tipo_elemento, tiempo_inicio, tiempo_duracion, orden, atributos) 
SELECT p.id, 'clave', 0, NULL, 1, '{"clave": "sol", "posicion": 2}'::jsonb
FROM partituras p
WHERE p.titulo = 'Mi primera melodía'
UNION ALL
SELECT p.id, 'nota', 0, 1, 2, '{"nota": "C4", "duracion": "negra", "octava": 4}'::jsonb
FROM partituras p
WHERE p.titulo = 'Mi primera melodía'
UNION ALL
SELECT p.id, 'nota', 1, 1, 3, '{"nota": "D4", "duracion": "negra", "octava": 4}'::jsonb
FROM partituras p
WHERE p.titulo = 'Mi primera melodía';

-- Insertar algunas descargas de ejemplo
INSERT INTO descargas (partitura_id, usuario_id, formato, ip_address, user_agent) VALUES
((SELECT id FROM partituras WHERE titulo = 'Mi primera melodía'),
 (SELECT id FROM usuarios WHERE email = 'profesor@partiturasapp.com'),
 'pdf', '192.168.1.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');

-- Insertar una colaboración de ejemplo
INSERT INTO colaboraciones (partitura_id, usuario_id, rol, estado, fecha_aceptacion) VALUES
((SELECT id FROM partituras WHERE titulo = 'Mi primera melodía'),
 (SELECT id FROM usuarios WHERE email = 'profesor@partiturasapp.com'),
 'editor', 'aceptada', NOW());

-- Insertar historial de ejemplo
INSERT INTO historial_cambios (partitura_id, usuario_id, tipo_cambio, descripcion, datos_anteriores, datos_nuevos) VALUES
((SELECT id FROM partituras WHERE titulo = 'Mi primera melodía'),
 (SELECT id FROM usuarios WHERE email = 'usuario@partiturasapp.com'),
 'creacion', 'Partitura creada inicialmente', 
 NULL,
 '{"titulo": "Mi primera melodía", "compas": "4/4", "tonalidad": "C"}'::jsonb);

-- ============================================
-- CONFIGURACIÓN ROW LEVEL SECURITY (RLS)
-- ============================================

-- Habilitar RLS en todas las tablas
ALTER TABLE usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE partituras ENABLE ROW LEVEL SECURITY;
ALTER TABLE elementos_musicales ENABLE ROW LEVEL SECURITY;
ALTER TABLE colaboraciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE historial_cambios ENABLE ROW LEVEL SECURITY;
ALTER TABLE plantillas ENABLE ROW LEVEL SECURITY;
ALTER TABLE descargas ENABLE ROW LEVEL SECURITY;

-- Políticas para usuarios (si se usa autenticación nativa)
CREATE POLICY "Usuarios ven solo su data" ON usuarios
    FOR SELECT USING (auth.uid() = id OR current_user = 'postgres');

CREATE POLICY "Usuarios actualizan solo su data" ON usuarios
    FOR UPDATE USING (auth.uid() = id OR current_user = 'postgres');

-- Políticas para partituras
CREATE POLICY "Ver partituras propias y públicas" ON partituras
    FOR SELECT USING (
        usuario_id = current_setting('app.user_id', true)::uuid OR 
        es_publica = TRUE OR
        current_user = 'postgres'
    );

CREATE POLICY "Insertar partituras propias" ON partituras
    FOR INSERT WITH CHECK (usuario_id = current_setting('app.user_id', true)::uuid);

CREATE POLICY "Actualizar partituras propias" ON partituras
    FOR UPDATE USING (usuario_id = current_setting('app.user_id', true)::uuid OR current_user = 'postgres');

CREATE POLICY "Eliminar partituras propias" ON partituras
    FOR DELETE USING (usuario_id = current_setting('app.user_id', true)::uuid OR current_user = 'postgres');

-- ============================================
-- FIN DE LOS DATOS INICIALES
-- ============================================
