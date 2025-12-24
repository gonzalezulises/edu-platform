# Variables de Entorno

## Introducción

Las variables de entorno permiten configurar tu aplicación de forma diferente según el ambiente (desarrollo, staging, producción) sin modificar código.

## Tipos de variables en Next.js

### Variables de servidor

Solo accesibles en código del servidor:

```bash
# .env.local
DATABASE_URL=postgresql://...
STRIPE_SECRET_KEY=sk_live_...
EMAIL_API_KEY=...
```

```tsx
// Solo en Server Components, API Routes, Server Actions
const dbUrl = process.env.DATABASE_URL
```

### Variables públicas

Accesibles en cliente y servidor (incluidas en el bundle):

```bash
# .env.local
NEXT_PUBLIC_SITE_URL=https://midominio.com
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
NEXT_PUBLIC_GA_ID=UA-123456
```

```tsx
// Accesible en cualquier lugar
const siteUrl = process.env.NEXT_PUBLIC_SITE_URL
```

## Archivos de entorno

```
.env                 # Default para todos los ambientes
.env.local           # Overrides locales (no committear)
.env.development     # Solo en npm run dev
.env.production      # Solo en npm run build/start
.env.test            # Solo en npm test
```

### Orden de carga

1. `process.env`
2. `.env.$(NODE_ENV).local`
3. `.env.local` (excepto en test)
4. `.env.$(NODE_ENV)`
5. `.env`

## Configuración para Vercel

### Dashboard

1. Ve a Project Settings → Environment Variables
2. Agrega cada variable
3. Selecciona ambientes (Production, Preview, Development)

### CLI

```bash
# Listar variables
vercel env ls

# Agregar variable
vercel env add DATABASE_URL

# Pull a .env.local
vercel env pull .env.local
```

### Diferentes valores por ambiente

```bash
# En Vercel puedes tener:
# Production: DATABASE_URL=postgresql://prod-db...
# Preview: DATABASE_URL=postgresql://staging-db...
# Development: DATABASE_URL=postgresql://localhost...
```

## Validación con Zod

```tsx
// lib/env.ts
import { z } from 'zod'

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  NEXT_PUBLIC_SITE_URL: z.string().url(),
  NODE_ENV: z.enum(['development', 'production', 'test']),
})

// Validar al iniciar
const parsed = envSchema.safeParse(process.env)

if (!parsed.success) {
  console.error('❌ Invalid environment variables:', parsed.error.format())
  throw new Error('Invalid environment variables')
}

export const env = parsed.data
```

```tsx
// Uso
import { env } from '@/lib/env'

const dbUrl = env.DATABASE_URL  // Type-safe y validado
```

## T3 Env (recomendado)

Librería popular para validación de env vars:

```bash
npm install @t3-oss/env-nextjs zod
```

```tsx
// env.ts
import { createEnv } from '@t3-oss/env-nextjs'
import { z } from 'zod'

export const env = createEnv({
  server: {
    DATABASE_URL: z.string().url(),
    STRIPE_SECRET_KEY: z.string().min(1),
    EMAIL_SERVER: z.string().url(),
  },
  client: {
    NEXT_PUBLIC_SITE_URL: z.string().url(),
    NEXT_PUBLIC_STRIPE_KEY: z.string().startsWith('pk_'),
  },
  runtimeEnv: {
    DATABASE_URL: process.env.DATABASE_URL,
    STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY,
    EMAIL_SERVER: process.env.EMAIL_SERVER,
    NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
    NEXT_PUBLIC_STRIPE_KEY: process.env.NEXT_PUBLIC_STRIPE_KEY,
  },
})
```

## Secretos seguros

### Nunca exponer en cliente

```tsx
// ❌ PELIGRO: Esto expone el secret
const apiKey = process.env.STRIPE_SECRET_KEY
// Si usas esto en un Client Component, se incluye en el bundle

// ✅ Solo en servidor
// app/api/payment/route.ts
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)
```

### Verificar en runtime

```tsx
// lib/stripe.ts
if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error('STRIPE_SECRET_KEY is not defined')
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)
```

## Patrones comunes

### URL base dinámica

```tsx
// lib/url.ts
export function getBaseUrl() {
  // En servidor
  if (typeof window === 'undefined') {
    // Vercel
    if (process.env.VERCEL_URL) {
      return `https://${process.env.VERCEL_URL}`
    }
    // Desarrollo
    return 'http://localhost:3000'
  }

  // En cliente
  return window.location.origin
}
```

### Feature flags

```bash
# .env.local
NEXT_PUBLIC_FEATURE_NEW_DASHBOARD=true
NEXT_PUBLIC_FEATURE_BETA_EDITOR=false
```

```tsx
// lib/features.ts
export const features = {
  newDashboard: process.env.NEXT_PUBLIC_FEATURE_NEW_DASHBOARD === 'true',
  betaEditor: process.env.NEXT_PUBLIC_FEATURE_BETA_EDITOR === 'true',
}

// Uso
if (features.newDashboard) {
  return <NewDashboard />
}
return <LegacyDashboard />
```

### Configuración por ambiente

```tsx
// lib/config.ts
const config = {
  development: {
    apiUrl: 'http://localhost:3001',
    logLevel: 'debug',
  },
  production: {
    apiUrl: 'https://api.midominio.com',
    logLevel: 'error',
  },
  test: {
    apiUrl: 'http://localhost:3001',
    logLevel: 'silent',
  },
}

export const appConfig = config[process.env.NODE_ENV || 'development']
```

## Debugging

### Ver variables cargadas

```tsx
// Solo en desarrollo
if (process.env.NODE_ENV === 'development') {
  console.log('Loaded env:', {
    hasDbUrl: !!process.env.DATABASE_URL,
    siteUrl: process.env.NEXT_PUBLIC_SITE_URL,
  })
}
```

### Verificar en build

```bash
npm run build

# Si falta una variable, el build fallará con:
# Error: Missing required env variable: DATABASE_URL
```

## Checklist

### Seguridad
- [ ] Secrets solo en variables de servidor (sin NEXT_PUBLIC_)
- [ ] .env.local en .gitignore
- [ ] Valores diferentes por ambiente en Vercel
- [ ] Validación con Zod o T3 Env

### Organización
- [ ] .env.example con todas las variables (sin valores reales)
- [ ] Documentación de cada variable
- [ ] Validación en startup de la app

### Ejemplo de .env.example

```bash
# .env.example (sí committear)
# Base de datos
DATABASE_URL=

# Auth
NEXTAUTH_SECRET=
NEXTAUTH_URL=http://localhost:3000

# Stripe
STRIPE_SECRET_KEY=
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=

# Email
EMAIL_SERVER=

# Analytics
NEXT_PUBLIC_GA_ID=
```

## Resumen

| Prefijo | Acceso | Uso |
|---------|--------|-----|
| (ninguno) | Solo servidor | Secrets, DB, APIs |
| NEXT_PUBLIC_ | Cliente + servidor | Config pública |

## Buenas prácticas

1. **Nunca hardcodear secrets**: Siempre variables de entorno
2. **Validar al inicio**: Fallar rápido si falta algo
3. **Documentar variables**: .env.example actualizado
4. **Separar por ambiente**: Valores diferentes en Vercel
5. **Type safety**: Usar Zod o T3 Env
