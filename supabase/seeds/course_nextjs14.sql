-- ============================================
-- CURSO: Introducción a Next.js 14
-- Seed completo para EduPlatform
-- ============================================

-- Limpiar datos previos del curso (si existe)
DELETE FROM quiz_questions WHERE quiz_id IN (
  SELECT id FROM quizzes WHERE lesson_id IN (
    SELECT id FROM lessons WHERE course_id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890'
  )
);
DELETE FROM quizzes WHERE lesson_id IN (
  SELECT id FROM lessons WHERE course_id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890'
);
DELETE FROM assignments WHERE lesson_id IN (
  SELECT id FROM lessons WHERE course_id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890'
);
DELETE FROM resources WHERE lesson_id IN (
  SELECT id FROM lessons WHERE course_id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890'
);
DELETE FROM lessons WHERE course_id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890';
DELETE FROM modules WHERE course_id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890';
DELETE FROM courses WHERE id = 'a1b2c3d4-e5f6-4890-abcd-ef1234567890';

-- ============================================
-- CURSO PRINCIPAL
-- ============================================
INSERT INTO courses (id, title, description, instructor_id, thumbnail_url, is_published, created_at)
VALUES (
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Introducción a Next.js 14',
  'Domina Next.js 14 con App Router, Server Components y patrones de producción. Aprende a construir aplicaciones full-stack modernas con autenticación, base de datos y optimizaciones de rendimiento. Curso práctico con proyectos reales.',
  (SELECT id FROM profiles WHERE role = 'instructor' LIMIT 1),
  '/images/courses/nextjs-14-cover.jpg',
  true,
  NOW()
);

-- ============================================
-- MÓDULO 1: Fundamentos de Next.js 14
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, created_at)
VALUES (
  '11111111-1111-4111-8111-111111111111',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Fundamentos de Next.js 14',
  'Entiende la arquitectura y diferencias clave con React tradicional. Aprende por qué Next.js es el framework preferido para producción.',
  1,
  false,
  NOW()
);

-- Lecciones del Módulo 1
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b1111111-0001-4001-8001-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '11111111-1111-4111-8111-111111111111',
 '¿Por qué Next.js? El problema que resuelve',
 'Ver archivo: content/courses/nextjs-14/module-01/lesson-01.md',
 'text', 1, true, NOW()),

('b1111111-0001-4001-8001-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '11111111-1111-4111-8111-111111111111',
 'Arquitectura del App Router',
 'Ver archivo: content/courses/nextjs-14/module-01/lesson-02.md',
 'text', 2, true, NOW()),

('b1111111-0001-4001-8001-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '11111111-1111-4111-8111-111111111111',
 'Setup del entorno de desarrollo',
 'Ver archivo: content/courses/nextjs-14/module-01/lesson-03.md',
 'video', 3, true, NOW()),

('b1111111-0001-4001-8001-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '11111111-1111-4111-8111-111111111111',
 'Tu primera página',
 'Ver archivo: content/courses/nextjs-14/module-01/lesson-04.md',
 'text', 4, true, NOW()),

('b1111111-0001-4001-8001-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '11111111-1111-4111-8111-111111111111',
 'Quiz: Fundamentos de Next.js',
 'Evaluación de conocimientos del Módulo 1',
 'quiz', 5, true, NOW());

-- ============================================
-- MÓDULO 2: Sistema de Routing
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '22222222-2222-4222-8222-222222222222',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Sistema de Routing',
  'Domina el sistema de rutas file-based de Next.js. Aprende rutas dinámicas, layouts anidados y patrones avanzados.',
  2,
  false,
  '11111111-1111-4111-8111-111111111111',
  NOW()
);

-- Lecciones del Módulo 2
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b2222222-0002-4002-8002-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '22222222-2222-4222-8222-222222222222',
 'Rutas estáticas y dinámicas',
 'Ver archivo: content/courses/nextjs-14/module-02/lesson-01.md',
 'text', 1, true, NOW()),

('b2222222-0002-4002-8002-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '22222222-2222-4222-8222-222222222222',
 'Layouts anidados y templates',
 'Ver archivo: content/courses/nextjs-14/module-02/lesson-02.md',
 'text', 2, true, NOW()),

('b2222222-0002-4002-8002-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '22222222-2222-4222-8222-222222222222',
 'Loading, Error y Not Found',
 'Ver archivo: content/courses/nextjs-14/module-02/lesson-03.md',
 'text', 3, true, NOW()),

('b2222222-0002-4002-8002-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '22222222-2222-4222-8222-222222222222',
 'Parallel Routes e Intercepting Routes',
 'Ver archivo: content/courses/nextjs-14/module-02/lesson-04.md',
 'text', 4, true, NOW()),

('b2222222-0002-4002-8002-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '22222222-2222-4222-8222-222222222222',
 'Navegación y Link component',
 'Ver archivo: content/courses/nextjs-14/module-02/lesson-05.md',
 'video', 5, true, NOW()),

('b2222222-0002-4002-8002-000000000006', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '22222222-2222-4222-8222-222222222222',
 'Quiz: Sistema de Routing',
 'Evaluación de conocimientos del Módulo 2',
 'quiz', 6, true, NOW());

-- ============================================
-- MÓDULO 3: Server Components y Data Fetching
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '33333333-3333-4333-8333-333333333333',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Server Components y Data Fetching',
  'Entiende el modelo mental de React Server Components y domina los patrones de fetching de datos.',
  3,
  false,
  '22222222-2222-4222-8222-222222222222',
  NOW()
);

-- Lecciones del Módulo 3
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b3333333-0003-4003-8003-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '33333333-3333-4333-8333-333333333333',
 'Server vs Client Components',
 'Ver archivo: content/courses/nextjs-14/module-03/lesson-01.md',
 'text', 1, true, NOW()),

('b3333333-0003-4003-8003-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '33333333-3333-4333-8333-333333333333',
 'Fetching en Server Components',
 'Ver archivo: content/courses/nextjs-14/module-03/lesson-02.md',
 'text', 2, true, NOW()),

('b3333333-0003-4003-8003-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '33333333-3333-4333-8333-333333333333',
 'Caching y Revalidación',
 'Ver archivo: content/courses/nextjs-14/module-03/lesson-03.md',
 'text', 3, true, NOW()),

('b3333333-0003-4003-8003-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '33333333-3333-4333-8333-333333333333',
 'Patrones de composición',
 'Ver archivo: content/courses/nextjs-14/module-03/lesson-04.md',
 'text', 4, true, NOW()),

('b3333333-0003-4003-8003-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '33333333-3333-4333-8333-333333333333',
 'Streaming y Suspense',
 'Ver archivo: content/courses/nextjs-14/module-03/lesson-05.md',
 'video', 5, true, NOW()),

('b3333333-0003-4003-8003-000000000006', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '33333333-3333-4333-8333-333333333333',
 'Quiz: Server Components y Data Fetching',
 'Evaluación de conocimientos del Módulo 3',
 'quiz', 6, true, NOW());

-- ============================================
-- MÓDULO 4: Server Actions y Mutaciones
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '44444444-4444-4444-8444-444444444444',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Server Actions y Mutaciones',
  'Implementa mutaciones sin API routes tradicionales. Domina formularios, validación y optimistic updates.',
  4,
  false,
  '33333333-3333-4333-8333-333333333333',
  NOW()
);

-- Lecciones del Módulo 4
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b4444444-0004-4004-8004-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '44444444-4444-4444-8444-444444444444',
 'Introducción a Server Actions',
 'Ver archivo: content/courses/nextjs-14/module-04/lesson-01.md',
 'text', 1, true, NOW()),

