-- Seed: Curso de Introduccion a Python
-- Este curso tiene ejercicios interactivos con Pyodide

-- Insertar el curso (si no existe)
INSERT INTO courses (id, title, description, thumbnail_url, is_published)
VALUES (
  'ba910d93-bf66-4038-8d60-b70df4f6843e',
  'Introduccion a Python',
  'Aprende Python desde cero con ejercicios practicos interactivos. Ideal para principiantes que quieren dar sus primeros pasos en programacion.',
  'https://upload.wikimedia.org/wikipedia/commons/c/c3/Python-logo-notext.svg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  is_published = EXCLUDED.is_published;

-- Insertar el modulo
INSERT INTO modules (id, course_id, title, description, order_index, is_locked)
VALUES (
  'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
  'ba910d93-bf66-4038-8d60-b70df4f6843e',
  'Fundamentos de Python',
  'Variables, operadores, control de flujo, listas y funciones',
  1,
  false
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description;

-- Insertar las lecciones
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required, video_url)
VALUES
  (
    '11111111-1111-1111-1111-111111111111',
    'ba910d93-bf66-4038-8d60-b70df4f6843e',
    'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
    'Variables y Tipos de Datos',
    'Aprende sobre variables, strings, integers, floats y booleans',
    'text',
    1,
    20,
    true,
    'https://www.youtube.com/embed/Z1Yd7upQsXY'
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'ba910d93-bf66-4038-8d60-b70df4f6843e',
    'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
    'Operadores y Expresiones',
    'Operadores aritmeticos, de comparacion y logicos',
    'text',
    2,
    15,
    true,
    'https://www.youtube.com/embed/v5MR5JnKcZI'
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'ba910d93-bf66-4038-8d60-b70df4f6843e',
    'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
    'Estructuras de Control',
    'Condicionales if, elif, else para tomar decisiones',
    'text',
    3,
    20,
    true,
    'https://www.youtube.com/embed/PqFKRqpHrjw'
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'ba910d93-bf66-4038-8d60-b70df4f6843e',
    'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
    'Listas y Bucles',
    'Listas, bucles for y while para iterar',
    'text',
    4,
    25,
    true,
    'https://www.youtube.com/embed/ohCDWZgNIU0'
  ),
  (
    '55555555-5555-5555-5555-555555555555',
    'ba910d93-bf66-4038-8d60-b70df4f6843e',
    'a1b2c3d4-e5f6-4a5b-8c9d-0e1f2a3b4c5d',
    'Funciones',
    'Crear y usar funciones reutilizables',
    'text',
    5,
    25,
    true,
    'https://www.youtube.com/embed/u-OmVr_fT4s'
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  content = EXCLUDED.content,
  video_url = EXCLUDED.video_url;
