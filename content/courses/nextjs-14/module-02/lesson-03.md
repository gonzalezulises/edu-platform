# Loading, Error y Not Found

## Introducción

Next.js 14 proporciona archivos especiales para manejar estados de carga, errores y páginas no encontradas de forma declarativa y automática.

## Loading UI

El archivo `loading.tsx` muestra UI mientras la página o layout carga:

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="flex items-center justify-center min-h-screen">
      <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600" />
    </div>
  )
}
```

### Cómo Funciona

Next.js envuelve automáticamente tu página con Suspense:

```tsx
// Esto es lo que Next.js hace internamente
<Suspense fallback={<Loading />}>
  <Page />
</Suspense>
```

### Skeleton Loading

Un patrón común es usar skeletons que imitan la estructura del contenido:

```tsx
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="space-y-4">
      {/* Header skeleton */}
      <div className="h-8 w-64 bg-gray-200 rounded animate-pulse" />

      {/* Cards skeleton */}
      <div className="grid grid-cols-3 gap-4">
        {[1, 2, 3].map((i) => (
          <div key={i} className="h-32 bg-gray-200 rounded animate-pulse" />
        ))}
      </div>

      {/* Table skeleton */}
      <div className="space-y-2">
        {[1, 2, 3, 4, 5].map((i) => (
          <div key={i} className="h-12 bg-gray-200 rounded animate-pulse" />
        ))}
      </div>
    </div>
  )
}
```

## Error Handling

El archivo `error.tsx` captura errores en su segmento de ruta:

```tsx
// app/dashboard/error.tsx
'use client' // Los error boundaries deben ser Client Components

import { useEffect } from 'react'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    // Log del error a un servicio de monitoreo
    console.error('Error capturado:', error)
  }, [error])

  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h2 className="text-2xl font-bold text-red-600 mb-4">
        Algo salió mal
      </h2>
      <p className="text-gray-600 mb-4">{error.message}</p>
      <button
        onClick={reset}
        className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        Intentar de nuevo
      </button>
    </div>
  )
}
```

### Error Boundaries Anidados

Los errores burbujean hasta el error boundary más cercano:

```
app/
├── error.tsx           # Captura errores de toda la app
├── dashboard/
│   ├── error.tsx       # Captura errores del dashboard
│   └── settings/
│       ├── error.tsx   # Captura errores de settings
│       └── page.tsx
```

### global-error.tsx

Para capturar errores en el root layout:

```tsx
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <h2>Error crítico</h2>
        <button onClick={reset}>Reintentar</button>
      </body>
    </html>
  )
}
```

## Not Found

El archivo `not-found.tsx` maneja rutas inexistentes:

```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen">
      <h1 className="text-6xl font-bold text-gray-300">404</h1>
      <h2 className="text-2xl font-semibold mt-4">Página no encontrada</h2>
      <p className="text-gray-500 mt-2">
        Lo sentimos, no pudimos encontrar la página que buscas.
      </p>
      <Link
        href="/"
        className="mt-6 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
      >
        Volver al inicio
      </Link>
    </div>
  )
}
```

### Trigger Programático

Puedes disparar not-found programáticamente:

```tsx
// app/posts/[id]/page.tsx
import { notFound } from 'next/navigation'

export default async function PostPage({ params }: { params: { id: string } }) {
  const post = await getPost(params.id)

  if (!post) {
    notFound() // Renderiza el not-found.tsx más cercano
  }

  return <article>{post.title}</article>
}
```

## Jerarquía de Archivos Especiales

```
app/
├── layout.tsx      # Envuelve todo
├── template.tsx    # Re-renderiza en navegación
├── loading.tsx     # Estado de carga
├── error.tsx       # Manejo de errores
├── not-found.tsx   # 404
└── page.tsx        # Contenido de la ruta
```

El orden de renderizado es:

```tsx
<Layout>
  <Template>
    <ErrorBoundary fallback={<Error />}>
      <Suspense fallback={<Loading />}>
        <Page />
      </Suspense>
    </ErrorBoundary>
  </Template>
</Layout>
```

## Buenas Prácticas

1. **Loading específicos**: Crea loading.tsx por sección para mejor UX
2. **Skeletons realistas**: Que imiten la estructura real del contenido
3. **Errores informativos**: Mensajes claros con acciones posibles
4. **Not Found contextual**: Diferente 404 para /products vs /blog
5. **Logging de errores**: Integra con servicios como Sentry

## Resumen

| Archivo | Propósito | Client/Server |
|---------|-----------|---------------|
| `loading.tsx` | Estado de carga | Server |
| `error.tsx` | Manejo de errores | Client (requerido) |
| `not-found.tsx` | Rutas inexistentes | Server |
| `global-error.tsx` | Errores del root layout | Client |
