# EduPlatform - Contexto del Proyecto

> **ESTADO ACTUAL:** El proyecto Supabase fue eliminado y necesita recrearse.
> Lee `RECOVERY_STATE.md` para los pasos pendientes antes de cualquier trabajo con backend/migraciones.

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

---

## CRITICO: Sistema de Contratos para Continuidad entre Modulos

Claude Code no tiene memoria entre sesiones. La coherencia pedagogica y tecnica de los cursos depende de **artefactos explicitos** que capturen el estado del diseño instruccional.

### Archivo de Estado por Curso

Cada curso DEBE tener un archivo `COURSE_STATE.yaml` en su carpeta raiz:

```
content/courses/[curso]/
├── COURSE_STATE.yaml    ← CONTRATO OBLIGATORIO
├── course.yaml
├── module-01/
├── module-02/
└── ...
```

### Protocolo Obligatorio para Claude Code

**ANTES de crear contenido para cualquier modulo:**

1. **LEER** `content/courses/[curso]/COURSE_STATE.yaml`
2. **VERIFICAR** que conceptos ya se introdujeron en modulos anteriores
3. **RESPETAR** las convenciones de codigo establecidas (nombres de variables, imports)
4. **SEGUIR** la especificacion en `next_module_spec`
5. **NO INTRODUCIR** conceptos que esten planificados para modulos posteriores

**AL COMPLETAR un modulo:**

1. **MOVER** contenido de `next_module_spec` a `exercises_registry`
2. **ACTUALIZAR** `concepts_introduced` con los nuevos conceptos
3. **ACTUALIZAR** `last_module_completed` y `last_updated`
4. **CREAR** nueva `next_module_spec` para el siguiente modulo
5. **INCREMENTAR** `total_exercises_created`

### Estructura del COURSE_STATE.yaml

```yaml
# content/courses/[curso]/COURSE_STATE.yaml

meta:
  course_id: [slug-del-curso]
  last_updated: YYYY-MM-DD
  last_module_completed: module-XX
  total_exercises_created: N

# Progresion pedagogica explicita
learning_progression:
  concepts_introduced:
    module-01:
      - concepto_1
      - concepto_2
    module-02:
      - concepto_3
    # ... conceptos por modulo

  skills_assumed:
    module-01: [prerequisito_1, prerequisito_2]
    module-02: [concepto_1, concepto_2]  # Del modulo anterior
    # ... prerequisitos por modulo

  complexity_trajectory:
    module-01: { lines_of_code: 5-15, datasets: 1, new_libraries: [lib1] }
    module-02: { lines_of_code: 15-30, datasets: 2, new_libraries: [] }
    # ... complejidad creciente

# Convenciones de codigo establecidas - RESPETAR EN TODO EL CURSO
code_conventions:
  variable_names:
    dataframe: df
    features: X
    target: y
    train_sets: X_train, y_train
    test_sets: X_test, y_test
    model: model
  
  import_style: |
    # Imports estandar del curso
    import pandas as pd
    import numpy as np
    # ... agregar segun se introduzcan

  test_pattern: |
    # Patron estandar para tests de ejercicios
    assert 'variable' in dir(), "Variable 'variable' no definida"
    assert isinstance(variable, expected_type), f"Tipo incorrecto"

# Registro de ejercicios completados con dependencias
exercises_registry:
  ex-01-nombre:
    concepts: [concepto_a, concepto_b]
    variables_created: [var1, var2]
    depends_on: []
    
  ex-02-nombre:
    concepts: [concepto_c]
    depends_on: [ex-01-nombre]
    variables_created: [var3]
  # ... todos los ejercicios creados

# ESPECIFICACION DEL PROXIMO MODULO - Claude Code debe seguir esto
next_module_spec:
  id: module-XX
  title: "Titulo del Modulo"
  
  prerequisites_from_previous:
    - "Descripcion de lo que el estudiante ya sabe"
    - "Otra habilidad adquirida"
  
  new_concepts_to_introduce:
    - nuevo_concepto_1
    - nuevo_concepto_2
  
  dataset_transition:
    from: dataset_anterior.csv
    to: dataset_nuevo.csv
    reason: "Por que se cambia de dataset"
  
  exercises_planned:
    - id: ex-XX-nombre
      builds_on: ex-YY-anterior
      new_challenge: "Que nuevo aprende el estudiante"
    
    - id: ex-XX-otro
      new_concepts: [concepto_nuevo]
  
  estimated_exercises: N
  estimated_lessons: M

# Estilo pedagogico del curso - MANTENER CONSISTENTE
pedagogical_style:
  lesson_structure:
    - "Introduccion breve (2-3 parrafos, sin fluff)"
    - "Codigo de ejemplo comentado"
    - "Ejercicio embebido <!-- exercise:id -->"
    - "Tip o nota de buenas practicas"
    - "Conexion con siguiente tema"
  
  exercise_difficulty_curve:
    beginner: "Copy-paste con 1 cambio"
    intermediate: "Completar funcion con hints"
    advanced: "Implementar desde cero con especificacion"
  
  hints_policy:
    count: 3
    progression:
      - "Que funcion/metodo usar"
      - "Sintaxis basica o firma"
      - "Solucion casi completa"
  
  feedback_tone: "Directo, sin condescendencia, celebra brevemente el exito"
```

