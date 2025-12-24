# Optimización de Bundle

## Introducción

El tamaño del bundle JavaScript afecta directamente el tiempo de carga y la interactividad. Next.js proporciona herramientas para analizar y optimizar el bundle.

## Análisis del bundle

### @next/bundle-analyzer

```bash
npm install @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})

module.exports = withBundleAnalyzer({
  // tu config existente
})
```

```bash
# Ejecutar análisis
ANALYZE=true npm run build
```

Esto abre un reporte visual mostrando el tamaño de cada dependencia.

### Interpretar el análisis

```
Tamaño del bundle:
├── node_modules/
│   ├── lodash (71.5 KB)      ❌ Muy grande
│   ├── moment (289 KB)       ❌ Muy grande
│   ├── @mui/material (150 KB) ⚠️ Revisar
│   └── react-dom (128 KB)    ✅ Necesario
└── src/
    └── components/ (45 KB)   ✅ OK
```

## Estrategias de optimización

### 1. Tree Shaking

Importa solo lo que necesitas:

```tsx
// ❌ Importa toda la librería
import _ from 'lodash'
const result = _.debounce(fn, 300)

// ✅ Importa solo la función
import debounce from 'lodash/debounce'
const result = debounce(fn, 300)

// ✅ O usa lodash-es para mejor tree shaking
import { debounce } from 'lodash-es'
```

### 2. Reemplazar librerías pesadas

```tsx
// ❌ moment.js (289 KB)
import moment from 'moment'
moment().format('YYYY-MM-DD')

// ✅ date-fns (solo lo usado)
import { format } from 'date-fns'
format(new Date(), 'yyyy-MM-dd')

// ✅ O nativo
new Date().toISOString().split('T')[0]
```

```tsx
// ❌ lodash completo (71 KB)
import _ from 'lodash'

// ✅ Funciones nativas
// _.map() → array.map()
// _.filter() → array.filter()
// _.find() → array.find()
// _.includes() → array.includes()
```

### 3. Dynamic Imports

```tsx
// Componentes pesados
import dynamic from 'next/dynamic'

// Solo carga cuando se necesita
const HeavyEditor = dynamic(() => import('@/components/Editor'), {
  loading: () => <EditorSkeleton />,
  ssr: false,  // Si no necesita SSR
})

// Con named exports
const Chart = dynamic(
  () => import('@/components/Charts').then((mod) => mod.LineChart),
  { ssr: false }
)
```

```tsx
// Librerías pesadas
async function handleExport() {
  // Solo carga xlsx cuando el usuario hace click
  const XLSX = await import('xlsx')
  const workbook = XLSX.utils.book_new()
  // ...
}
```

### 4. Code Splitting por rutas

Next.js lo hace automáticamente por página. Puedes optimizar más:

```tsx
// Componentes específicos de ruta
// Solo se cargan cuando visitas /admin

// app/admin/layout.tsx
import dynamic from 'next/dynamic'

const AdminSidebar = dynamic(() => import('@/components/admin/Sidebar'))
const AdminHeader = dynamic(() => import('@/components/admin/Header'))

export default function AdminLayout({ children }) {
  return (
    <div>
      <AdminHeader />
      <AdminSidebar />
      {children}
    </div>
  )
}
```

### 5. Lazy loading de componentes

```tsx
'use client'

import { useState, lazy, Suspense } from 'react'

// Solo carga el modal cuando se abre
const Modal = lazy(() => import('@/components/Modal'))

export function ProductCard() {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div>
      <button onClick={() => setIsOpen(true)}>Ver detalles</button>

      {isOpen && (
        <Suspense fallback={<div>Cargando...</div>}>
          <Modal onClose={() => setIsOpen(false)} />
        </Suspense>
      )}
    </div>
  )
}
```

## Optimizaciones en next.config.js

```js
// next.config.js
module.exports = {
  // Compilador SWC (más rápido que Babel)
  swcMinify: true,

  // Excluir paquetes del bundle del servidor
  experimental: {
    serverComponentsExternalPackages: ['sharp', 'prisma'],
  },

  // Optimizar imports de librerías
  modularizeImports: {
    'lodash': {
      transform: 'lodash/{{member}}',
    },
    '@mui/icons-material': {
      transform: '@mui/icons-material/{{member}}',
    },
  },
}
```

## Optimización de dependencias específicas

### Icons

```tsx
// ❌ Importa todos los iconos
import { FaHome, FaUser } from 'react-icons/fa'

// ✅ Importa específicos
import FaHome from 'react-icons/fa/FaHome'
import FaUser from 'react-icons/fa/FaUser'

// ✅ O usa Lucide (tree-shakeable por defecto)
import { Home, User } from 'lucide-react'
```

### UI Libraries

```tsx
// ❌ Shadcn/Radix completo
import * as Dialog from '@radix-ui/react-dialog'

// ✅ Solo lo necesario (Shadcn hace esto bien)
import { Dialog, DialogContent, DialogTrigger } from '@/components/ui/dialog'
```

## Medir el impacto

### Build output

```bash
npm run build

# Output muestra tamaños
Route (app)                    Size     First Load JS
┌ ○ /                          5.2 kB        89 kB
├ ○ /about                     1.1 kB        85 kB
├ ● /blog/[slug]              2.3 kB        86 kB
└ ○ /dashboard                12.4 kB       96 kB
```

### Comparar antes/después

```bash
# Antes de cambios
npm run build
# First Load JS shared: 84 kB

# Después de optimizar
npm run build
# First Load JS shared: 72 kB (14% menos)
```

## Checklist de optimización

### Dependencias
- [ ] Analizar bundle con @next/bundle-analyzer
- [ ] Reemplazar moment → date-fns o nativo
- [ ] Reemplazar lodash → funciones nativas o lodash-es
- [ ] Usar imports específicos para iconos

### Code Splitting
- [ ] Dynamic imports para componentes pesados
- [ ] Lazy load de modales y drawers
- [ ] ssr: false para componentes client-only

### Configuración
- [ ] swcMinify habilitado
- [ ] modularizeImports para librerías grandes

## Resumen

| Técnica | Ahorro típico |
|---------|---------------|
| Reemplazar moment | ~250 KB |
| Tree shake lodash | ~50 KB |
| Dynamic imports | Variable |
| Iconos específicos | ~100 KB |

## Metas recomendadas

| Métrica | Meta |
|---------|------|
| First Load JS (shared) | < 100 KB |
| Página individual | < 50 KB |
| Total transferido | < 200 KB |