('b4444444-0004-4004-8004-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '44444444-4444-4444-8444-444444444444',
 'Validación y manejo de errores',
 'Ver archivo: content/courses/nextjs-14/module-04/lesson-02.md',
 'text', 2, true, NOW()),

('b4444444-0004-4004-8004-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '44444444-4444-4444-8444-444444444444',
 'Optimistic Updates',
 'Ver archivo: content/courses/nextjs-14/module-04/lesson-03.md',
 'text', 3, true, NOW()),

('b4444444-0004-4004-8004-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '44444444-4444-4444-8444-444444444444',
 'Revalidación después de mutaciones',
 'Ver archivo: content/courses/nextjs-14/module-04/lesson-04.md',
 'text', 4, true, NOW()),

('b4444444-0004-4004-8004-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '44444444-4444-4444-8444-444444444444',
 'Assignment: CRUD completo con Server Actions',
 'Proyecto práctico del Módulo 4',
 'assignment', 5, true, NOW());

-- ============================================
-- MÓDULO 5: Autenticación y Middleware
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '55555555-5555-4555-8555-555555555555',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Autenticación y Middleware',
  'Implementa autenticación y protección de rutas. Aprende JWT, sessions y middleware de Next.js.',
  5,
  false,
  '44444444-4444-4444-8444-444444444444',
  NOW()
);

-- Lecciones del Módulo 5
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b5555555-0005-4005-8005-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '55555555-5555-4555-8555-555555555555',
 'Estrategias de autenticación',
 'Ver archivo: content/courses/nextjs-14/module-05/lesson-01.md',
 'text', 1, true, NOW()),

('b5555555-0005-4005-8005-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '55555555-5555-4555-8555-555555555555',
 'Implementación con NextAuth.js / Auth.js',
 'Ver archivo: content/courses/nextjs-14/module-05/lesson-02.md',
 'video', 2, true, NOW()),

('b5555555-0005-4005-8005-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '55555555-5555-4555-8555-555555555555',
 'Middleware para protección de rutas',
 'Ver archivo: content/courses/nextjs-14/module-05/lesson-03.md',
 'text', 3, true, NOW()),

('b5555555-0005-4005-8005-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '55555555-5555-4555-8555-555555555555',
 'Roles y permisos',
 'Ver archivo: content/courses/nextjs-14/module-05/lesson-04.md',
 'text', 4, true, NOW()),

('b5555555-0005-4005-8005-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '55555555-5555-4555-8555-555555555555',
 'Quiz: Autenticación y Seguridad',
 'Evaluación de conocimientos del Módulo 5',
 'quiz', 5, true, NOW());

-- ============================================
-- MÓDULO 6: Base de Datos y ORM
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '66666666-6666-4666-8666-666666666666',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Base de Datos y ORM',
  'Conecta Next.js con bases de datos en producción. Aprende Prisma, Drizzle y patrones de acceso a datos.',
  6,
  false,
  '55555555-5555-4555-8555-555555555555',
  NOW()
);

-- Lecciones del Módulo 6
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b6666666-0006-4006-8006-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '66666666-6666-4666-8666-666666666666',
 'Opciones de base de datos',
 'Ver archivo: content/courses/nextjs-14/module-06/lesson-01.md',
 'text', 1, true, NOW()),

('b6666666-0006-4006-8006-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '66666666-6666-4666-8666-666666666666',
 'Prisma vs Drizzle',
 'Ver archivo: content/courses/nextjs-14/module-06/lesson-02.md',
 'text', 2, true, NOW()),

('b6666666-0006-4006-8006-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '66666666-6666-4666-8666-666666666666',
 'Queries en Server Components',
 'Ver archivo: content/courses/nextjs-14/module-06/lesson-03.md',
 'text', 3, true, NOW()),

('b6666666-0006-4006-8006-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '66666666-6666-4666-8666-666666666666',
 'Transacciones y manejo de errores',
 'Ver archivo: content/courses/nextjs-14/module-06/lesson-04.md',
 'text', 4, true, NOW()),

('b6666666-0006-4006-8006-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '66666666-6666-4666-8666-666666666666',
 'Assignment: Modelo de datos con Prisma',
 'Proyecto práctico del Módulo 6',
 'assignment', 5, true, NOW());

-- ============================================
-- MÓDULO 7: Estilos y UI
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '77777777-7777-4777-8777-777777777777',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Estilos y UI',
  'Implementa sistemas de diseño escalables. Aprende Tailwind, shadcn/ui y optimización de assets.',
  7,
  false,
  '66666666-6666-4666-8666-666666666666',
  NOW()
);

-- Lecciones del Módulo 7
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b7777777-0007-4007-8007-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '77777777-7777-4777-8777-777777777777',
 'CSS Modules vs Tailwind',
 'Ver archivo: content/courses/nextjs-14/module-07/lesson-01.md',
 'text', 1, true, NOW()),

('b7777777-0007-4007-8007-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '77777777-7777-4777-8777-777777777777',
 'Componentes UI: shadcn/ui',
 'Ver archivo: content/courses/nextjs-14/module-07/lesson-02.md',
 'video', 2, true, NOW()),

('b7777777-0007-4007-8007-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '77777777-7777-4777-8777-777777777777',
 'Fonts y optimización de assets',
 'Ver archivo: content/courses/nextjs-14/module-07/lesson-03.md',
 'text', 3, true, NOW()),

('b7777777-0007-4007-8007-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '77777777-7777-4777-8777-777777777777',
 'Animaciones con Framer Motion',
 'Ver archivo: content/courses/nextjs-14/module-07/lesson-04.md',
 'text', 4, true, NOW()),

('b7777777-0007-4007-8007-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '77777777-7777-4777-8777-777777777777',
 'Quiz: Estilos y Optimización de UI',
 'Evaluación de conocimientos del Módulo 7',
 'quiz', 5, true, NOW());

-- ============================================
-- MÓDULO 8: Testing y Calidad
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '88888888-8888-4888-8888-888888888888',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Testing y Calidad',
  'Establece una estrategia de testing robusta para Next.js. Aprende Vitest, Playwright y mejores prácticas.',
  8,
  false,
  '77777777-7777-4777-8777-777777777777',
  NOW()
);

-- Lecciones del Módulo 8
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b8888888-0008-4008-8008-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '88888888-8888-4888-8888-888888888888',
 'Testing de componentes con Vitest',
 'Ver archivo: content/courses/nextjs-14/module-08/lesson-01.md',
 'text', 1, true, NOW()),

('b8888888-0008-4008-8008-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '88888888-8888-4888-8888-888888888888',
 'Testing de Server Actions',
 'Ver archivo: content/courses/nextjs-14/module-08/lesson-02.md',
 'text', 2, true, NOW()),

('b8888888-0008-4008-8008-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '88888888-8888-4888-8888-888888888888',
 'E2E con Playwright',
 'Ver archivo: content/courses/nextjs-14/module-08/lesson-03.md',
 'video', 3, true, NOW()),

('b8888888-0008-4008-8008-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '88888888-8888-4888-8888-888888888888',
 'Type checking y linting',
 'Ver archivo: content/courses/nextjs-14/module-08/lesson-04.md',
 'text', 4, true, NOW());

-- ============================================
-- MÓDULO 9: Optimización y Performance
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  '99999999-9999-4999-8999-999999999999',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Optimización y Performance',
  'Aplica técnicas avanzadas de optimización. Domina Core Web Vitals, bundle analysis y edge runtime.',
  9,
  false,
  '88888888-8888-4888-8888-888888888888',
  NOW()
);

