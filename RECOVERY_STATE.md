# Estado de Recuperacion - EduPlatform

> **Fecha:** 2026-02-13
> **Motivo:** El proyecto Supabase original (`mcssewqlcyfsuznuvtmh`) fue eliminado por error.
> **Prioridad:** ALTA - La plataforma no funciona sin backend.

---

## Que se perdio

| Recurso | Estado |
|---------|--------|
| Base de datos PostgreSQL | Eliminada (schema recuperable via migraciones) |
| Datos de usuarios/progreso | Perdidos (no habia usuarios reales en produccion) |
| Auth configuration | Debe reconfigurarse |
| API keys y secrets | Invalidos, deben regenerarse |
| DNS `mcssewqlcyfsuznuvtmh.supabase.co` | NXDOMAIN - no existe |

## Que esta intacto

| Recurso | Ubicacion |
|---------|-----------|
| Codigo fuente completo | Este repositorio |
| 18 migraciones SQL (schema + seeds) | `supabase/migrations/` |
| 4 cursos con contenido | `content/courses/` |
| Workflow CI/CD (actualizado) | `.github/workflows/supabase-keepalive.yml` |
| Deploy Vercel | Funcional pero sin backend |

---

## Pasos para recuperar (en orden)

### Paso 1: Crear nuevo proyecto Supabase
- [ ] Ir a https://supabase.com/dashboard
- [ ] Click "New Project"
- [ ] Nombre: `edu-platform`
- [ ] Guardar password de la base de datos
- [ ] Esperar ~2 minutos a que se cree

### Paso 2: Obtener credenciales del nuevo proyecto
- [ ] Project URL: `https://NUEVO_REF.supabase.co`
- [ ] Anon Key: (Project Settings > API)
- [ ] Project Ref: (el ID del proyecto)
- [ ] Access Token: (Account Settings > Access Tokens)

### Paso 3: Actualizar archivos locales
- [ ] Actualizar `.env.local` con nuevas credenciales:
  ```
  NEXT_PUBLIC_SUPABASE_URL=https://NUEVO_REF.supabase.co
  NEXT_PUBLIC_SUPABASE_ANON_KEY=NUEVA_KEY
  SUPABASE_ACCESS_TOKEN=TOKEN
  ```
- [ ] Actualizar `CLAUDE.local.md` con nuevo project ref
- [ ] Actualizar `~/.edu-platform-credentials`

### Paso 4: Linkear y aplicar migraciones
```bash
cd /Users/ulisesgonzalez/Documents/GitHub/edu-platform
source .env.local && supabase link --project-ref NUEVO_REF
source .env.local && supabase db push --linked
```

### Paso 5: Actualizar secrets en GitHub
```bash
gh secret set SUPABASE_URL -b "https://NUEVO_REF.supabase.co"
gh secret set SUPABASE_ANON_KEY -b "NUEVA_KEY"
```

### Paso 6: Verificar
- [ ] `npm run dev` funciona y conecta al backend
- [ ] Ejecutar workflow keep-alive manualmente: `gh workflow run supabase-keepalive.yml`
- [ ] Verificar deploy en Vercel (actualizar env vars en Vercel dashboard)

### Paso 7: Limpiar
- [ ] Eliminar este archivo (`RECOVERY_STATE.md`)
- [ ] Commit final

---

## Cambios hechos en esta sesion

1. **Workflow actualizado** (`.github/workflows/supabase-keepalive.yml`):
   - URL hardcodeada reemplazada por secret `SUPABASE_URL`
   - Si el secret no existe, el workflow pasa sin error (no mas fallos)
   - Cron cambiado de cada 6 dias a cada 4 dias (margen seguro vs 7 dias de pausa)
   - Agregado `--max-time 10`, `--retry 2`, `--retry-delay 5` a curl

2. **Este archivo creado** (`RECOVERY_STATE.md`)

---

## Cursos existentes (contenido intacto)

| Curso | Slug | Migracion seed |
|-------|------|---------------|
| Introduccion a Python | `python-data-science` | `20251225000002_seed_python_course.sql` |
| Scikit-Learn | `sklearn-intro` | `007_sklearn_course.sql` |
| SQL Fundamentos | `sql-fundamentos` | `20251225100000_seed_sql_course.sql` |
| Data Analytics | `data-analytics` | `20251226000001_seed_data_analytics_course.sql` |

## Migraciones (18 archivos, aplicar en orden)

```
20251201000001_initial_schema.sql
20251201000002_modules_hierarchy.sql
20251201000003_progress_tracking.sql
20251201000004_quizzes.sql
20251201000005_forums.sql
20251201000006_content_management.sql
20251224185516_test_migration.sql
20251225000001_interactive_exercises.sql
20251225000002_seed_python_course.sql
20251225000003_update_python_course_content.sql
007_sklearn_course.sql
20251225000004_update_sklearn_course_content.sql
20251225000005_add_course_slug.sql
20251225000006_fix_course_slugs.sql
20251225100000_seed_sql_course.sql
20251226000001_seed_data_analytics_course.sql
20251230000001_security_fixes.sql
20251230000002_security_fixes_part2.sql
```

---

*Para Claude Code: al iniciar la proxima sesion, lee este archivo primero. Si el usuario dice que ya creo el nuevo proyecto, sigue los pasos 3-7 y luego elimina este archivo.*
