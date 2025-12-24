# Streaming y Suspense

## Introducción

Streaming permite enviar HTML progresivamente al cliente, mejorando el Time to First Byte (TTFB) y permitiendo que partes de la página se muestren antes de que todo esté listo.

## Cómo Funciona el Streaming

### Sin Streaming (Tradicional)

```
[Servidor procesa todo] ──────────────────► [Cliente recibe HTML completo]
         5 segundos                                    ↓
                                              [Usuario ve página]
```

### Con Streaming

```
[Shell HTML] ──► [Cliente muestra estructura]
      ↓
[Datos parte 1] ──► [Cliente actualiza]
      ↓
[Datos parte 2] ──► [Cliente actualiza]
      ↓
[Datos parte 3] ──► [Página completa]
```

## Suspense para Streaming

```tsx
import { Suspense } from 'react'

export default function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Se muestra inmediatamente */}
      <WelcomeMessage />

      {/* Cada sección carga independientemente */}
      <Suspense fallback={<CardSkeleton />}>
        <RevenueCard />
      </Suspense>

      <Suspense fallback={<ChartSkeleton />}>
        <SalesChart />
      </Suspense>

      <Suspense fallback={<TableSkeleton />}>
        <RecentOrders />
      </Suspense>
    </div>
  )
}
```

## Componentes Async con Suspense

```tsx
// components/RevenueCard.tsx
async function RevenueCard() {
  // Simula fetch lento
  const revenue = await fetch('https://api.example.com/revenue', {
    cache: 'no-store'
  }).then(r => r.json())

  return (
    <div className="p-6 bg-white rounded-lg shadow">
      <h2>Ingresos del Mes</h2>
      <p className="text-3xl font-bold">${revenue.total}</p>
    </div>
  )
}
```

## loading.tsx Automático

Next.js usa loading.tsx como Suspense boundary automático:

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="space-y-4">
      <div className="h-8 w-48 bg-gray-200 animate-pulse rounded" />
      <div className="grid grid-cols-3 gap-4">
        {[1, 2, 3].map(i => (
          <div key={i} className="h-32 bg-gray-200 animate-pulse rounded" />
        ))}
      </div>
    </div>
  )
}
```

Esto es equivalente a:

```tsx
<Suspense fallback={<Loading />}>
  <DashboardPage />
</Suspense>
```

## Streaming Granular

```tsx
export default function Page() {
  return (
    <div className="grid grid-cols-2 gap-6">
      {/* Lado izquierdo - Carga rápida */}
      <div>
        <Suspense fallback={<ProfileSkeleton />}>
          <UserProfile />  {/* 200ms */}
        </Suspense>
      </div>

      {/* Lado derecho - Carga lenta */}
      <div>
        <Suspense fallback={<FeedSkeleton />}>
          <ActivityFeed />  {/* 2000ms */}
        </Suspense>
      </div>
    </div>
  )
}
```

El usuario ve el perfil primero, luego el feed.

## Suspense Anidado

```tsx
<Suspense fallback={<PageSkeleton />}>
  <Header />

  <Suspense fallback={<MainSkeleton />}>
    <MainContent />

    <Suspense fallback={<CommentsSkeleton />}>
      <Comments />  {/* Lo más lento */}
    </Suspense>
  </Suspense>

  <Footer />
</Suspense>
```

## Skeleton Components

```tsx
// components/skeletons/CardSkeleton.tsx
export function CardSkeleton() {
  return (
    <div className="p-6 bg-white rounded-lg shadow animate-pulse">
      <div className="h-4 w-24 bg-gray-200 rounded mb-4" />
      <div className="h-8 w-32 bg-gray-200 rounded mb-2" />
      <div className="h-3 w-full bg-gray-200 rounded" />
    </div>
  )
}

// components/skeletons/TableSkeleton.tsx
export function TableSkeleton({ rows = 5 }) {
  return (
    <div className="space-y-2">
      {Array.from({ length: rows }).map((_, i) => (
        <div key={i} className="h-12 bg-gray-200 rounded animate-pulse" />
      ))}
    </div>
  )
}
```

## Parallel Routes + Streaming

```tsx
// app/layout.tsx
export default function Layout({
  children,
  analytics,
  team,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  team: React.ReactNode
}) {
  return (
    <div>
      {children}
      <div className="grid grid-cols-2 gap-4">
        {/* Cada slot puede tener su propio loading.tsx */}
        {analytics}
        {team}
      </div>
    </div>
  )
}
```

```tsx
// app/@analytics/loading.tsx
export default function AnalyticsLoading() {
  return <div className="h-64 bg-gray-100 animate-pulse rounded" />
}

// app/@team/loading.tsx
export default function TeamLoading() {
  return <div className="h-64 bg-gray-100 animate-pulse rounded" />
}
```

## Error Boundaries con Streaming

Combina Suspense con Error Boundaries:

```tsx
import { Suspense } from 'react'
import { ErrorBoundary } from 'react-error-boundary'

export default function Dashboard() {
  return (
    <ErrorBoundary fallback={<ErrorCard />}>
      <Suspense fallback={<CardSkeleton />}>
        <DataCard />
      </Suspense>
    </ErrorBoundary>
  )
}
```

O usa el archivo error.tsx de Next.js:

```tsx
// app/dashboard/error.tsx
'use client'

export default function Error({ error, reset }) {
  return (
    <div>
      <p>Error: {error.message}</p>
      <button onClick={reset}>Reintentar</button>
    </div>
  )
}
```

## Beneficios del Streaming

| Métrica | Sin Streaming | Con Streaming |
|---------|---------------|---------------|
| TTFB | 5s | <1s |
| FCP | 5s | <1s |
| LCP | 5s | ~2s (progresivo) |
| TTI | 5s | Progresivo |

## Buenas Prácticas

1. **Suspense granular**: Más boundaries = mejor UX
2. **Skeletons realistas**: Que imiten el contenido final
3. **Prioriza contenido crítico**: Fuera de Suspense
4. **loading.tsx por sección**: No solo en la raíz
5. **Combina con Parallel Routes**: Para máximo paralelismo

## Resumen

```tsx
// Streaming básico con loading.tsx
app/
├── page.tsx
└── loading.tsx  // Suspense automático

// Streaming granular con Suspense
<Suspense fallback={<Skeleton />}>
  <SlowComponent />
</Suspense>

// Múltiples streams paralelos
<div className="grid">
  <Suspense fallback={<A />}><ComponentA /></Suspense>
  <Suspense fallback={<B />}><ComponentB /></Suspense>
</div>
```
