# EduPlatform

<p align="center">
  <a href="https://github.com/gonzalezulises/edu-platform/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License"/></a>
  <a href="https://github.com/gonzalezulises/edu-platform/pulls"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome"/></a>
  <a href="https://claude.ai"><img src="https://img.shields.io/badge/Made%20with-Claude%20Code-blueviolet?logo=anthropic&logoColor=white" alt="Made with Claude Code"/></a>
</p>

<p align="center">
  <a href="https://nextjs.org/"><img src="https://img.shields.io/badge/Next.js-14-black?logo=next.js&logoColor=white" alt="Next.js"/></a>
  <a href="https://react.dev/"><img src="https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black" alt="React"/></a>
  <a href="https://www.typescriptlang.org/"><img src="https://img.shields.io/badge/TypeScript-5-3178C6?logo=typescript&logoColor=white" alt="TypeScript"/></a>
  <a href="https://nodejs.org/"><img src="https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white" alt="Node.js"/></a>
  <a href="https://tailwindcss.com/"><img src="https://img.shields.io/badge/Tailwind_CSS-3-06B6D4?logo=tailwindcss&logoColor=white" alt="Tailwind CSS"/></a>
</p>

<p align="center">
  <a href="https://supabase.com/"><img src="https://img.shields.io/badge/Supabase-Database-3FCF8E?logo=supabase&logoColor=white" alt="Supabase"/></a>
  <a href="https://www.postgresql.org/"><img src="https://img.shields.io/badge/PostgreSQL-15-4169E1?logo=postgresql&logoColor=white" alt="PostgreSQL"/></a>
</p>

<p align="center">
  <a href="https://pyodide.org/"><img src="https://img.shields.io/badge/Pyodide-Python%20WASM-3776AB?logo=python&logoColor=white" alt="Pyodide"/></a>
  <a href="https://sql.js.org/"><img src="https://img.shields.io/badge/sql.js-SQLite%20WASM-003B57?logo=sqlite&logoColor=white" alt="sql.js"/></a>
  <a href="https://webassembly.org/"><img src="https://img.shields.io/badge/WebAssembly-Enabled-654FF0?logo=webassembly&logoColor=white" alt="WebAssembly"/></a>
  <a href="https://microsoft.github.io/monaco-editor/"><img src="https://img.shields.io/badge/Monaco-Editor-007ACC?logo=visualstudiocode&logoColor=white" alt="Monaco Editor"/></a>
  <a href="https://eslint.org/"><img src="https://img.shields.io/badge/ESLint-Configured-4B32C3?logo=eslint&logoColor=white" alt="ESLint"/></a>
</p>

<p align="center">
  <a href="https://vercel.com/"><img src="https://img.shields.io/badge/Vercel-Deploy-000000?logo=vercel&logoColor=white" alt="Vercel"/></a>
  <a href="https://colab.research.google.com/"><img src="https://img.shields.io/badge/Google_Colab-Integration-F9AB00?logo=googlecolab&logoColor=white" alt="Google Colab"/></a>
</p>

---

Plataforma educativa completa con cursos, evaluaciones, **ejercicios interactivos de codigo**, foros y tracking de progreso. Desarrollada con Next.js 14, Supabase y Tailwind CSS.

## Tabla de Contenidos