-- Lecciones del Módulo 9
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('b9999999-0009-4009-8009-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '99999999-9999-4999-8999-999999999999',
 'Core Web Vitals en Next.js',
 'Ver archivo: content/courses/nextjs-14/module-09/lesson-01.md',
 'text', 1, true, NOW()),

('b9999999-0009-4009-8009-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '99999999-9999-4999-8999-999999999999',
 'Bundle analysis y code splitting',
 'Ver archivo: content/courses/nextjs-14/module-09/lesson-02.md',
 'text', 2, true, NOW()),

('b9999999-0009-4009-8009-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '99999999-9999-4999-8999-999999999999',
 'Edge Runtime vs Node.js',
 'Ver archivo: content/courses/nextjs-14/module-09/lesson-03.md',
 'text', 3, true, NOW()),

('b9999999-0009-4009-8009-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '99999999-9999-4999-8999-999999999999',
 'ISR y generación estática',
 'Ver archivo: content/courses/nextjs-14/module-09/lesson-04.md',
 'text', 4, true, NOW()),

('b9999999-0009-4009-8009-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', '99999999-9999-4999-8999-999999999999',
 'Quiz: Performance y Optimización',
 'Evaluación de conocimientos del Módulo 9',
 'quiz', 5, true, NOW());

-- ============================================
-- MÓDULO 10: Deploy y Producción
-- ============================================
INSERT INTO modules (id, course_id, title, description, order_index, is_locked, unlock_after_module, created_at)
VALUES (
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'a1b2c3d4-e5f6-4890-abcd-ef1234567890',
  'Deploy y Producción',
  'Lleva tu aplicación a producción con confianza. Aprende deploy en Vercel, Docker, CI/CD y monitoreo.',
  10,
  false,
  '99999999-9999-4999-8999-999999999999',
  NOW()
);

-- Lecciones del Módulo 10
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, is_required, created_at) VALUES
('baaaaaaa-000a-400a-800a-000000000001', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
 'Deploy en Vercel',
 'Ver archivo: content/courses/nextjs-14/module-10/lesson-01.md',
 'video', 1, true, NOW()),

('baaaaaaa-000a-400a-800a-000000000002', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
 'Alternativas: Docker y self-hosted',
 'Ver archivo: content/courses/nextjs-14/module-10/lesson-02.md',
 'text', 2, true, NOW()),

('baaaaaaa-000a-400a-800a-000000000003', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
 'Monitoreo y observabilidad',
 'Ver archivo: content/courses/nextjs-14/module-10/lesson-03.md',
 'text', 3, true, NOW()),

('baaaaaaa-000a-400a-800a-000000000004', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
 'CI/CD pipeline',
 'Ver archivo: content/courses/nextjs-14/module-10/lesson-04.md',
 'text', 4, true, NOW()),

('baaaaaaa-000a-400a-800a-000000000005', 'a1b2c3d4-e5f6-4890-abcd-ef1234567890', 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
 'Assignment Final: Deploy con CI/CD',
 'Proyecto final del curso',
 'assignment', 5, true, NOW());

-- ============================================
-- QUIZZES
-- ============================================

-- Quiz 1: Fundamentos de Next.js
INSERT INTO quizzes (id, lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, show_correct_answers, is_published, created_at)
VALUES (
  'c1111111-1111-4111-8111-111111111111',
  'b1111111-0001-4001-8001-000000000005',
  'Quiz: Fundamentos de Next.js 14',
  'Evalúa tu comprensión de los conceptos fundamentales de Next.js 14 y su arquitectura.',
  70,
  3,
  15,
  true,
  true,
  true,
  NOW()
);

-- Quiz 2: Sistema de Routing
INSERT INTO quizzes (id, lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, show_correct_answers, is_published, created_at)
VALUES (
  'c2222222-2222-4222-8222-222222222222',
  'b2222222-0002-4002-8002-000000000006',
  'Quiz: Sistema de Routing',
  'Evalúa tu dominio del sistema de rutas file-based de Next.js 14.',
  70,
  3,
  15,
  true,
  true,
  true,
  NOW()
);

-- Quiz 3: Server Components y Data Fetching
INSERT INTO quizzes (id, lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, show_correct_answers, is_published, created_at)
VALUES (
  'c3333333-3333-4333-8333-333333333333',
  'b3333333-0003-4003-8003-000000000006',
  'Quiz: Server Components y Data Fetching',
  'Evalúa tu comprensión del modelo de React Server Components y patrones de fetching.',
  70,
  3,
  15,
  true,
  true,
  true,
  NOW()
);

-- Quiz 4: Autenticación y Seguridad
INSERT INTO quizzes (id, lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, show_correct_answers, is_published, created_at)
VALUES (
  'c5555555-5555-4555-8555-555555555555',
  'b5555555-0005-4005-8005-000000000005',
  'Quiz: Autenticación y Seguridad',
  'Evalúa tu conocimiento sobre autenticación, middleware y seguridad en Next.js.',
  70,
  3,
  12,
  true,
  true,
  true,
  NOW()
);

-- Quiz 5: Estilos y UI
INSERT INTO quizzes (id, lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, show_correct_answers, is_published, created_at)
VALUES (
  'c7777777-7777-4777-8777-777777777777',
  'b7777777-0007-4007-8007-000000000005',
  'Quiz: Estilos y Optimización de UI',
  'Evalúa tu comprensión de estrategias de styling y optimización de assets.',
  70,
  3,
  10,
  true,
  true,
  true,
  NOW()
);

-- Quiz 6: Performance
INSERT INTO quizzes (id, lesson_id, title, description, passing_score, max_attempts, time_limit, shuffle_questions, show_correct_answers, is_published, created_at)
VALUES (
  'c9999999-9999-4999-8999-999999999999',
  'b9999999-0009-4009-8009-000000000005',
  'Quiz: Performance y Optimización',
  'Evalúa tu conocimiento sobre Core Web Vitals y técnicas de optimización.',
  70,
  3,
  12,
  true,
  true,
  true,
  NOW()
);

-- ============================================
-- PREGUNTAS DE QUIZZES
-- ============================================

-- Preguntas Quiz 1: Fundamentos
INSERT INTO quiz_questions (id, quiz_id, question_type, question, options, points, order_index, explanation, created_at) VALUES
('d1110001-0001-4001-8001-000000000001', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Cuál es la principal diferencia entre CSR (Client-Side Rendering) y SSR (Server-Side Rendering)?',
 '[{"id": "a", "text": "CSR renderiza en el servidor, SSR en el cliente", "is_correct": false}, {"id": "b", "text": "SSR genera HTML en el servidor antes de enviarlo al cliente, CSR lo hace en el navegador", "is_correct": true}, {"id": "c", "text": "No hay diferencia, son términos intercambiables", "is_correct": false}, {"id": "d", "text": "CSR es más rápido que SSR siempre", "is_correct": false}]',
 1, 1, 'SSR pre-renderiza el HTML en el servidor, lo que mejora el SEO y el tiempo de carga inicial. CSR envía un HTML vacío y JavaScript que renderiza en el navegador.', NOW()),

('d1110002-0002-4002-8002-000000000002', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Qué problema resuelve principalmente Next.js respecto a React vanilla?',
 '[{"id": "a", "text": "Agrega TypeScript automáticamente", "is_correct": false}, {"id": "b", "text": "Proporciona SSR/SSG, routing y optimizaciones out-of-the-box", "is_correct": true}, {"id": "c", "text": "Reemplaza completamente a React", "is_correct": false}, {"id": "d", "text": "Solo sirve para aplicaciones pequeñas", "is_correct": false}]',
 1, 2, 'Next.js extiende React con renderizado en servidor, generación estática, routing basado en archivos y múltiples optimizaciones de producción.', NOW()),

