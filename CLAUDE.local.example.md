# Configuracion Local - EduPlatform

> **IMPORTANTE:** Copia este archivo a `CLAUDE.local.md` y reemplaza los placeholders con tus valores.
> El archivo `CLAUDE.local.md` esta en `.gitignore` y NO se sube al repositorio.

---

## Instrucciones de Configuracion

1. Copia este archivo:
   ```bash
   cp CLAUDE.local.example.md CLAUDE.local.md
   ```

2. Reemplaza los placeholders:
   - `{{PROJECT_PATH}}` - Ruta absoluta a tu copia del proyecto
   - `{{CREDENTIALS_PATH}}` - Ruta a tu archivo de credenciales (ej: `~/.edu-platform-credentials`)
   - `{{SUPABASE_PROJECT_REF}}` - ID de tu proyecto Supabase (lo encuentras en Project Settings)
   - `{{GITHUB_USERNAME}}` - Tu usuario de GitHub (para el fork)

3. Crea tu archivo de credenciales (ver seccion Credenciales)

4. Alternativamente, ejecuta el script de setup:
   ```bash
   ./scripts/setup-local.sh
   ```

---

## Referencia Rapida

| Variable | Valor |
|----------|-------|
| **PROJECT_PATH** | `{{PROJECT_PATH}}` |
| **CREDENTIALS_PATH** | `{{CREDENTIALS_PATH}}` |
| **SUPABASE_PROJECT_REF** | `{{SUPABASE_PROJECT_REF}}` |
| **SUPABASE_DASHBOARD** | `https://supabase.com/dashboard/project/{{SUPABASE_PROJECT_REF}}/editor` |
| **GITHUB_REPO** | `https://github.com/{{GITHUB_USERNAME}}/edu-platform.git` |

---

## Iniciar Sesion de Claude Code

### Opcion Recomendada

```bash
cd {{PROJECT_PATH}}
claude
```

### Con Ruta Absoluta

```bash
claude "Lee {{PROJECT_PATH}}/CLAUDE_COURSE_GUIDE.md y {{CREDENTIALS_PATH}}. Quiero crear un curso de [TEMA]."
```

---

## Rutas Importantes

| Recurso | Ruta Absoluta |
|---------|---------------|
| Proyecto | `{{PROJECT_PATH}}` |
| Guia de cursos | `{{PROJECT_PATH}}/CLAUDE_COURSE_GUIDE.md` |
| Credenciales | `{{CREDENTIALS_PATH}}` |
| Contenido cursos | `{{PROJECT_PATH}}/content/courses/` |
| Migraciones | `{{PROJECT_PATH}}/supabase/migrations/` |

---

## Credenciales

Crea un archivo de credenciales en `{{CREDENTIALS_PATH}}` con el siguiente formato:

```bash
# EduPlatform Credentials
# NO compartir ni subir a repositorios

# Supabase
export NEXT_PUBLIC_SUPABASE_URL="https://{{SUPABASE_PROJECT_REF}}.supabase.co"
export NEXT_PUBLIC_SUPABASE_ANON_KEY="tu-anon-key"
export SUPABASE_SERVICE_ROLE_KEY="tu-service-role-key"
export SUPABASE_ACCESS_TOKEN="tu-access-token"

# Project Info
export SUPABASE_PROJECT_REF="{{SUPABASE_PROJECT_REF}}"
```

Puedes obtener estas claves en:
- **Supabase Dashboard** > Project Settings > API

---

## Comandos Supabase

### Linkear Proyecto (primera vez)

```bash
source .env.local && supabase link --project-ref $SUPABASE_PROJECT_REF
```

### Verificar Link

```bash
cat supabase/.temp/project-ref
# Debe mostrar tu project-ref
```

### Aplicar Migraciones

```bash
source .env.local && supabase db push --linked
```

### Ver Estado de Migraciones

```bash
source .env.local && supabase migration list
```

---

## Dashboard Supabase

- **Editor SQL**: `https://supabase.com/dashboard/project/{{SUPABASE_PROJECT_REF}}/editor`
- **Auth**: `https://supabase.com/dashboard/project/{{SUPABASE_PROJECT_REF}}/auth/users`
- **Storage**: `https://supabase.com/dashboard/project/{{SUPABASE_PROJECT_REF}}/storage/buckets`

---

## Donde Encontrar los Valores

| Placeholder | Donde Encontrarlo |
|-------------|-------------------|
| `{{PROJECT_PATH}}` | Ejecuta `pwd` en la carpeta del proyecto |
| `{{CREDENTIALS_PATH}}` | Decide donde guardar tus credenciales (ej: `~/.edu-platform-credentials`) |
| `{{SUPABASE_PROJECT_REF}}` | Supabase Dashboard > Project Settings > General > Reference ID |
| `{{GITHUB_USERNAME}}` | Tu usuario de GitHub si hiciste fork |

---

*Template para configuracion local. Copia a CLAUDE.local.md y personaliza.*
