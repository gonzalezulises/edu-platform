# Caching y Revalidación

## Introducción

Next.js 14 tiene un sistema de caché multicapa que optimiza automáticamente tu aplicación. Entender cómo funciona es esencial para aplicaciones de producción.

## Las 4 Capas de Cache

### 1. Request Memoization (React)

Deduplicación dentro de un único render:

```tsx
// Ambas llamadas resultan en UN solo request
async function Layout({ children }) {
  const user = await getUser() // Request real
  return <>{children}</>
}

async function Page() {
  const user = await getUser() // Usa el resultado cacheado
  return <div>{user.name}</div>
}
```

### 2. Data Cache (Next.js)

Cache persistente entre requests:

```tsx
// Cacheado indefinidamente (default)
fetch('https://api.example.com/data')

// Sin cache
fetch('https://api.example.com/data', { cache: 'no-store' })

// Revalidar cada 60 segundos
fetch('https://api.example.com/data', { next: { revalidate: 60 } })
```

### 3. Full Route Cache

Next.js cachea el HTML y RSC payload de rutas estáticas:

```tsx
// Esta página se genera en build time
// y se sirve desde cache
export default async function StaticPage() {
  const data = await fetch('https://api.example.com/static')
  return <div>{data.title}</div>
}
```

### 4. Router Cache (Client-side)

El navegador cachea rutas visitadas durante la sesión.

## Revalidación por Tiempo (ISR)

```tsx
// Opción 1: En el fetch individual
const data = await fetch('https://api.example.com/posts', {
  next: { revalidate: 3600 } // 1 hora
})

// Opción 2: A nivel de segmento
export const revalidate = 3600

export default async function Page() {
  const data = await getData()
  return <div>{/* ... */}</div>
}
```

### Cómo funciona ISR

1. Primera visita → Genera y cachea la página
2. Siguientes visitas (< 1 hora) → Sirve desde cache
3. Visita después de 1 hora → Sirve stale, regenera en background
4. Siguiente visita → Sirve la versión nueva

## Revalidación On-Demand

### Por Path

```tsx
// app/api/revalidate/route.ts
import { revalidatePath } from 'next/cache'
import { NextRequest } from 'next/server'

export async function POST(request: NextRequest) {
  const path = request.nextUrl.searchParams.get('path')

  if (path) {
    revalidatePath(path)
    return Response.json({ revalidated: true, now: Date.now() })
  }

  return Response.json({ revalidated: false })
}
```

```bash
curl -X POST "https://mysite.com/api/revalidate?path=/blog"
```

### Por Tag

```tsx
// Al hacer fetch, asigna tags
const posts = await fetch('https://api.example.com/posts', {
  next: { tags: ['posts'] }
})

const post = await fetch(`https://api.example.com/posts/${id}`, {
  next: { tags: ['posts', `post-${id}`] }
})
```

```tsx
// Revalidar por tag
import { revalidateTag } from 'next/cache'

export async function createPost(data: FormData) {
  'use server'

  await db.post.create({ data })

  // Invalida todas las páginas que usen el tag 'posts'
  revalidateTag('posts')
}
```

## unstable_cache para No-Fetch

Para funciones que no usan fetch:

```tsx
import { unstable_cache } from 'next/cache'

const getCachedUser = unstable_cache(
  async (id: string) => {
    return db.user.findUnique({ where: { id } })
  },
  ['user-cache'],  // cache key
  {
    tags: ['users'],
    revalidate: 3600,
  }
)

export default async function UserPage({ params }) {
  const user = await getCachedUser(params.id)
  return <div>{user.name}</div>
}
```

## Opt-out del Cache

### A nivel de fetch

```tsx
fetch(url, { cache: 'no-store' })
```

### A nivel de ruta

```tsx
export const dynamic = 'force-dynamic'
export const revalidate = 0
```

### Funciones dinámicas

Usar estas funciones hace la ruta dinámica automáticamente:

```tsx
import { cookies, headers } from 'next/headers'

async function Page() {
  const cookieStore = await cookies()  // Hace la ruta dinámica
  const headersList = await headers()  // Hace la ruta dinámica

  return <div>...</div>
}
```

## Cache en Diferentes Escenarios

| Escenario | Configuración |
|-----------|---------------|
| Blog (contenido estático) | Default (cacheado) |
| Dashboard (datos de usuario) | `cache: 'no-store'` |
| E-commerce (productos) | `revalidate: 3600` |
| Noticias (actualización frecuente) | `revalidate: 60` + on-demand |

## Debugging del Cache

```tsx
// next.config.js
module.exports = {
  logging: {
    fetches: {
      fullUrl: true,
    },
  },
}
```

En desarrollo verás logs como:

```
GET https://api.example.com/posts 200 in 45ms (cache: HIT)
GET https://api.example.com/users 200 in 120ms (cache: MISS)
```

## Buenas Prácticas

1. **Default es cacheado**: Solo opt-out cuando necesites datos frescos
2. **Usa tags**: Más granular que revalidatePath
3. **ISR para contenido semi-dinámico**: Balance entre performance y frescura
4. **On-demand para mutaciones**: revalidateTag después de crear/actualizar

## Resumen

```tsx
// Estático (default)
fetch(url)

// Dinámico (sin cache)
fetch(url, { cache: 'no-store' })

// ISR (revalidar por tiempo)
fetch(url, { next: { revalidate: 60 } })

// Tags (revalidar on-demand)
fetch(url, { next: { tags: ['posts'] } })
revalidateTag('posts')

// Path (revalidar toda la ruta)
revalidatePath('/blog')
```
