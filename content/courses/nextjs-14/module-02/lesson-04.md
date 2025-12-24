# Parallel Routes e Intercepting Routes

## Introducción

Next.js 14 introduce patrones avanzados de routing que permiten renderizar múltiples páginas simultáneamente y crear experiencias modales sofisticadas.

## Parallel Routes

Los Parallel Routes permiten renderizar múltiples páginas en el mismo layout simultáneamente.

### Sintaxis con @folder

```
app/
├── layout.tsx
├── page.tsx
├── @team/
│   ├── page.tsx
│   └── loading.tsx
├── @analytics/
│   ├── page.tsx
│   └── loading.tsx
```

### Implementación del Layout

```tsx
// app/layout.tsx
export default function Layout({
  children,
  team,
  analytics,
}: {
  children: React.ReactNode
  team: React.ReactNode
  analytics: React.ReactNode
}) {
  return (
    <div>
      <main>{children}</main>
      <div className="grid grid-cols-2 gap-4">
        <section>{team}</section>
        <section>{analytics}</section>
      </div>
    </div>
  )
}
```

### Casos de Uso

1. **Dashboards**: Múltiples widgets cargando independientemente
2. **Feeds sociales**: Timeline + trending topics + suggestions
3. **E-commerce**: Productos + filtros + carrito

### Loading Independiente

Cada slot puede tener su propio loading:

```tsx
// app/@team/loading.tsx
export default function TeamLoading() {
  return <div className="animate-pulse h-48 bg-gray-200 rounded" />
}

// app/@analytics/loading.tsx
export default function AnalyticsLoading() {
  return <div className="animate-pulse h-48 bg-gray-200 rounded" />
}
```

### Default.tsx para Rutas No Coincidentes

Cuando navegas a una subruta, los slots que no tienen esa ruta necesitan un `default.tsx`:

```tsx
// app/@team/default.tsx
export default function TeamDefault() {
  return null // O renderiza contenido por defecto
}
```

## Intercepting Routes

Permiten "interceptar" una ruta y mostrarla de forma diferente (ej: modal) mientras se mantiene el contexto actual.

### Convenciones

| Patrón | Intercepta |
|--------|------------|
| `(.)` | Mismo nivel |
| `(..)` | Un nivel arriba |
| `(..)(..)` | Dos niveles arriba |
| `(...)` | Desde la raíz |

### Ejemplo: Modal de Fotos

```
app/
├── @modal/
│   └── (.)photo/
│       └── [id]/
│           └── page.tsx    # Modal interceptando /photo/[id]
├── photo/
│   └── [id]/
│       └── page.tsx        # Página completa de la foto
├── feed/
│   └── page.tsx            # Feed con fotos
└── layout.tsx
```

### Implementación

```tsx
// app/feed/page.tsx
import Link from 'next/link'

export default function Feed() {
  const photos = [1, 2, 3, 4, 5]

  return (
    <div className="grid grid-cols-3 gap-4">
      {photos.map((id) => (
        <Link key={id} href={`/photo/${id}`}>
          <img src={`/photos/${id}.jpg`} alt={`Photo ${id}`} />
        </Link>
      ))}
    </div>
  )
}
```

```tsx
// app/@modal/(.)photo/[id]/page.tsx
import { Modal } from '@/components/Modal'

export default function PhotoModal({ params }: { params: { id: string } }) {
  return (
    <Modal>
      <img src={`/photos/${params.id}.jpg`} alt="Photo" className="max-w-full" />
    </Modal>
  )
}
```

```tsx
// app/photo/[id]/page.tsx
// Página completa cuando accedes directamente o refrescas
export default function PhotoPage({ params }: { params: { id: string } }) {
  return (
    <div className="container mx-auto py-8">
      <img src={`/photos/${params.id}.jpg`} alt="Photo" />
      <h1>Foto {params.id}</h1>
      <p>Detalles de la foto...</p>
    </div>
  )
}
```

### Layout con Modal Slot

```tsx
// app/layout.tsx
export default function Layout({
  children,
  modal,
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <>
      {children}
      {modal}
    </>
  )
}
```

### Componente Modal

```tsx
// components/Modal.tsx
'use client'

import { useRouter } from 'next/navigation'

export function Modal({ children }: { children: React.ReactNode }) {
  const router = useRouter()

  return (
    <div
      className="fixed inset-0 bg-black/50 flex items-center justify-center z-50"
      onClick={() => router.back()}
    >
      <div
        className="bg-white rounded-lg p-6 max-w-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {children}
        <button onClick={() => router.back()}>Cerrar</button>
      </div>
    </div>
  )
}
```

## Comportamiento en Navegación

| Acción | Resultado |
|--------|-----------|
| Click en link | Se abre el modal (interceptado) |
| Refresh (F5) | Se carga la página completa |
| URL directa | Se carga la página completa |
| Botón atrás | Se cierra el modal |

## Casos de Uso Avanzados

### Login Modal

```
app/
├── @auth/
│   └── (.)login/
│       └── page.tsx    # Modal de login
├── login/
│   └── page.tsx        # Página de login completa
```

### Quick View de Productos

```
app/
├── products/
│   └── page.tsx
├── @modal/
│   └── (..)products/
│       └── [id]/
│           └── page.tsx  # Quick view modal
├── products/
│   └── [id]/
│       └── page.tsx      # Página completa del producto
```

## Resumen

- **Parallel Routes** (@folder): Múltiples páginas en un layout
- **Intercepting Routes** ((.)folder): Modales contextuales
- Ambos patrones mejoran UX sin sacrificar funcionalidad
- El refresh siempre carga la página completa (SEO-friendly)