- [Descripcion General](#descripcion-general)
- [Stack Tecnologico](#stack-tecnologico)
- [Caracteristicas](#caracteristicas)
- [Sistema de Ejercicios Interactivos](#sistema-de-ejercicios-interactivos)
- [Estructura del Proyecto](#estructura-del-proyecto)
- [Base de Datos](#base-de-datos)
- [Creacion de Cursos](#creacion-de-cursos)
- [Instalacion](#instalacion)
- [Variables de Entorno](#variables-de-entorno)
- [Scripts Disponibles](#scripts-disponibles)

---

## Descripcion General

EduPlatform es una plataforma de aprendizaje en linea que permite a instructores crear cursos estructurados con modulos, lecciones, quizzes, **ejercicios de codigo interactivos** y recursos descargables. Los estudiantes pueden inscribirse, seguir su progreso, ejecutar codigo Python/SQL en el navegador y participar en foros.

### Roles de Usuario

| Rol | Permisos |
|-----|----------|
| **Student** | Inscribirse a cursos, ver lecciones, ejecutar ejercicios, tomar quizzes, participar en foros |
| **Instructor** | Todo lo anterior + crear/editar cursos, subir recursos, publicar anuncios |
| **Admin** | Todo lo anterior + gestionar usuarios y configuracion global |

---

## Stack Tecnologico

| Tecnologia | Uso |
|------------|-----|
| **Next.js 14** | Framework React con App Router y Server Components |
| **TypeScript** | Tipado estatico |
| **Supabase** | Base de datos PostgreSQL, autenticacion y storage |
| **Tailwind CSS** | Estilos utility-first |
| **Pyodide** | Python en el navegador (WebAssembly) |
| **sql.js** | SQLite en el navegador (WebAssembly) |
| **Monaco Editor** | Editor de codigo (el mismo de VS Code) |
| **Vercel** | Deploy con CI/CD automatico |

---

## Caracteristicas

### Gestion de Cursos
- Crear y editar cursos con thumbnail
- Organizar contenido en modulos y lecciones
- Soporte para video (YouTube embebido), texto y recursos
- Publicar/despublicar cursos

### Sistema de Ejercicios Interactivos
- **Python Playground**: Ejecutar Python en el navegador con Pyodide
- **SQL Playground**: Ejecutar SQL con sql.js
- **Google Colab Integration**: Lanzar notebooks en Colab
- Editor Monaco con syntax highlighting
- Tests automatizados con puntuacion
- Hints progresivos

### Sistema de Evaluaciones
- Quizzes con multiples tipos de preguntas (MCQ, verdadero/falso, respuesta corta)
- Limite de intentos y tiempo
- Retroalimentacion inmediata
- Calificacion automatica

### Tracking de Progreso
- Progreso por leccion, ejercicio y curso
- Dashboard personal con cursos en progreso
- Boton "Continuar donde quede"
- Estadisticas de tiempo invertido

### Foros y Comunicacion
- Foro por curso para dudas y discusion
- Respuestas anidadas (hasta 3 niveles)
- Marcar respuestas como solucion
- Sistema de notificaciones en tiempo real

### Recursos Descargables
- Subida de archivos por leccion (PDF, Word, Excel, PowerPoint, imagenes)
- Drag & drop para upload
- Contador de descargas

---

## Sistema de Ejercicios Interactivos

### Arquitectura

```
content/
  courses/
    python-data-science/          # Curso
      course.yaml                 # Configuracion del curso
      module-01/                  # Modulo
        module.yaml               # Configuracion del modulo
        lessons/                  # Lecciones en Markdown
          01-variables.md
        exercises/                # Ejercicios en YAML
          ex-01-hola-mundo.yaml
  shared/
    datasets/                     # CSVs compartidos
    schemas/                      # Schemas SQL
```

### Formato de Ejercicio (YAML)

```yaml
id: ex-01-hola-mundo
type: code-python              # code-python | sql | colab | quiz
title: "Tu primer programa"
description: "Aprende a usar print()"
instructions: |
  Escribe un programa que imprima "Hola, Mundo!"
difficulty: beginner           # beginner | intermediate | advanced
estimated_time_minutes: 5
points: 10
runtime_tier: pyodide          # pyodide | jupyterlite | colab

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
      # Capturar output y verificar
    points: 10

hints:
  - "Usa la funcion print()"
  - "El texto va entre comillas"

tags:
  - python-basico
  - print
```

### Embeds en Markdown

Los ejercicios se insertan en las lecciones con comentarios HTML:

```markdown
# Variables y Tipos de Datos

Aprende sobre variables en Python...

## Ejercicio: Tu primer print

<!-- exercise:ex-01-hola-mundo -->

## Siguiente tema...
```

### Componentes Clave

| Componente | Ubicacion | Funcion |
|------------|-----------|---------|
| `CodePlayground` | `src/components/exercises/` | Editor + runner Python |
| `SQLPlayground` | `src/components/exercises/` | Editor + runner SQL |
| `Exercise` | `src/components/exercises/` | Orquestador de tipos |
| `usePyodide` | `src/hooks/` | Hook para Python runtime |
| `useSQLite` | `src/hooks/` | Hook para SQL runtime |
| `MarkdownRenderer` | `src/components/course/` | Parser de embeds |
| `embed-parser` | `src/lib/content/` | Detecta `<!-- exercise:id -->` |
| `loaders` | `src/lib/content/` | Carga YAML y datasets |

### API de Ejercicios

```
GET /api/exercises/[exerciseId]?course=slug&module=module-id

Response:
{
  "exercise": { ... },      // Sin solution_code
  "datasets": { ... },      // CSVs cargados
  "schema": "..."           // Schema SQL si aplica
}
```

---

## Estructura del Proyecto

```
edu-platform/
├── src/
│   ├── app/
│   │   ├── (auth)/login, register
│   │   ├── (dashboard)/
│   │   │   ├── courses/[id]/lessons/[lessonId]/
│   │   │   └── dashboard/
│   │   └── api/exercises/[exerciseId]/
│   ├── components/
│   │   ├── exercises/          # Playgrounds interactivos
│   │   ├── course/             # MarkdownRenderer, LessonPlayer
│   │   └── ...
│   ├── hooks/
│   │   ├── usePyodide.ts       # Python runtime
│   │   └── useSQLite.ts        # SQL runtime
│   ├── lib/
│   │   ├── content/            # Loaders y parsers
│   │   └── supabase/
│   └── types/
│       ├── index.ts
│       └── exercises.ts
├── content/                    # Contenido declarativo
│   ├── courses/
│   └── shared/
├── config/
│   └── environments.yaml       # Config de runtimes
├── supabase/
│   └── migrations/
├── CLAUDE.md                   # Contexto para Claude Code
├── CLAUDE_COURSE_GUIDE.md      # Guia para crear cursos
└── package.json
```

---

## Base de Datos

### Tablas Principales

| Tabla | Descripcion |
|-------|-------------|
| `profiles` | Usuarios con roles |
| `courses` | Cursos con instructor |
| `modules` | Modulos dentro de cursos |
| `lessons` | Lecciones con contenido markdown |
| `enrollments` | Inscripciones |
| `progress` | Progreso por leccion |
| `exercise_progress` | Progreso por ejercicio interactivo |

### Tabla exercise_progress

```sql
CREATE TABLE exercise_progress (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES profiles(id),
  exercise_id TEXT NOT NULL,
  status TEXT DEFAULT 'not_started',  -- not_started, in_progress, completed, failed
  current_code TEXT,                   -- Ultimo codigo guardado
  attempts INTEGER DEFAULT 0,
  score DECIMAL(10,2),
  max_score DECIMAL(10,2),
  test_results JSONB DEFAULT '[]',
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  UNIQUE(user_id, exercise_id)
);
```

---

## Creacion de Cursos

Ver **[CLAUDE_COURSE_GUIDE.md](CLAUDE_COURSE_GUIDE.md)** para instrucciones detalladas sobre:

- Crear un nuevo curso con ejercicios interactivos
- Estructura de archivos YAML
- Agregar al base de datos
- Deploy

---

## Instalacion

```bash
# Clonar repositorio
git clone https://github.com/gonzalezulises/edu-platform.git
cd edu-platform

# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env.local

# Iniciar servidor de desarrollo
npm run dev
```

---

## Variables de Entorno

```env
NEXT_PUBLIC_SUPABASE_URL=https://tu-proyecto.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=tu-anon-key
SUPABASE_SERVICE_ROLE_KEY=tu-service-role-key
SUPABASE_ACCESS_TOKEN=tu-access-token  # Para CLI
```

---

## Scripts Disponibles

| Comando | Descripcion |
|---------|-------------|
| `npm run dev` | Servidor de desarrollo |
| `npm run build` | Build de produccion |
| `npm run lint` | Ejecutar ESLint |
| `node scripts/seed-python-course.mjs` | Seed de curso Python |

### Supabase CLI

```bash
# Aplicar migraciones
source .env.local && supabase db push --linked

# Ver estado de migraciones
source .env.local && supabase migration list
```

---

## Deploy

El proyecto se despliega automaticamente en **Vercel** con cada push a `main`.

**Importante:** Los archivos en `content/` se incluyen en el build y estan disponibles para la API.

---

## Cursos Disponibles

| Curso | Modulos | Ejercicios | Estado |
|-------|---------|------------|--------|
| Introduccion a Python | 1 | 13 | Publicado |
| Introduccion a Scikit-Learn | 4 | 10 | Publicado |
| Fundamentos de SQL | 1 | 16 | Publicado |

**Total:** 6 modulos, 39 ejercicios interactivos

---

## Licencia

Este proyecto esta licenciado bajo la **MIT License** - ver el archivo [LICENSE](LICENSE) para mas detalles.

---

## Autor

**Ulises Gonzalez** - *Fundador de Rizoma* @ [Rizo.ma](https://rizo.ma)

[![Website](https://img.shields.io/badge/Website-ulises--gonzalez-blue?style=flat-square&logo=google-chrome&logoColor=white)](https://ulises-gonzalez-site.vercel.app)
[![GitHub](https://img.shields.io/badge/GitHub-gonzalezulises-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/gonzalezulises)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-ulisesgonzalez-0A66C2?style=flat-square&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ulisesgonzalez/)
[![Kaggle](https://img.shields.io/badge/Kaggle-ulisesgonzalez-20BEFF?style=flat-square&logo=kaggle&logoColor=white)](https://www.kaggle.com/ulisesgonzalez)
[![Medium](https://img.shields.io/badge/Medium-gonzalezulises-000000?style=flat-square&logo=medium&logoColor=white)](https://medium.com/@gonzalezulises)

[![Email](https://img.shields.io/badge/Email-ulises%40rizo.ma-EA4335?style=flat-square&logo=gmail&logoColor=white)](mailto:ulises@rizo.ma)
[![Calendly](https://img.shields.io/badge/Calendly-Schedule%20Meeting-006BFF?style=flat-square&logo=calendly&logoColor=white)](https://calendly.com/gonzalezulises)

---

## Creditos

Desarrollado con asistencia de **Claude Code** (Anthropic).



---

<p align="center">
  <sub>Built with passion in Panama</sub>
</p>
