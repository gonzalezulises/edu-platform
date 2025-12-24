# Core Web Vitals

## Introducción

Core Web Vitals son métricas de Google que miden la experiencia de usuario. Son factores de ranking en SEO y afectan directamente la conversión.

## Las 3 métricas principales

### LCP - Largest Contentful Paint

Mide cuánto tarda en renderizarse el elemento más grande visible.

| Puntuación | Tiempo |
|------------|--------|
| Bueno | ≤ 2.5s |
| Necesita mejora | 2.5s - 4s |
| Pobre | > 4s |

**Cómo mejorar:**
- Optimizar imágenes hero con `priority`
- Precargar fuentes críticas
- Evitar lazy load en contenido above-the-fold
- Server-side rendering

### FID / INP - First Input Delay / Interaction to Next Paint

Mide la respuesta a la primera interacción del usuario.

| Puntuación | Tiempo |
|------------|--------|
| Bueno | ≤ 100ms |
| Necesita mejora | 100ms - 300ms |
| Pobre | > 300ms |

**Cómo mejorar:**
- Reducir JavaScript del bundle
- Dividir código con dynamic imports
- Evitar tareas largas en el main thread
- Web Workers para cálculos pesados

### CLS - Cumulative Layout Shift

Mide la estabilidad visual (cuánto se mueven elementos).

| Puntuación | Score |
|------------|-------|
| Bueno | ≤ 0.1 |
| Necesita mejora | 0.1 - 0.25 |
| Pobre | > 0.25 |

**Cómo mejorar:**
- Siempre especificar dimensiones en imágenes
- Reservar espacio para anuncios
- Evitar insertar contenido dinámico arriba
- Usar skeleton loaders

## Herramientas de medición

### Lighthouse

```bash
# En Chrome DevTools
# 1. F12 → Lighthouse tab
# 2. Seleccionar categorías
# 3. Analyze page load
```

### PageSpeed Insights

https://pagespeed.web.dev/

Muestra datos de campo (usuarios reales) y lab (simulación).

### Web Vitals Extension

Extensión de Chrome que muestra métricas en tiempo real.

### Vercel Analytics

```tsx
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react'
import { SpeedInsights } from '@vercel/speed-insights/next'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  )
}
```

## Optimizaciones en Next.js

### Optimizar LCP

```tsx
// 1. Imagen hero con priority
import Image from 'next/image'

export function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero"
      width={1920}
      height={1080}
      priority  // Precarga inmediata
    />
  )
}

// 2. Preload fuentes críticas
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',  // Evita FOIT
  preload: true,
})

// 3. Streaming con Suspense
import { Suspense } from 'react'

export default function Page() {
  return (
    <div>
      <HeroSection />  {/* Rápido, sin Suspense */}

      <Suspense fallback={<ProductsSkeleton />}>
        <ProductsList />  {/* Lento, con streaming */}
      </Suspense>
    </div>
  )
}
```

### Optimizar INP

```tsx
// 1. Dynamic imports para código pesado
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/Chart'), {
  ssr: false,
  loading: () => <ChartSkeleton />,
})

// 2. Debounce de inputs
import { useDebouncedCallback } from 'use-debounce'

function SearchInput() {
  const handleSearch = useDebouncedCallback((term) => {
    // Búsqueda costosa
  }, 300)

  return <input onChange={(e) => handleSearch(e.target.value)} />
}

// 3. useTransition para actualizaciones no urgentes
'use client'

import { useTransition } from 'react'

function FilterList() {
  const [isPending, startTransition] = useTransition()
  const [filter, setFilter] = useState('')

  const handleFilter = (value: string) => {
    startTransition(() => {
      setFilter(value)  // Actualización de baja prioridad
    })
  }

  return (
    <div>
      <input onChange={(e) => handleFilter(e.target.value)} />
      {isPending ? <Spinner /> : <FilteredList filter={filter} />}
    </div>
  )
}
```

### Optimizar CLS

```tsx
// 1. Siempre especificar dimensiones
<Image
  src="/product.jpg"
  alt="Product"
  width={400}
  height={300}  // Evita layout shift
/>

// 2. Aspect ratio para videos
<div className="aspect-video">
  <iframe src="..." className="w-full h-full" />
</div>

// 3. Skeleton con mismas dimensiones
function ProductCardSkeleton() {
  return (
    <div className="w-full h-64 animate-pulse bg-gray-200 rounded" />
  )
}

// 4. Reservar espacio para contenido dinámico
<div className="min-h-[200px]">
  {banner && <Banner />}
</div>
```

## Monitoreo continuo

### Custom Web Vitals reporting

```tsx
// app/layout.tsx
'use client'

import { useReportWebVitals } from 'next/web-vitals'

export function WebVitals() {
  useReportWebVitals((metric) => {
    console.log(metric)

    // Enviar a analytics
    fetch('/api/analytics', {
      method: 'POST',
      body: JSON.stringify({
        name: metric.name,
        value: metric.value,
        id: metric.id,
      }),
    })
  })

  return null
}
```

### Estructura de métricas

```ts
interface Metric {
  name: 'LCP' | 'FID' | 'CLS' | 'TTFB' | 'FCP' | 'INP'
  value: number
  rating: 'good' | 'needs-improvement' | 'poor'
  id: string
  navigationType: string
}
```

## Checklist de optimización

### LCP
- [ ] Imagen hero con `priority`
- [ ] Fuentes con `display: swap`
- [ ] SSR para contenido crítico
- [ ] CDN para assets estáticos

### INP
- [ ] Code splitting activo
- [ ] Dynamic imports para componentes pesados
- [ ] Debounce en inputs de búsqueda
- [ ] useTransition para filtros

### CLS
- [ ] Dimensiones en todas las imágenes
- [ ] Aspect ratio en iframes
- [ ] Skeletons con tamaño correcto
- [ ] min-height para contenido dinámico

## Resumen

| Métrica | Meta | Enfoque principal |
|---------|------|-------------------|
| LCP | ≤ 2.5s | Imágenes, fonts, SSR |
| INP | ≤ 100ms | Bundle size, code splitting |
| CLS | ≤ 0.1 | Dimensiones, skeletons |

## Recursos

- [web.dev/vitals](https://web.dev/vitals/)
- [Chrome UX Report](https://developer.chrome.com/docs/crux/)
- [Next.js Analytics](https://nextjs.org/analytics)