('d1110003-0003-4003-8003-000000000003', 'c1111111-1111-4111-8111-111111111111', 'true_false',
 'El App Router de Next.js 14 utiliza React Server Components por defecto.',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 3, 'Correcto. En el App Router, todos los componentes son Server Components por defecto. Debes usar "use client" explícitamente para Client Components.', NOW()),

('d1110004-0004-4004-8004-000000000004', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Cuál es la estructura de archivos correcta para crear una ruta /about en App Router?',
 '[{"id": "a", "text": "pages/about.tsx", "is_correct": false}, {"id": "b", "text": "app/about/page.tsx", "is_correct": true}, {"id": "c", "text": "src/about/index.tsx", "is_correct": false}, {"id": "d", "text": "routes/about.tsx", "is_correct": false}]',
 1, 4, 'En App Router, las rutas se definen con carpetas y el archivo page.tsx dentro de ellas. app/about/page.tsx crea la ruta /about.', NOW()),

('d1110005-0005-4005-8005-000000000005', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Qué archivo define el layout compartido para todas las rutas en App Router?',
 '[{"id": "a", "text": "app/_app.tsx", "is_correct": false}, {"id": "b", "text": "app/layout.tsx", "is_correct": true}, {"id": "c", "text": "app/template.tsx", "is_correct": false}, {"id": "d", "text": "app/wrapper.tsx", "is_correct": false}]',
 1, 5, 'app/layout.tsx es el layout raíz que envuelve todas las páginas. Es obligatorio y define la estructura HTML básica incluyendo <html> y <body>.', NOW()),

('d1110006-0006-4006-8006-000000000006', 'c1111111-1111-4111-8111-111111111111', 'true_false',
 'La hidratación es el proceso de adjuntar event listeners al HTML pre-renderizado por el servidor.',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 6, 'Correcto. La hidratación hace que el HTML estático sea interactivo al adjuntar los manejadores de eventos de React en el cliente.', NOW()),

('d1110007-0007-4007-8007-000000000007', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Cuál comando crea un nuevo proyecto Next.js 14 con la configuración recomendada?',
 '[{"id": "a", "text": "npm init next-app", "is_correct": false}, {"id": "b", "text": "npx create-next-app@latest", "is_correct": true}, {"id": "c", "text": "npm install next", "is_correct": false}, {"id": "d", "text": "yarn create next", "is_correct": false}]',
 1, 7, 'npx create-next-app@latest es el comando oficial que configura un proyecto con todas las opciones recomendadas incluyendo TypeScript, ESLint y App Router.', NOW()),

('d1110008-0008-4008-8008-000000000008', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Qué ventaja tiene SSG (Static Site Generation) sobre SSR?',
 '[{"id": "a", "text": "Datos siempre actualizados", "is_correct": false}, {"id": "b", "text": "Puede servirse desde CDN, mejor performance y caching", "is_correct": true}, {"id": "c", "text": "Mejor para contenido dinámico", "is_correct": false}, {"id": "d", "text": "No requiere build step", "is_correct": false}]',
 1, 8, 'SSG genera HTML en build time que puede cachearse en CDN globalmente, resultando en tiempos de respuesta más rápidos para contenido estático.', NOW()),

('d1110009-0009-4009-8009-000000000009', 'c1111111-1111-4111-8111-111111111111', 'true_false',
 'En Next.js 14, Pages Router y App Router pueden coexistir en el mismo proyecto.',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 9, 'Correcto. Next.js permite migración incremental. Puedes tener rutas en /pages y /app simultáneamente, aunque App Router tiene prioridad para rutas conflictivas.', NOW()),

('d1110010-0010-4010-8010-000000000010', 'c1111111-1111-4111-8111-111111111111', 'mcq',
 '¿Qué significa SEO y por qué SSR lo mejora?',
 '[{"id": "a", "text": "Server Enabled Output - mejora el rendimiento del servidor", "is_correct": false}, {"id": "b", "text": "Search Engine Optimization - los crawlers ven el contenido renderizado", "is_correct": true}, {"id": "c", "text": "Static Export Option - genera archivos estáticos", "is_correct": false}, {"id": "d", "text": "Secure Encrypted Output - mejora la seguridad", "is_correct": false}]',
 1, 10, 'SEO (Search Engine Optimization) mejora con SSR porque los crawlers de buscadores reciben HTML completo en lugar de un shell vacío con JavaScript.', NOW());

-- Preguntas Quiz 2: Routing
INSERT INTO quiz_questions (id, quiz_id, question_type, question, options, points, order_index, explanation, created_at) VALUES
('d2220001-0001-4001-8001-000000000001', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Cómo se crea una ruta dinámica para /products/[id] en App Router?',
 '[{"id": "a", "text": "app/products/$id/page.tsx", "is_correct": false}, {"id": "b", "text": "app/products/[id]/page.tsx", "is_correct": true}, {"id": "c", "text": "app/products/:id/page.tsx", "is_correct": false}, {"id": "d", "text": "app/products/{id}/page.tsx", "is_correct": false}]',
 1, 1, 'Next.js usa corchetes [param] para rutas dinámicas. El valor del parámetro se pasa como prop params al componente.', NOW()),

('d2220002-0002-4002-8002-000000000002', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Cuál es la diferencia entre [...slug] y [[...slug]]?',
 '[{"id": "a", "text": "[...slug] es opcional, [[...slug]] es requerido", "is_correct": false}, {"id": "b", "text": "[...slug] captura todos los segmentos, [[...slug]] también matchea la ruta raíz", "is_correct": true}, {"id": "c", "text": "No hay diferencia", "is_correct": false}, {"id": "d", "text": "[[...slug]] captura más segmentos", "is_correct": false}]',
 1, 2, '[...slug] requiere al menos un segmento. [[...slug]] es opcional y también matchea la ruta sin parámetros (ej: /docs además de /docs/a/b).', NOW()),

('d2220003-0003-4003-8003-000000000003', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Para qué sirven los grupos de rutas con (folder)?',
 '[{"id": "a", "text": "Crear rutas privadas que requieren autenticación", "is_correct": false}, {"id": "b", "text": "Organizar archivos sin afectar la URL", "is_correct": true}, {"id": "c", "text": "Crear rutas opcionales", "is_correct": false}, {"id": "d", "text": "Definir rutas API", "is_correct": false}]',
 1, 3, 'Los grupos (folder) permiten organizar código y compartir layouts sin que el nombre de la carpeta aparezca en la URL.', NOW()),

('d2220004-0004-4004-8004-000000000004', 'c2222222-2222-4222-8222-222222222222', 'true_false',
 'layout.tsx se re-renderiza completamente en cada navegación.',
 '[{"id": "true", "text": "Verdadero", "is_correct": false}, {"id": "false", "text": "Falso", "is_correct": true}]',
 1, 4, 'Falso. Los layouts preservan su estado entre navegaciones. Solo las partes que cambian (pages) se re-renderizan. Para re-renderizar usa template.tsx.', NOW()),

('d2220005-0005-4005-8005-000000000005', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Qué archivo muestra mientras se carga una página?',
 '[{"id": "a", "text": "wait.tsx", "is_correct": false}, {"id": "b", "text": "loading.tsx", "is_correct": true}, {"id": "c", "text": "pending.tsx", "is_correct": false}, {"id": "d", "text": "suspense.tsx", "is_correct": false}]',
 1, 5, 'loading.tsx crea automáticamente un Suspense boundary y muestra su contenido mientras la página carga datos.', NOW()),

