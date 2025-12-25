# EduPlatform - Contexto del Proyecto

> **Configuracion Local:** Para rutas absolutas, credenciales y project refs especificos de tu entorno,
> crea `CLAUDE.local.md` basandote en `CLAUDE.local.example.md`.

## Descripcion
Plataforma educativa con cursos, lecciones, **ejercicios interactivos de codigo**, quizzes y tracking de progreso.

## Stack Tecnologico
- **Frontend**: Next.js 14 (App Router)
- **Base de datos**: Supabase (PostgreSQL)
- **Autenticacion**: Auth.js + Supabase Auth
- **Ejercicios Python**: Pyodide (WebAssembly)
- **Ejercicios SQL**: sql.js (WebAssembly)
- **Editor**: Monaco Editor
- **Estilos**: Tailwind CSS
- **Deploy**: Vercel con CI/CD automatico

## Funcionalidades Principales
- Cursos con modulos y lecciones
- **Ejercicios interactivos** (Python, SQL, Colab)
- Quizzes con calificacion automatica
- Foros de discusion
- Tracking de progreso
- Roles: student, instructor, admin

## Sistema de Ejercicios Interactivos

### Arquitectura
```
content/courses/[curso]/module-XX/
├── lessons/       # Markdown con <!-- exercise:id -->
└── exercises/     # YAML con codigo, tests, hints
```

### Componentes Clave
| Archivo | Funcion |
|---------|---------|
| `src/components/exercises/CodePlayground.tsx` | Editor + runner Python |
| `src/components/exercises/SQLPlayground.tsx` | Editor + runner SQL |
| `src/hooks/usePyodide.ts` | Carga Pyodide |
| `src/lib/content/loaders.ts` | Carga YAML |
| `src/app/api/exercises/[id]/route.ts` | API de ejercicios |

### Crear Nuevo Curso
**Ver:** `CLAUDE_COURSE_GUIDE.md` para instrucciones completas.

Resumen rapido:
1. Crear carpetas en `content/courses/[slug]/module-01/{lessons,exercises}`
2. Crear `course.yaml` y `module.yaml`
3. Crear lecciones `.md` con embeds `<!-- exercise:id -->`
4. Crear ejercicios `.yaml`
5. Crear migracion SQL en `supabase/migrations/`
6. Aplicar: `source .env.local && supabase db push --linked`
7. Push a main para deploy

## Estructura de Carpetas
```
src/
├── app/
│   ├── (auth)/login, register
│   ├── (dashboard)/courses/[id]/lessons/[lessonId]
│   └── api/exercises/[exerciseId]
├── components/
│   ├── exercises/     # Playgrounds interactivos
│   └── course/        # LessonPlayer, MarkdownRenderer
├── hooks/             # usePyodide, useSQLite
├── lib/content/       # Loaders, embed-parser
└── types/
content/
├── courses/           # Cursos con ejercicios
└── shared/            # Datasets, schemas
```

## Base de Datos (Supabase)

**IMPORTANTE: NO se necesita Connection String URI ni conexion directa a PostgreSQL.**

Este proyecto usa:
- **Frontend**: Supabase JS Client (`NEXT_PUBLIC_SUPABASE_URL` + `ANON_KEY`)
- **Migraciones**: Supabase CLI (`supabase db push --linked` con `SUPABASE_ACCESS_TOKEN`)

Las credenciales en `.env.local` son suficientes. Nunca pidas Connection String.

Tablas principales:
- `profiles` - Usuarios con roles
- `courses` - Cursos
- `modules` - Modulos
- `lessons` - Lecciones (contenido markdown)
- `progress` - Progreso por leccion
- `exercise_progress` - Progreso por ejercicio
- `quizzes`, `quiz_questions`, `quiz_attempts`
- `forums`, `forum_posts`, `forum_replies`

## Variables de Entorno

Las credenciales se configuran localmente. Ver `CLAUDE.local.md` para rutas especificas.

Variables requeridas en `.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_ACCESS_TOKEN=
```

## Comandos Utiles
```bash
npm run dev              # Desarrollo local
npm run build            # Build produccion
npm run lint             # Linter

# Migraciones
source .env.local && supabase db push --linked
source .env.local && supabase migration list
```

## Migraciones Existentes
| Archivo | Descripcion |
|---------|-------------|
| 20251201000001_initial_schema.sql | Schema inicial |
| 20251201000002_modules_hierarchy.sql | Modulos |
| 20251201000003_progress_tracking.sql | Tracking |
| 20251201000004_quizzes.sql | Evaluaciones |
| 20251201000005_forums.sql | Foros |
| 20251201000006_content_management.sql | Recursos |
| 20251225000001_interactive_exercises.sql | Tabla exercise_progress |
| 20251225000002_seed_python_course.sql | Curso Python |
| 20251225000003_update_python_course_content.sql | Contenido markdown |

## Cursos Existentes
| Curso | Slug | Ejercicios |
|-------|------|------------|
| Introduccion a Python | python-data-science | 13 |

## Documentacion
- `README.md` - Documentacion publica
- `CLAUDE.md` - Este archivo (contexto rapido)
- `CLAUDE_COURSE_GUIDE.md` - Guia completa para crear cursos
