# Guia para Crear Cursos en EduPlatform

**Documento de contexto para Claude Code**

Este documento contiene toda la informacion necesaria para crear un nuevo curso con ejercicios interactivos en EduPlatform desde una sesion nueva de Claude Code.

---

## IMPORTANTE: Credenciales Locales

Antes de comenzar, lee el archivo de credenciales:
```bash
cat ~/.edu-platform-credentials
```

Este archivo contiene:
- URLs y claves de Supabase
- Token de acceso para CLI
- Rutas del proyecto
- IDs de cursos existentes
- Comandos utiles

**NO se necesita Connection String URI ni conexion directa a PostgreSQL.**
- Frontend usa Supabase JS Client (`NEXT_PUBLIC_SUPABASE_URL` + `ANON_KEY`)
- Migraciones usan `supabase db push --linked` con `SUPABASE_ACCESS_TOKEN`

---

## Tabla de Contenidos

1. [Resumen del Proyecto](#resumen-del-proyecto)
2. [Arquitectura del Sistema de Ejercicios](#arquitectura-del-sistema-de-ejercicios)
3. [Paso a Paso: Crear un Nuevo Curso](#paso-a-paso-crear-un-nuevo-curso)
4. [Referencia de Formatos](#referencia-de-formatos)
5. [Agregar a la Base de Datos](#agregar-a-la-base-de-datos)
6. [Deploy](#deploy)
7. [Troubleshooting](#troubleshooting)

---

## Resumen del Proyecto

### Repositorio
```
https://github.com/gonzalezulises/edu-platform.git
```

### Stack
- **Frontend**: Next.js 14 (App Router)
- **Base de datos**: Supabase (PostgreSQL)
- **Ejercicios Python**: Pyodide (WebAssembly)
- **Ejercicios SQL**: sql.js (WebAssembly)
- **Editor de codigo**: Monaco Editor
- **Deploy**: Vercel (automatico con push a main)

### Tipos de Ejercicios Soportados
| Tipo | Runtime | Descripcion |
|------|---------|-------------|
| `code-python` | Pyodide | Ejecuta Python en el navegador |
| `sql` | sql.js | Ejecuta SQL en SQLite |
| `colab` | Google Colab | Abre notebook externo |
| `quiz` | N/A | Preguntas de opcion multiple |

---

## Arquitectura del Sistema de Ejercicios

### Flujo de Datos

```
1. Usuario accede a leccion
   ↓
2. LessonPlayer carga contenido desde DB (markdown con embeds)
   ↓
3. MarkdownRenderer detecta <!-- exercise:id -->
   ↓
4. Exercise component hace fetch a /api/exercises/[id]
   ↓
5. API carga YAML desde content/courses/[curso]/[modulo]/exercises/
   ↓
6. CodePlayground renderiza editor + ejecuta tests
```

### Estructura de Archivos

```
edu-platform/
├── content/
│   ├── courses/
│   │   └── [curso-slug]/              # Ej: python-data-science
│   │       ├── course.yaml            # Metadata del curso
│   │       └── module-01/
│   │           ├── module.yaml        # Metadata del modulo
│   │           ├── lessons/
│   │           │   ├── 01-tema.md     # Leccion con embeds
│   │           │   └── 02-tema.md
│   │           └── exercises/
│   │               ├── ex-01-nombre.yaml
│   │               └── ex-02-nombre.yaml
│   └── shared/
│       ├── datasets/                  # CSVs compartidos
│       └── schemas/                   # Schemas SQL
├── supabase/
│   └── migrations/                    # SQL para base de datos
└── src/
    ├── app/api/exercises/[exerciseId]/route.ts
    ├── components/exercises/
    ├── hooks/usePyodide.ts
    └── lib/content/loaders.ts
```

### Componentes Clave

| Archivo | Funcion |
|---------|---------|
| `src/components/exercises/CodePlayground.tsx` | Editor Monaco + runner Pyodide |
| `src/components/exercises/SQLPlayground.tsx` | Editor Monaco + runner sql.js |
| `src/components/exercises/Exercise.tsx` | Orquestador que decide que playground usar |
| `src/components/course/MarkdownRenderer.tsx` | Parsea markdown y renderiza ejercicios |
| `src/lib/content/embed-parser.ts` | Detecta `<!-- exercise:id -->` en markdown |
| `src/lib/content/loaders.ts` | Carga YAML con js-yaml |
| `src/hooks/usePyodide.ts` | Hook para cargar y ejecutar Python |
| `src/app/api/exercises/[exerciseId]/route.ts` | API que sirve ejercicios |

### Implementacion Tecnica del Sistema Interactivo

#### Pyodide (Python en el Navegador)

**Que es:** Pyodide es CPython compilado a WebAssembly. Permite ejecutar Python real en el navegador sin servidor.

**Como funciona en este proyecto:**

```typescript
// src/hooks/usePyodide.ts

// 1. Carga Pyodide desde CDN (~8MB primera vez, luego cacheado)
const pyodide = await loadPyodide({
  indexURL: "https://cdn.jsdelivr.net/pyodide/v0.24.1/full/"
})

// 2. Instala paquetes con micropip (equivalente a pip)
await pyodide.loadPackage("micropip")
const micropip = pyodide.pyimport("micropip")
await micropip.install(["pandas", "numpy"])

// 3. Ejecuta codigo del usuario
const result = await pyodide.runPythonAsync(userCode)

// 4. Captura stdout/stderr
pyodide.setStdout({ batched: (text) => setOutput(text) })
```

**Paquetes disponibles:** numpy, pandas, matplotlib, scipy, scikit-learn (se cargan bajo demanda)

#### Monaco Editor

**Que es:** El mismo editor de VS Code, embebido en React.

**Configuracion usada:**

```tsx
// src/components/exercises/CodePlayground.tsx

import Editor from '@monaco-editor/react'

<Editor
  height="300px"
  language="python"           // Syntax highlighting
  theme="vs-dark"             // Tema oscuro
  value={code}
  onChange={setCode}
  options={{
    minimap: { enabled: false },
    fontSize: 14,
    lineNumbers: 'on',
    automaticLayout: true,
    tabSize: 4,
  }}
/>
```

#### Ejecucion de Tests

Los tests se definen en YAML y se ejecutan en el contexto del codigo del usuario:

```yaml
# exercises/ex-01.yaml
test_cases:
  - id: test-output
    name: "Verifica output"
    test_code: |
      import sys
      from io import StringIO

      # Capturar stdout
      old_stdout = sys.stdout
      sys.stdout = StringIO()

      # El codigo del usuario ya se ejecuto, verificar resultado
      assert 'resultado' in dir(), "Variable 'resultado' no definida"
      assert resultado == 42, f"Esperado 42, obtenido {resultado}"

      sys.stdout = old_stdout
    points: 10
```

**Flujo de ejecucion:**
1. Usuario escribe codigo en Monaco
2. Click en "Ejecutar" → codigo se envia a Pyodide
3. Pyodide ejecuta codigo del usuario
4. Luego ejecuta cada test_code en el mismo contexto
5. Si test pasa → puntos sumados
6. Resultados se muestran en UI

#### SQL Playground (sql.js)

**Que es:** SQLite compilado a WebAssembly.

```typescript
// src/hooks/useSQLite.ts

import initSqlJs from 'sql.js'

// 1. Inicializar sql.js
const SQL = await initSqlJs({
  locateFile: file => `https://sql.js.org/dist/${file}`
})

// 2. Crear base de datos en memoria
const db = new SQL.Database()

// 3. Cargar schema y datos
db.run(schemaSQL)
db.run(insertDataSQL)

// 4. Ejecutar query del usuario
const results = db.exec(userQuery)
```

#### Dependencias del Sistema

```json
// package.json (relevantes para ejercicios)
{
  "dependencies": {
    "@monaco-editor/react": "^4.6.0",  // Editor de codigo
    "pyodide": "^0.24.1",              // Python WASM
    "sql.js": "^1.9.0",                // SQLite WASM
    "js-yaml": "^4.1.0",               // Parser de YAML
    "react-markdown": "^9.0.1",        // Render markdown
    "remark-gfm": "^4.0.0"             // GitHub Flavored Markdown
  }
}
```

#### Diagrama de Componentes

```
┌─────────────────────────────────────────────────────────────┐
│                        LessonPlayer                          │
│  (src/components/course/LessonPlayer.tsx)                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     MarkdownRenderer                         │
│  - Parsea markdown                                          │
│  - Detecta <!-- exercise:id -->                             │
│  - Renderiza Exercise component                             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Exercise                              │
│  - Fetch /api/exercises/[id]                                │
│  - Decide que playground renderizar                         │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
┌───────────────────┐ ┌──────────────┐ ┌──────────────┐
│  CodePlayground   │ │ SQLPlayground│ │ ColabLauncher│
│  - Monaco Editor  │ │ - Monaco     │ │ - Link Colab │
│  - usePyodide()   │ │ - useSQLite()│ │              │
│  - Test runner    │ │ - Tabla res  │ │              │
└───────────────────┘ └──────────────┘ └──────────────┘
         │                    │
         ▼                    ▼
┌───────────────────┐ ┌──────────────┐
│     Pyodide       │ │    sql.js    │
│  (WebAssembly)    │ │ (WebAssembly)│
└───────────────────┘ └──────────────┘
```

---

## Paso a Paso: Crear un Nuevo Curso

### Paso 1: Crear Estructura de Carpetas

```bash
# Desde la raiz del proyecto
mkdir -p content/courses/[curso-slug]/module-01/lessons
mkdir -p content/courses/[curso-slug]/module-01/exercises
```

**Ejemplo para curso de SQL:**
```bash
mkdir -p content/courses/sql-fundamentals/module-01/lessons
mkdir -p content/courses/sql-fundamentals/module-01/exercises
```

### Paso 2: Crear course.yaml

```yaml
# content/courses/[curso-slug]/course.yaml

id: sql-fundamentals
title: "Fundamentos de SQL"
description: "Aprende SQL desde cero con ejercicios practicos"
slug: sql-fundamentals
thumbnail_url: "https://example.com/sql-logo.png"
is_published: true
instructor_id: null

exercise_config:
  default_runtime: pyodide
  allow_solution_view: true
  max_attempts: null

modules:
  - id: module-01
    title: "Consultas Basicas"
    description: "SELECT, WHERE, ORDER BY"
    order: 1

prerequisites: []

tags:
  - sql
  - bases-de-datos
  - principiantes
```

### Paso 3: Crear module.yaml

```yaml
# content/courses/[curso-slug]/module-01/module.yaml

id: module-01
title: "Consultas Basicas"
description: "Aprende a hacer consultas SELECT"
order: 1

lessons:
  - id: lesson-01
    file: lessons/01-select.md
    title: "Tu primera consulta"
    type: text
    order: 1
  - id: lesson-02
    file: lessons/02-where.md
    title: "Filtrar con WHERE"
    type: text
    order: 2

exercises:
  - id: ex-01-select-basico
    file: exercises/ex-01-select-basico.yaml
    lesson_id: lesson-01
  - id: ex-02-where-numeros
    file: exercises/ex-02-where-numeros.yaml
    lesson_id: lesson-02
```

### Paso 4: Crear Lecciones (Markdown)

```markdown
<!-- content/courses/[curso-slug]/module-01/lessons/01-select.md -->

# Tu Primera Consulta SQL

SQL (Structured Query Language) es el lenguaje para trabajar con bases de datos.

## La sentencia SELECT

Para obtener datos de una tabla usamos `SELECT`:

```sql
SELECT columna1, columna2
FROM tabla;
```

### Ejemplo

```sql
SELECT nombre, edad
FROM usuarios;
```

## Ejercicio: Tu primer SELECT

Practica haciendo tu primera consulta:

<!-- exercise:ex-01-select-basico -->

## Siguiente tema

Ahora aprenderemos a filtrar resultados...
```

**IMPORTANTE:** Los ejercicios se insertan con el comentario HTML:
```
<!-- exercise:id-del-ejercicio -->
```

### Paso 5: Crear Ejercicios (YAML)

#### Ejercicio Python

```yaml
# content/courses/[curso-slug]/module-01/exercises/ex-01-hola.yaml

id: ex-01-hola
type: code-python
title: "Hola Mundo"
description: "Tu primer programa en Python"
instructions: |
  Escribe un programa que imprima "Hola, Mundo!" usando la funcion print().

difficulty: beginner
estimated_time_minutes: 5
points: 10
runtime_tier: pyodide

starter_code: |
  # Escribe tu codigo aqui


solution_code: |
  print("Hola, Mundo!")

test_cases:
  - id: test-output
    name: "Output correcto"
    test_code: |
      import sys
      from io import StringIO
      old_stdout = sys.stdout
      sys.stdout = StringIO()
      exec(user_code)
      output = sys.stdout.getvalue().strip()
      sys.stdout = old_stdout
      assert output == "Hola, Mundo!", f"Esperado 'Hola, Mundo!' pero obtuviste '{output}'"
    points: 10

hints:
  - "Usa la funcion print()"
  - "El texto debe ir entre comillas: print(\"texto\")"
  - "Asegurate de escribir exactamente 'Hola, Mundo!'"

tags:
  - python
  - print
  - basico
```

#### Ejercicio SQL

```yaml
# content/courses/[curso-slug]/module-01/exercises/ex-01-select.yaml

id: ex-01-select
type: sql
title: "SELECT basico"
description: "Selecciona todos los registros"
instructions: |
  Escribe una consulta que seleccione todas las columnas de la tabla `usuarios`.

difficulty: beginner
estimated_time_minutes: 5
points: 10
runtime_tier: pyodide  # sql.js usa este valor por compatibilidad
schema_id: usuarios    # Referencia a shared/schemas/usuarios.sql

starter_code: |
  -- Escribe tu consulta aqui
  SELECT

solution_code: |
  SELECT * FROM usuarios;

expected_output:
  columns: ["id", "nombre", "edad"]
  rows_count: 3

test_cases:
  - id: test-columns
    name: "Columnas correctas"
    test_code: |
      assert len(result.columns) >= 3
    points: 5
  - id: test-rows
    name: "Filas correctas"
    test_code: |
      assert len(result.rows) == 3
    points: 5

hints:
  - "Usa SELECT * para seleccionar todas las columnas"
  - "FROM indica de que tabla"

tags:
  - sql
  - select
```

#### Ejercicio Colab

```yaml
id: ex-ml-01
type: colab
title: "Entrenamiento con GPU"
description: "Entrena un modelo en Google Colab"
instructions: |
  Este ejercicio requiere GPU. Haz clic para abrir en Colab.

difficulty: advanced
estimated_time_minutes: 30
points: 50
runtime_tier: colab

colab_url: "https://colab.research.google.com/drive/xxx"
colab_instructions: |
  1. Ejecuta todas las celdas
  2. Guarda el modelo entrenado
  3. Vuelve aqui y marca como completado

tags:
  - machine-learning
  - gpu
```

### Paso 6: Crear Schema SQL (si aplica)

```sql
-- content/shared/schemas/usuarios.sql

CREATE TABLE usuarios (
  id INTEGER PRIMARY KEY,
  nombre TEXT NOT NULL,
  edad INTEGER
);

INSERT INTO usuarios (id, nombre, edad) VALUES
  (1, 'Ana', 25),
  (2, 'Carlos', 30),
  (3, 'Maria', 28);
```

---

## Agregar a la Base de Datos

### Opcion A: Migracion SQL (Recomendado)

Crear archivo en `supabase/migrations/`:

```sql
-- supabase/migrations/20251225000010_seed_[curso].sql

-- 1. Insertar curso
INSERT INTO courses (id, title, description, thumbnail_url, is_published)
VALUES (
  'uuid-del-curso',
  'Titulo del Curso',
  'Descripcion completa del curso...',
  'https://url-del-thumbnail.png',
  true
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  is_published = EXCLUDED.is_published;

-- 2. Insertar modulo
INSERT INTO modules (id, course_id, title, description, order_index, is_locked)
VALUES (
  'uuid-del-modulo',
  'uuid-del-curso',
  'Titulo del Modulo',
  'Descripcion del modulo',
  1,
  false
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description;

-- 3. Insertar lecciones
INSERT INTO lessons (id, course_id, module_id, title, content, lesson_type, order_index, duration_minutes, is_required, video_url)
VALUES
  (
    'uuid-leccion-1',
    'uuid-del-curso',
    'uuid-del-modulo',
    'Titulo de la Leccion',
    $CONTENT$
# Contenido Markdown completo aqui

Con ejercicios embebidos:

<!-- exercise:ex-01-nombre -->

Mas contenido...
$CONTENT$,
    'text',
    1,
    20,
    true,
    'https://youtube.com/embed/xxx'
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  content = EXCLUDED.content;
```

**NOTA:** Usa `$CONTENT$...$CONTENT$` para contenido multilinea con caracteres especiales.

### Aplicar Migracion

**Paso 1: Verificar que el proyecto esta linkeado**

```bash
cd /Users/ulisesgonzalez/Documents/data_science_projects/edu-platform

# Verificar estado del link
cat supabase/.temp/project-ref
# Debe mostrar: mcssewqlcyfsuznuvtmh
```

Si no esta linkeado:
```bash
source .env.local && supabase link --project-ref mcssewqlcyfsuznuvtmh
```

**Paso 2: Aplicar migraciones**

```bash
source .env.local && supabase db push --linked
```

**Paso 3: Verificar migraciones aplicadas**

```bash
source .env.local && supabase migration list
```

### Verificar en Supabase Dashboard

Despues de aplicar, verifica los datos en:
- https://supabase.com/dashboard/project/mcssewqlcyfsuznuvtmh/editor

Tablas a verificar:
- `courses` - nuevo curso insertado
- `modules` - modulos del curso
- `lessons` - lecciones con contenido markdown

---

## Deploy

### 1. Verificar Build

```bash
npm run build
```

### 2. Commit y Push

```bash
git add -A
git commit -m "feat: add [nombre-curso] course with [N] exercises"
git push origin main
```

### 3. Verificar en Vercel

El deploy es automatico. Verificar en:
- Dashboard de Vercel
- `npx vercel list`

---

## Troubleshooting

### Ejercicio no aparece

1. Verificar que el ID en `<!-- exercise:id -->` coincide con el `id:` en el YAML
2. Verificar que el archivo YAML esta en `content/courses/[curso]/module-XX/exercises/`
3. Verificar que el curso usa `courseSlug` correcto en LessonPlayer

### Error "Exercise not found"

1. Revisar consola del navegador para ver la URL de la API
2. Verificar que el archivo YAML existe y tiene sintaxis correcta
3. Probar la API directamente: `/api/exercises/[id]?course=[slug]&module=module-01`

### Pyodide no carga

1. Pyodide pesa ~8MB, puede tardar en la primera carga
2. Verificar conexion a internet (CDN de Pyodide)
3. Revisar consola para errores de red

### Tests no pasan

1. Los tests se ejecutan en el contexto del codigo del usuario
2. Usar `assert` para validaciones
3. Capturar stdout si necesitas verificar output:
```python
import sys
from io import StringIO
old_stdout = sys.stdout
sys.stdout = StringIO()
exec(user_code)
output = sys.stdout.getvalue()
sys.stdout = old_stdout
```

### RLS bloquea inserts

Si la migracion SQL falla por RLS:
1. Las migraciones via `supabase db push` se ejecutan con permisos elevados (bypass RLS)
2. Siempre usa migraciones SQL, no scripts JS con el cliente
3. Si necesitas insertar desde la app, verifica las policies en Supabase Dashboard

---

## Checklist para Nuevo Curso

### Contenido
- [ ] Crear carpetas: `content/courses/[slug]/module-01/{lessons,exercises}`
- [ ] Crear `course.yaml` con metadata
- [ ] Crear `module.yaml` con lista de lecciones y ejercicios
- [ ] Crear archivos `.md` para cada leccion
- [ ] Crear archivos `.yaml` para cada ejercicio
- [ ] Insertar `<!-- exercise:id -->` en las lecciones

### Base de Datos (Supabase)
- [ ] Verificar link: `cat supabase/.temp/project-ref` (debe mostrar `mcssewqlcyfsuznuvtmh`)
- [ ] Si no esta linkeado: `source .env.local && supabase link --project-ref mcssewqlcyfsuznuvtmh`
- [ ] Crear migracion SQL en `supabase/migrations/YYYYMMDDHHMMSS_seed_[curso].sql`
- [ ] Aplicar: `source .env.local && supabase db push --linked`
- [ ] Verificar: `source .env.local && supabase migration list`

### Deploy
- [ ] Verificar build: `npm run build`
- [ ] Commit y push a main
- [ ] Verificar deploy en Vercel

---

## Ejemplo Completo: Curso de Python

El curso "Introduccion a Python" sirve como referencia:

```
content/courses/python-data-science/
├── course.yaml
└── module-01/
    ├── module.yaml
    ├── lessons/
    │   ├── 01-variables.md      # 3 ejercicios embebidos
    │   ├── 02-operadores.md     # 2 ejercicios
    │   ├── 03-control-flujo.md  # 2 ejercicios
    │   ├── 04-listas.md         # 3 ejercicios
    │   └── 05-funciones.md      # 3 ejercicios
    └── exercises/
        ├── ex-01-hola-mundo.yaml
        ├── ex-02-variables-basicas.yaml
        ├── ex-03-tipos-datos.yaml
        ├── ex-04-aritmetica.yaml
        ├── ex-05-comparaciones.yaml
        ├── ex-06-if-else.yaml
        ├── ex-07-elif.yaml
        ├── ex-08-crear-lista.yaml
        ├── ex-09-for-loop.yaml
        ├── ex-10-while-loop.yaml
        ├── ex-11-funcion-simple.yaml
        ├── ex-12-funcion-parametros.yaml
        └── ex-13-funcion-return.yaml
```

**Total:** 5 lecciones, 13 ejercicios interactivos

---

## Contacto

Para dudas sobre el proyecto, revisar:
- `README.md` - Documentacion general
- `CLAUDE.md` - Contexto rapido para Claude Code
- Codigo fuente en `src/`

---

*Documento generado para uso con Claude Code*