('d2220006-0006-4006-8006-000000000006', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Cómo defines un error boundary para un segmento de ruta?',
 '[{"id": "a", "text": "Usando try/catch en el componente", "is_correct": false}, {"id": "b", "text": "Creando error.tsx en el directorio", "is_correct": true}, {"id": "c", "text": "Usando ErrorBoundary de React", "is_correct": false}, {"id": "d", "text": "Configurando next.config.js", "is_correct": false}]',
 1, 6, 'error.tsx captura errores del segmento y sus hijos. Debe ser un Client Component y recibe error y reset como props.', NOW()),

('d2220007-0007-4007-8007-000000000007', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Qué son Parallel Routes y cómo se definen?',
 '[{"id": "a", "text": "Rutas que cargan en paralelo, se definen con @folder", "is_correct": true}, {"id": "b", "text": "Rutas duplicadas, se definen con &folder", "is_correct": false}, {"id": "c", "text": "Rutas alternativas, se definen con |folder", "is_correct": false}, {"id": "d", "text": "Rutas simultáneas, se definen con +folder", "is_correct": false}]',
 1, 7, 'Parallel Routes (@slot) permiten renderizar múltiples páginas en la misma vista simultáneamente. Útil para dashboards y modales.', NOW()),

('d2220008-0008-4008-8008-000000000008', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Cuál es la ventaja del componente Link sobre anchor tags normales?',
 '[{"id": "a", "text": "Solo funciona con rutas absolutas", "is_correct": false}, {"id": "b", "text": "Habilita prefetching y navegación del lado del cliente", "is_correct": true}, {"id": "c", "text": "Requiere JavaScript deshabilitado", "is_correct": false}, {"id": "d", "text": "Solo funciona en Server Components", "is_correct": false}]',
 1, 8, 'Link pre-carga rutas en viewport para navegación instantánea y mantiene el estado de la aplicación sin recargar la página completa.', NOW()),

('d2220009-0009-4009-8009-000000000009', 'c2222222-2222-4222-8222-222222222222', 'true_false',
 'Intercepting Routes con (.) interceptan rutas del mismo nivel.',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 9, 'Correcto. (.) matchea el mismo nivel, (..) un nivel arriba, (..)(..) dos niveles, y (...) desde la raíz.', NOW()),

('d2220010-0010-4010-8010-000000000010', 'c2222222-2222-4222-8222-222222222222', 'mcq',
 '¿Cómo accedes a los parámetros de ruta en un Server Component?',
 '[{"id": "a", "text": "useParams() hook", "is_correct": false}, {"id": "b", "text": "props.params directamente (es una Promise en Next.js 15+)", "is_correct": true}, {"id": "c", "text": "getServerSideProps", "is_correct": false}, {"id": "d", "text": "context.query", "is_correct": false}]',
 1, 10, 'En Server Components, params se pasa como prop. En Next.js 15+ es una Promise que debe awaitearse. En Client Components usa useParams().', NOW());

-- Preguntas Quiz 3: Server Components y Data Fetching
INSERT INTO quiz_questions (id, quiz_id, question_type, question, options, points, order_index, explanation, created_at) VALUES
('d3330001-0001-4001-8001-000000000001', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Cuál directiva convierte un Server Component en Client Component?',
 '[{"id": "a", "text": "\"use server\"", "is_correct": false}, {"id": "b", "text": "\"use client\"", "is_correct": true}, {"id": "c", "text": "\"client only\"", "is_correct": false}, {"id": "d", "text": "export const runtime = \"client\"", "is_correct": false}]',
 1, 1, '\"use client\" al inicio del archivo marca todo el módulo y sus importaciones como Client Components.', NOW()),

('d3330002-0002-4002-8002-000000000002', 'c3333333-3333-4333-8333-333333333333', 'true_false',
 'Los Server Components pueden usar hooks como useState y useEffect.',
 '[{"id": "true", "text": "Verdadero", "is_correct": false}, {"id": "false", "text": "Falso", "is_correct": true}]',
 1, 2, 'Falso. Los hooks de React que manejan estado o efectos solo funcionan en Client Components. Los Server Components no tienen ciclo de vida del cliente.', NOW()),

('d3330003-0003-4003-8003-000000000003', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Cómo se hace fetch de datos en un Server Component?',
 '[{"id": "a", "text": "useEffect + fetch", "is_correct": false}, {"id": "b", "text": "getServerSideProps", "is_correct": false}, {"id": "c", "text": "async/await directamente en el componente", "is_correct": true}, {"id": "d", "text": "useSWR", "is_correct": false}]',
 1, 3, 'Los Server Components pueden ser async functions y usar await directamente para fetch. No necesitan useEffect.', NOW()),

('d3330004-0004-4004-8004-000000000004', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Cuál opción de fetch desactiva el caching?',
 '[{"id": "a", "text": "cache: \"default\"", "is_correct": false}, {"id": "b", "text": "cache: \"no-store\"", "is_correct": true}, {"id": "c", "text": "cache: \"reload\"", "is_correct": false}, {"id": "d", "text": "cache: false", "is_correct": false}]',
 1, 4, 'cache: \"no-store\" hace que cada request sea fresh. Equivale a getServerSideProps del Pages Router.', NOW()),

('d3330005-0005-4005-8005-000000000005', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Cómo revalidas datos cacheados después de un tiempo específico?',
 '[{"id": "a", "text": "fetch(url, { revalidate: 60 })", "is_correct": false}, {"id": "b", "text": "fetch(url, { next: { revalidate: 60 } })", "is_correct": true}, {"id": "c", "text": "fetch(url, { ttl: 60 })", "is_correct": false}, {"id": "d", "text": "fetch(url, { maxAge: 60 })", "is_correct": false}]',
 1, 5, 'next: { revalidate: 60 } revalida los datos cada 60 segundos. Es ISR (Incremental Static Regeneration).', NOW()),

('d3330006-0006-4006-8006-000000000006', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Qué es la serialización en el contexto de Server/Client Components?',
 '[{"id": "a", "text": "Comprimir datos para transferencia", "is_correct": false}, {"id": "b", "text": "Convertir datos a formato transferible entre servidor y cliente", "is_correct": true}, {"id": "c", "text": "Encriptar datos sensibles", "is_correct": false}, {"id": "d", "text": "Ordenar datos alfabéticamente", "is_correct": false}]',
 1, 6, 'La serialización convierte props a JSON para transferir del servidor al cliente. Por eso no puedes pasar funciones o clases como props a Client Components.', NOW()),

('d3330007-0007-4007-8007-000000000007', 'c3333333-3333-4333-8333-333333333333', 'true_false',
 'Un Client Component puede importar y renderizar un Server Component.',
 '[{"id": "true", "text": "Verdadero", "is_correct": false}, {"id": "false", "text": "Falso", "is_correct": true}]',
 1, 7, 'Falso. Un Client Component no puede importar Server Components. Pero puede recibirlos como children o props ya renderizados.', NOW()),

('d3330008-0008-4008-8008-000000000008', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Qué patrón permite usar Server Components dentro de Client Components?',
 '[{"id": "a", "text": "Importación directa", "is_correct": false}, {"id": "b", "text": "Pasarlos como children o slots", "is_correct": true}, {"id": "c", "text": "Usar dynamic imports", "is_correct": false}, {"id": "d", "text": "No es posible", "is_correct": false}]',
 1, 8, 'El patrón \"Composition\" pasa Server Components pre-renderizados como children a Client Components, manteniendo los beneficios de ambos.', NOW()),

