# EduPlatform - Contexto del Proyecto

## Descripcion
Plataforma educativa con cursos, lecciones, autenticacion y tracking de progreso.

## Stack Tecnologico
- **Frontend**: Next.js 14 (App Router)
- **Base de datos**: Supabase (PostgreSQL)
- **Autenticacion**: Auth.js + Supabase Auth
- **Storage**: Supabase Storage
- **Estilos**: Tailwind CSS
- **Deploy**: Vercel con CI/CD automatico

## Funcionalidades
- Cursos y lecciones estructurados
- Login/registro con Auth.js
- Tracking de progreso por usuario
- Subida de archivos (videos, PDFs, imagenes)
- Roles: student, instructor, admin

## Estructura de Carpetas
```
src/
├── app/
│   ├── (auth)/login, register
│   ├── (dashboard)/courses, profile
│   └── api/auth
├── components/
├── lib/supabase/
└── types/
```

## Base de Datos (Supabase)
Tablas principales:
- `profiles` - Usuarios extendidos
- `courses` - Cursos
- `lessons` - Lecciones
- `progress` - Progreso del estudiante
- `enrollments` - Inscripciones

## Versionado
- Conventional Commits (feat, fix, docs, chore)
- Husky + Commitlint para validacion
- Standard Version para CHANGELOG automatico

## Seguridad
- Headers de seguridad en next.config.js
- Auditoria con https://web-check.xyz post-deploy
- RLS (Row Level Security) en Supabase

## Variables de Entorno Requeridas
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXTAUTH_SECRET=
NEXTAUTH_URL=
```

## Plan Completo
Ver: ~/.claude/plans/wiggly-baking-teapot.md

## Comandos Utiles
```bash
npm run dev      # Desarrollo local
npm run build    # Build de produccion
npm run lint     # Linter
npx standard-version  # Generar nueva version + CHANGELOG
```
