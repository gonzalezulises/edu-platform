# Caching Strategies

## Introducción

El caching es crucial para performance. Next.js 14 tiene múltiples capas de cache que trabajan juntas para optimizar tu aplicación.

## Las 4 capas de cache

### 1. Request Memoization (React)

Deduplicación automática dentro de un render:

```tsx
// Ambas llamadas resultan en UNA sola query
async function Layout({ children }) {
  const user = await getUser()  // Query real
  return <div>{children}</div>
}

async function Page() {
  const user = await getUser()  // Usa cache de arriba
  return <div>{user.name}</div>
}

// La función debe usar cache() de React
import { cache } from 'react'

export const getUser = cache(async () => {
  return db.user.findUnique({ where: { id: userId } })
})
```

### 2. Data Cache (Next.js)

Cache persistente entre requests:

```tsx
// Cacheado indefinidamente (default)
const data = await fetch('https://api.example.com/data')

// Sin cache
const data = await fetch('https://api.example.com/data', {
  cache: 'no-store'
})

// Revalidar cada hora
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 3600 }
})

// Con tags para invalidación granular
const data = await fetch('https://api.example.com/data', {
  next: { tags: ['products'] }
})
```

### 3. Full Route Cache

HTML y RSC payload de rutas estáticas:

```tsx
// Ruta estática - cacheada en build
export default async function StaticPage() {
  const data = await fetch('https://api.example.com/static')
  return <div>{data.title}</div>
}

// Ruta dinámica - no cacheada
export const dynamic = 'force-dynamic'

export default async function DynamicPage() {
  const data = await fetch('https://api.example.com/realtime', {
    cache: 'no-store'
  })
  return <div>{data.title}</div>
}
```

### 4. Router Cache (Client)

Cache en navegador de rutas visitadas:

```tsx
// Prefetch automático de links visibles
<Link href="/about">About</Link>  // Se precarga

// Prefetch manual
const router = useRouter()
router.prefetch('/dashboard')

// Invalidar después de mutación
router.refresh()
```

## Estrategias por caso de uso

### Contenido estático (Blog, docs)

```tsx
// pages/blog/[slug]/page.tsx
export const revalidate = 3600  // 1 hora

export async function generateStaticParams() {
  const posts = await getPosts()
  return posts.map((post) => ({ slug: post.slug }))
}

export default async function BlogPost({ params }) {
  const post = await getPost(params.slug)
  return <article>{post.content}</article>
}
```

### Dashboard (datos de usuario)

```tsx
// Siempre fresco
export const dynamic = 'force-dynamic'

export default async function Dashboard() {
  const user = await getCurrentUser()
  const stats = await getUserStats(user.id)

  return <DashboardView stats={stats} />
}
```

### E-commerce (productos)

```tsx
// ISR: Cache pero revalidar periódicamente
export const revalidate = 60  // 1 minuto

export default async function ProductPage({ params }) {
  const product = await fetch(
    `https://api.example.com/products/${params.id}`,
    { next: { tags: [`product-${params.id}`] } }
  )

  return <ProductView product={product} />
}

// Server Action para actualizar
export async function updateProduct(id, data) {
  await db.product.update({ where: { id }, data })
  revalidateTag(`product-${id}`)
}
```

### Feed de noticias

```tsx
// Revalidación frecuente
export const revalidate = 30  // 30 segundos

// O streaming para contenido mixto
export default async function NewsFeed() {
  return (
    <div>
      {/* Contenido estático rápido */}
      <Header />

      {/* Contenido dinámico con streaming */}
      <Suspense fallback={<FeedSkeleton />}>
        <LatestNews />
      </Suspense>
    </div>
  )
}
```

## unstable_cache para funciones no-fetch

```tsx
import { unstable_cache } from 'next/cache'

const getCachedProducts = unstable_cache(
  async (category: string) => {
    return db.product.findMany({
      where: { category },
    })
  },
  ['products'],  // Cache key prefix
  {
    tags: ['products'],
    revalidate: 3600,
  }
)

// Uso
const products = await getCachedProducts('electronics')

// Invalidar
revalidateTag('products')
```

## Patrones avanzados

### Cache por usuario

```tsx
import { unstable_cache } from 'next/cache'
import { auth } from '@/auth'

async function getUserDashboard() {
  const session = await auth()
  if (!session) throw new Error('Not authenticated')

  // Cache key incluye user ID
  const getCachedDashboard = unstable_cache(
    async () => {
      return db.dashboard.findUnique({
        where: { userId: session.user.id },
      })
    },
    [`dashboard-${session.user.id}`],
    { revalidate: 300 }  // 5 minutos
  )

  return getCachedDashboard()
}
```

### Stale-While-Revalidate manual

```tsx
import { unstable_cache } from 'next/cache'

const getProducts = unstable_cache(
  async () => {
    const products = await fetch('https://api.example.com/products')
    return products.json()
  },
  ['products'],
  {
    revalidate: 60,  // Datos "frescos" por 1 minuto
    // Después, sirve stale mientras revalida en background
  }
)
```

### Invalidación en cascada

```tsx
// Cuando un producto cambia, invalida múltiples caches
export async function updateProduct(id: string, data: any) {
  await db.product.update({ where: { id }, data })

  // Invalida el producto específico
  revalidateTag(`product-${id}`)

  // Invalida listas que lo incluyan
  revalidateTag(`category-${data.category}`)

  // Invalida página principal si es featured
  if (data.featured) {
    revalidatePath('/')
  }
}
```

## Debugging del cache

```js
// next.config.js
module.exports = {
  logging: {
    fetches: {
      fullUrl: true,
    },
  },
}
```

Output en desarrollo:
```
GET https://api.example.com/products 200 in 45ms (cache: HIT)
GET https://api.example.com/users/1 200 in 120ms (cache: MISS)
GET https://api.example.com/cart 200 in 80ms (cache: SKIP)
```

## Resumen de opciones

| Estrategia | Config | Uso |
|------------|--------|-----|
| Estático | Default | Landing, docs |
| ISR | `revalidate: N` | Blog, productos |
| Dinámico | `cache: 'no-store'` | Dashboard, cart |
| Tags | `next: { tags: [] }` | Invalidación granular |
| On-demand | `revalidatePath/Tag` | Después de mutaciones |

## Cuándo NO cachear

- Datos de sesión/autenticación
- Carrito de compras
- Datos en tiempo real
- Contenido personalizado por usuario

## Checklist

- [ ] Definir estrategia por tipo de contenido
- [ ] Usar tags para invalidación precisa
- [ ] unstable_cache para queries de DB
- [ ] ISR para contenido semi-estático
- [ ] Logging habilitado en desarrollo
- [ ] Invalidar después de mutaciones