('d3330009-0009-4009-8009-000000000009', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Qué hace Suspense en el contexto de streaming?',
 '[{"id": "a", "text": "Detiene todo el render hasta que los datos lleguen", "is_correct": false}, {"id": "b", "text": "Permite enviar HTML progresivamente mostrando fallbacks", "is_correct": true}, {"id": "c", "text": "Cachea los componentes suspendidos", "is_correct": false}, {"id": "d", "text": "Previene errores de hidratación", "is_correct": false}]',
 1, 9, 'Suspense con streaming envía el HTML progresivamente. Muestra el fallback inmediatamente y reemplaza con contenido real cuando está listo.', NOW()),

('d3330010-0010-4010-8010-000000000010', 'c3333333-3333-4333-8333-333333333333', 'mcq',
 '¿Cuándo deberías usar un Client Component en lugar de Server Component?',
 '[{"id": "a", "text": "Siempre que uses TypeScript", "is_correct": false}, {"id": "b", "text": "Cuando necesitas interactividad, estado o hooks del navegador", "is_correct": true}, {"id": "c", "text": "Para todas las páginas principales", "is_correct": false}, {"id": "d", "text": "Cuando haces fetch de datos", "is_correct": false}]',
 1, 10, 'Usa Client Components para: onClick, onChange, useState, useEffect, APIs del navegador (localStorage, geolocation), librerías que usan estos.', NOW());

-- Preguntas Quiz 4: Autenticación y Seguridad
INSERT INTO quiz_questions (id, quiz_id, question_type, question, options, points, order_index, explanation, created_at) VALUES
('d5550001-0001-4001-8001-000000000001', 'c5555555-5555-4555-8555-555555555555', 'mcq',
 '¿Cuál es la diferencia principal entre autenticación basada en JWT y Sessions?',
 '[{"id": "a", "text": "JWT es más seguro que sessions", "is_correct": false}, {"id": "b", "text": "JWT es stateless (no requiere storage en servidor), sessions requieren almacenamiento", "is_correct": true}, {"id": "c", "text": "Sessions son más rápidas que JWT", "is_correct": false}, {"id": "d", "text": "No hay diferencia significativa", "is_correct": false}]',
 1, 1, 'JWT contiene toda la info en el token (stateless), mientras sessions almacenan datos en servidor y solo envían un ID al cliente.', NOW()),

('d5550002-0002-4002-8002-000000000002', 'c5555555-5555-4555-8555-555555555555', 'mcq',
 '¿Dónde se ejecuta el middleware de Next.js?',
 '[{"id": "a", "text": "En el cliente después de la hidratación", "is_correct": false}, {"id": "b", "text": "En el Edge Runtime antes de que la request llegue a la aplicación", "is_correct": true}, {"id": "c", "text": "En Node.js después del render", "is_correct": false}, {"id": "d", "text": "En ambos servidor y cliente", "is_correct": false}]',
 1, 2, 'El middleware corre en Edge Runtime, interceptando requests antes de que lleguen a rutas o API. Ideal para auth, redirects y headers.', NOW()),

('d5550003-0003-4003-8003-000000000003', 'c5555555-5555-4555-8555-555555555555', 'true_false',
 'El archivo middleware.ts debe estar en la raíz del proyecto (junto a app/).',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 3, 'Correcto. middleware.ts va en la raíz del proyecto o en /src si usas esa estructura. No dentro de /app.', NOW()),

('d5550004-0004-4004-8004-000000000004', 'c5555555-5555-4555-8555-555555555555', 'mcq',
 '¿Cómo defines qué rutas procesa el middleware?',
 '[{"id": "a", "text": "if statements dentro del middleware", "is_correct": false}, {"id": "b", "text": "Exportando un objeto config con matcher", "is_correct": true}, {"id": "c", "text": "En next.config.js", "is_correct": false}, {"id": "d", "text": "El middleware procesa todas las rutas siempre", "is_correct": false}]',
 1, 4, 'export const config = { matcher: [\"/dashboard/:path*\"] } define qué rutas ejecutan el middleware. Soporta patrones glob.', NOW()),

('d5550005-0005-4005-8005-000000000005', 'c5555555-5555-4555-8555-555555555555', 'mcq',
 '¿Qué callback de NextAuth.js se usa para agregar datos custom al token JWT?',
 '[{"id": "a", "text": "signIn callback", "is_correct": false}, {"id": "b", "text": "jwt callback", "is_correct": true}, {"id": "c", "text": "session callback", "is_correct": false}, {"id": "d", "text": "authorize callback", "is_correct": false}]',
 1, 5, 'El jwt callback se ejecuta cuando se crea o actualiza el token. Aquí agregas claims custom como role o userId.', NOW()),

('d5550006-0006-4006-8006-000000000006', 'c5555555-5555-4555-8555-555555555555', 'mcq',
 '¿Cuál es la forma segura de verificar autenticación en un Server Component?',
 '[{"id": "a", "text": "Verificar cookies con JavaScript del cliente", "is_correct": false}, {"id": "b", "text": "Llamar auth() o getServerSession() en el servidor", "is_correct": true}, {"id": "c", "text": "Confiar en localStorage", "is_correct": false}, {"id": "d", "text": "Verificar query params de la URL", "is_correct": false}]',
 1, 6, 'auth() de NextAuth v5 o getServerSession() verifican la sesión en el servidor de forma segura, sin exponer lógica al cliente.', NOW()),

('d5550007-0007-4007-8007-000000000007', 'c5555555-5555-4555-8555-555555555555', 'true_false',
 'Es seguro verificar roles solo en el cliente (Client Components) para proteger rutas.',
 '[{"id": "true", "text": "Verdadero", "is_correct": false}, {"id": "false", "text": "Falso", "is_correct": true}]',
 1, 7, 'Falso. Las verificaciones del cliente pueden ser bypassed. Siempre verifica permisos en el servidor (middleware, Server Components, API routes).', NOW()),

('d5550008-0008-4008-8008-000000000008', 'c5555555-5555-4555-8555-555555555555', 'mcq',
 '¿Qué hace NextResponse.redirect() en middleware?',
 '[{"id": "a", "text": "Retorna un error 500", "is_correct": false}, {"id": "b", "text": "Redirige la request a otra URL antes de procesar la ruta", "is_correct": true}, {"id": "c", "text": "Guarda la URL en cookies", "is_correct": false}, {"id": "d", "text": "Reescribe la URL sin cambiar la barra de direcciones", "is_correct": false}]',
 1, 8, 'NextResponse.redirect() envía una respuesta de redirección HTTP. NextResponse.rewrite() cambia internamente la ruta sin que el usuario lo vea.', NOW());

-- Preguntas Quiz 5: Estilos y UI
INSERT INTO quiz_questions (id, quiz_id, question_type, question, options, points, order_index, explanation, created_at) VALUES
('d7770001-0001-4001-8001-000000000001', 'c7777777-7777-4777-8777-777777777777', 'mcq',
 '¿Cuál es la ventaja principal de Tailwind sobre CSS tradicional en proyectos Next.js?',
 '[{"id": "a", "text": "Es más rápido en runtime", "is_correct": false}, {"id": "b", "text": "Utility-first reduce CSS bundle y mejora DX con autocompletado", "is_correct": true}, {"id": "c", "text": "No requiere configuración", "is_correct": false}, {"id": "d", "text": "Funciona sin build step", "is_correct": false}]',
 1, 1, 'Tailwind purga CSS no usado, resultando en bundles pequeños. Las utilities permiten styling inline sin saltar entre archivos.', NOW()),