### Validacion de Coherencia

Antes de hacer commit, verificar:

| Check | Comando/Accion |
|-------|----------------|
| Ejercicios existen | Cada ID en `exercises_registry` tiene archivo YAML |
| Dependencias validas | `depends_on` referencia ejercicios anteriores |
| Conceptos ordenados | No se usa un concepto antes de introducirlo |
| Variables consistentes | Mismos nombres en todo el curso |
| Imports acumulativos | Cada modulo agrega, no redefine |

### Ejemplo de Flujo de Trabajo

```
Sesion 1: Crear Modulo 1
├── Crear COURSE_STATE.yaml con estructura inicial
├── Definir code_conventions y pedagogical_style
├── Crear lecciones y ejercicios del modulo
├── Poblar exercises_registry
└── Escribir next_module_spec para Modulo 2

Sesion 2: Crear Modulo 2  
├── LEER COURSE_STATE.yaml primero ← OBLIGATORIO
├── Verificar prerequisites_from_previous
├── Crear contenido siguiendo next_module_spec
├── Actualizar exercises_registry (agregar nuevos)
├── Actualizar concepts_introduced
└── Escribir next_module_spec para Modulo 3

Sesion N: Crear Modulo N
└── ... mismo patron
```

### Errores Comunes a Evitar

| Error | Consecuencia | Prevencion |
|-------|--------------|------------|
| No leer COURSE_STATE | Conceptos duplicados o desordenados | Siempre leer primero |
| Cambiar variable_names | Codigo inconsistente, confunde estudiante | Respetar code_conventions |
| Saltar next_module_spec | Ejercicios sin progresion logica | Seguir la especificacion |
| No actualizar al terminar | Proxima sesion pierde contexto | Actualizar antes de commit |
| Introducir concepto futuro | Rompe curva de aprendizaje | Verificar concepts_introduced |

---

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
│   └── [curso]/
│       ├── COURSE_STATE.yaml  ← CONTRATO
│       ├── course.yaml
│       └── module-XX/
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
| Curso | Slug | Ejercicios | Tiene COURSE_STATE |
|-------|------|------------|-------------------|
| Introduccion a Python | python-data-science | 13 | Pendiente migrar |

## Documentacion
- `README.md` - Documentacion publica
- `CLAUDE.md` - Este archivo (contexto rapido + contratos)
- `CLAUDE_COURSE_GUIDE.md` - Guia completa para crear cursos
- `COURSE_STATE.yaml` - Contrato por curso (en cada carpeta de curso)