('d7770002-0002-4002-8002-000000000002', 'c7777777-7777-4777-8777-777777777777', 'mcq',
 '¿Cómo implementas dark mode con Tailwind en Next.js?',
 '[{"id": "a", "text": "Usando @media (prefers-color-scheme) únicamente", "is_correct": false}, {"id": "b", "text": "Configurando darkMode: \"class\" y toggleando la clase dark en html", "is_correct": true}, {"id": "c", "text": "Instalando un plugin adicional", "is_correct": false}, {"id": "d", "text": "Dark mode no está soportado", "is_correct": false}]',
 1, 2, 'darkMode: \"class\" permite toggle manual con clase \"dark\" en <html>. Usa dark:bg-gray-900 para estilos específicos de dark mode.', NOW()),

('d7770003-0003-4003-8003-000000000003', 'c7777777-7777-4777-8777-777777777777', 'true_false',
 'next/font carga fuentes de Google sin enviar requests al dominio de Google desde el cliente.',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 3, 'Correcto. next/font descarga y sirve fuentes localmente en build time, mejorando privacidad y performance al evitar requests externos.', NOW()),

('d7770004-0004-4004-8004-000000000004', 'c7777777-7777-4777-8777-777777777777', 'mcq',
 '¿Qué hace el componente Image de next/image automáticamente?',
 '[{"id": "a", "text": "Solo lazy loading", "is_correct": false}, {"id": "b", "text": "Lazy loading, optimización de formato, responsive sizes y prevención de CLS", "is_correct": true}, {"id": "c", "text": "Compresión en el cliente", "is_correct": false}, {"id": "d", "text": "Solo conversión a WebP", "is_correct": false}]',
 1, 4, 'next/image optimiza: lazy loading, formato moderno (WebP/AVIF), srcset responsive, placeholder blur, y reserva espacio para evitar layout shift.', NOW()),

('d7770005-0005-4005-8005-000000000005', 'c7777777-7777-4777-8777-777777777777', 'mcq',
 '¿Qué es shadcn/ui y cómo difiere de otras librerías de componentes?',
 '[{"id": "a", "text": "Un paquete npm que instalas como dependencia", "is_correct": false}, {"id": "b", "text": "Componentes que copias a tu proyecto, dándote ownership total del código", "is_correct": true}, {"id": "c", "text": "Una extensión de VS Code", "is_correct": false}, {"id": "d", "text": "Un framework CSS alternativo a Tailwind", "is_correct": false}]',
 1, 5, 'shadcn/ui no es una dependencia: copias componentes a tu proyecto. Tienes control total para customizar sin limitaciones de la librería.', NOW()),

('d7770006-0006-4006-8006-000000000006', 'c7777777-7777-4777-8777-777777777777', 'mcq',
 '¿Por qué Framer Motion requiere consideraciones especiales en App Router?',
 '[{"id": "a", "text": "No funciona con TypeScript", "is_correct": false}, {"id": "b", "text": "Es una librería cliente que necesita \"use client\" y manejo de exit animations", "is_correct": true}, {"id": "c", "text": "Solo funciona en Pages Router", "is_correct": false}, {"id": "d", "text": "Requiere configuración en next.config.js", "is_correct": false}]',
 1, 6, 'Framer Motion usa hooks y APIs del cliente. Las exit animations requieren AnimatePresence que necesita controlar el unmount de componentes.', NOW());

-- Preguntas Quiz 6: Performance
INSERT INTO quiz_questions (id, quiz_id, question_type, question, options, points, order_index, explanation, created_at) VALUES
('d9990001-0001-4001-8001-000000000001', 'c9999999-9999-4999-8999-999999999999', 'mcq',
 '¿Cuáles son los tres Core Web Vitals principales?',
 '[{"id": "a", "text": "FPS, Memory, CPU", "is_correct": false}, {"id": "b", "text": "LCP, FID/INP, CLS", "is_correct": true}, {"id": "c", "text": "TTI, TBT, FCP", "is_correct": false}, {"id": "d", "text": "DNS, TCP, TLS", "is_correct": false}]',
 1, 1, 'LCP (Largest Contentful Paint), INP (Interaction to Next Paint, reemplazó FID), CLS (Cumulative Layout Shift) son los Core Web Vitals actuales.', NOW()),

('d9990002-0002-4002-8002-000000000002', 'c9999999-9999-4999-8999-999999999999', 'mcq',
 '¿Qué herramienta analiza el tamaño de tu bundle en Next.js?',
 '[{"id": "a", "text": "next analyze", "is_correct": false}, {"id": "b", "text": "@next/bundle-analyzer", "is_correct": true}, {"id": "c", "text": "webpack-stats", "is_correct": false}, {"id": "d", "text": "next size", "is_correct": false}]',
 1, 2, '@next/bundle-analyzer genera visualizaciones interactivas del bundle. Configúralo en next.config.js y corre ANALYZE=true npm run build.', NOW()),

('d9990003-0003-4003-8003-000000000003', 'c9999999-9999-4999-8999-999999999999', 'mcq',
 '¿Qué hace dynamic() con ssr: false?',
 '[{"id": "a", "text": "Deshabilita el componente completamente", "is_correct": false}, {"id": "b", "text": "Carga el componente solo en el cliente, no en SSR", "is_correct": true}, {"id": "c", "text": "Hace el componente estático", "is_correct": false}, {"id": "d", "text": "Activa el modo de desarrollo", "is_correct": false}]',
 1, 3, 'dynamic(() => import(\"...\"), { ssr: false }) excluye el componente del bundle del servidor. Útil para librerías que usan window/document.', NOW()),

('d9990004-0004-4004-8004-000000000004', 'c9999999-9999-4999-8999-999999999999', 'true_false',
 'Edge Runtime tiene acceso completo a todas las APIs de Node.js.',
 '[{"id": "true", "text": "Verdadero", "is_correct": false}, {"id": "false", "text": "Falso", "is_correct": true}]',
 1, 4, 'Falso. Edge Runtime es más limitado que Node.js. No soporta APIs como fs, child_process, o módulos nativos. Es un subset diseñado para baja latencia.', NOW()),

('d9990005-0005-4005-8005-000000000005', 'c9999999-9999-4999-8999-999999999999', 'mcq',
 '¿Qué hace generateStaticParams() en una ruta dinámica?',
 '[{"id": "a", "text": "Valida parámetros en runtime", "is_correct": false}, {"id": "b", "text": "Pre-genera páginas estáticas para los parámetros especificados en build time", "is_correct": true}, {"id": "c", "text": "Cachea parámetros en memoria", "is_correct": false}, {"id": "d", "text": "Genera tipos TypeScript para params", "is_correct": false}]',
 1, 5, 'generateStaticParams permite SSG para rutas dinámicas. Las páginas se generan en build time, sirviendo HTML estático desde CDN.', NOW()),

('d9990006-0006-4006-8006-000000000006', 'c9999999-9999-4999-8999-999999999999', 'mcq',
 '¿Cuál es la diferencia entre revalidate: 0 y cache: \"no-store\"?',
 '[{"id": "a", "text": "Son equivalentes, no hay diferencia", "is_correct": false}, {"id": "b", "text": "revalidate: 0 usa cache pero revalida inmediatamente, no-store nunca cachea", "is_correct": true}, {"id": "c", "text": "revalidate es para SSG, no-store para SSR", "is_correct": false}, {"id": "d", "text": "no-store es más rápido", "is_correct": false}]',
 1, 6, 'cache: \"no-store\" desactiva completamente el cache. revalidate: 0 sigue usando el Data Cache pero marca los datos como stale inmediatamente.', NOW()),

('d9990007-0007-4007-8007-000000000007', 'c9999999-9999-4999-8999-999999999999', 'mcq',
 '¿Qué estrategia de ISR permite regenerar bajo demanda con revalidateTag()?',
 '[{"id": "a", "text": "Time-based revalidation", "is_correct": false}, {"id": "b", "text": "On-demand revalidation", "is_correct": true}, {"id": "c", "text": "Stale-while-revalidate", "is_correct": false}, {"id": "d", "text": "Incremental adoption", "is_correct": false}]',
 1, 7, 'On-demand revalidation con revalidateTag() permite invalidar cache específico cuando los datos cambian, sin esperar el tiempo de revalidación.', NOW()),

('d9990008-0008-4008-8008-000000000008', 'c9999999-9999-4999-8999-999999999999', 'true_false',
 'Usar Server Components reduce el JavaScript enviado al cliente.',
 '[{"id": "true", "text": "Verdadero", "is_correct": true}, {"id": "false", "text": "Falso", "is_correct": false}]',
 1, 8, 'Correcto. Los Server Components se renderizan en el servidor y solo envían HTML. Su código JavaScript no se incluye en el bundle del cliente.', NOW());

-- ============================================
-- ASSIGNMENTS
-- ============================================

-- Assignment 1: CRUD con Server Actions
INSERT INTO assignments (id, lesson_id, title, instructions, due_date, max_score, allowed_file_types, created_at)
VALUES (
  'e0010001-0001-4001-8001-000000000001',
  'b4444444-0004-4004-8004-000000000005',
  'CRUD completo con Server Actions',
  E'## Objetivo\nImplementar un CRUD completo para una entidad \"Tasks\" usando Server Actions.\n\n## Requisitos\n1. Crear formulario para agregar tareas\n2. Listar tareas con Server Components\n3. Implementar edición inline\n4. Agregar eliminación con confirmación\n5. Validar con Zod\n6. Usar useOptimistic para UI responsiva\n7. Implementar revalidatePath después de mutaciones\n\n## Entregables\n- Repositorio GitHub con el código\n- README con instrucciones de ejecución\n- Video corto (2-3 min) demostrando funcionalidad\n\n## Rúbrica\n- Funcionalidad completa: 40 pts\n- Validación y errores: 20 pts\n- Optimistic updates: 15 pts\n- Código limpio: 15 pts\n- Documentación: 10 pts',
  NULL,
  100,
  ARRAY['pdf', 'zip', 'md'],
  NOW()
);

-- Assignment 2: Modelo de datos con Prisma
INSERT INTO assignments (id, lesson_id, title, instructions, due_date, max_score, allowed_file_types, created_at)
VALUES (
  'e0020002-0002-4002-8002-000000000002',
  'b6666666-0006-4006-8006-000000000005',
  'Modelo de datos y CRUD con Prisma',
  E'## Objetivo\nDiseñar e implementar un modelo de datos para un blog con Prisma.\n\n## Requisitos\n1. Definir schema con: Users, Posts, Categories, Comments\n2. Implementar relaciones: one-to-many, many-to-many\n3. Crear migrations\n4. Implementar seed script\n5. CRUD para Posts con categorías\n6. Queries optimizadas (select, include)\n7. Transacciones para operaciones complejas\n\n## Entregables\n- Repositorio con schema.prisma\n- Migrations aplicadas\n- Seed script funcional\n- API routes o Server Actions implementando CRUD\n\n## Rúbrica\n- Schema diseño: 25 pts\n- Migrations: 15 pts\n- Seed data: 10 pts\n- CRUD funcional: 30 pts\n- Queries optimizadas: 10 pts\n- Documentación: 10 pts',
  NULL,
  100,
  ARRAY['pdf', 'zip', 'md'],
  NOW()
);

-- Assignment Final: Deploy con CI/CD
INSERT INTO assignments (id, lesson_id, title, instructions, due_date, max_score, allowed_file_types, created_at)
VALUES (
  'e0030003-0003-4003-8003-000000000003',
  'baaaaaaa-000a-400a-800a-000000000005',
  'Proyecto Final: Deploy con CI/CD',
  E'## Objetivo\nDesplegar una aplicación Next.js completa con pipeline CI/CD.\n\n## Requisitos\n1. Aplicación funcional con:\n   - Autenticación (NextAuth)\n   - Base de datos (Prisma + cualquier provider)\n   - Al menos 3 rutas protegidas\n   - Server Actions para mutaciones\n2. Deploy en Vercel con environment variables\n3. GitHub Actions para:\n   - Type checking (tsc --noEmit)\n   - Linting (eslint)\n   - Tests (al menos 5 tests con Vitest)\n   - Preview deployments en PRs\n4. Monitoreo básico configurado\n\n## Entregables\n- URL de producción funcionando\n- Repositorio público en GitHub\n- README con arquitectura y decisiones\n- Screenshot de pipeline pasando\n\n## Rúbrica\n- App funcional: 30 pts\n- CI pipeline: 25 pts\n- Deploy correcto: 20 pts\n- Tests: 15 pts\n- Documentación: 10 pts',
  NULL,
  100,
  ARRAY['pdf', 'zip', 'md', 'png', 'jpg'],
  NOW()
);

-- ============================================
-- RECURSOS DEL CURSO
-- ============================================

-- Recurso: Cheatsheet de Routing
INSERT INTO resources (id, lesson_id, title, file_url, file_type, file_size, download_count, created_at)
VALUES (
  'f0010001-0001-4001-8001-000000000001',
  'b2222222-0002-4002-8002-000000000006',
  'Cheatsheet: Next.js 14 Routing',
  '/resources/nextjs-14/cheatsheet-routing.pdf',
  'pdf',
  245760,
  0,
  NOW()
);

-- Recurso: Cheatsheet de Data Fetching
INSERT INTO resources (id, lesson_id, title, file_url, file_type, file_size, download_count, created_at)
VALUES (
  'f0020002-0002-4002-8002-000000000002',
  'b3333333-0003-4003-8003-000000000006',
  'Cheatsheet: Data Fetching y Caching',
  '/resources/nextjs-14/cheatsheet-fetching.pdf',
  'pdf',
  198656,
  0,
  NOW()
);

-- Recurso: Starter Code Módulo 4
INSERT INTO resources (id, lesson_id, title, file_url, file_type, file_size, download_count, created_at)
VALUES (
  'f0030003-0003-4003-8003-000000000003',
  'b4444444-0004-4004-8004-000000000001',
  'Starter Code: Server Actions Lab',
  '/resources/nextjs-14/starter-server-actions.zip',
  'zip',
  524288,
  0,
  NOW()
);

-- Recurso: Guía de Auth.js
INSERT INTO resources (id, lesson_id, title, file_url, file_type, file_size, download_count, created_at)
VALUES (
  'f0040004-0004-4004-8004-000000000004',
  'b5555555-0005-4005-8005-000000000002',
  'Guía completa: NextAuth.js v5',
  '/resources/nextjs-14/guide-authjs.pdf',
  'pdf',
  389120,
  0,
  NOW()
);

-- Recurso: Docker template
INSERT INTO resources (id, lesson_id, title, file_url, file_type, file_size, download_count, created_at)
VALUES (
  'f0050005-0005-4005-8005-000000000005',
  'baaaaaaa-000a-400a-800a-000000000002',
  'Dockerfile y docker-compose template',
  '/resources/nextjs-14/docker-template.zip',
  'zip',
  8192,
  0,
  NOW()
);

-- ============================================
-- FIN DEL SEED
-- ============================================
