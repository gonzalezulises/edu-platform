# Layouts Anidados y Templates

## Introducción

Los layouts en Next.js 14 permiten compartir UI entre múltiples rutas. Son una característica fundamental del App Router que optimiza la navegación y mantiene el estado entre páginas.

## Layouts: Persistencia de Estado

Un layout envuelve a sus hijos y **persiste** durante la navegación. Esto significa que:

- El estado del layout se mantiene
- No se re-renderiza al cambiar de página
- Los efectos no se ejecutan nuevamente

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex">
      <aside className="w-64 bg-gray-100">
        <nav>
          <a href="/dashboard">Overview</a>
          <a href="/dashboard/analytics">Analytics</a>
          <a href="/dashboard/settings">Settings</a>
        </nav>
      </aside>
      <main className="flex-1 p-6">
        {children}
      </main>
    </div>
  )
}
```

## Layouts Anidados

Puedes anidar layouts para crear estructuras complejas:

```
app/
├── layout.tsx          # Layout raíz (toda la app)
├── dashboard/
│   ├── layout.tsx      # Layout del dashboard
│   ├── page.tsx        # /dashboard
│   └── settings/
│       ├── layout.tsx  # Layout de settings
│       └── page.tsx    # /dashboard/settings
```

Cada nivel agrega su layout:

```tsx
// app/dashboard/settings/layout.tsx
export default function SettingsLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div>
      <h2 className="text-xl font-bold mb-4">Configuración</h2>
      <div className="grid grid-cols-4 gap-6">
        <nav className="col-span-1">
          <a href="/dashboard/settings/profile">Perfil</a>
          <a href="/dashboard/settings/security">Seguridad</a>
        </nav>
        <div className="col-span-3">{children}</div>
      </div>
    </div>
  )
}
```

## Templates: Re-renderizado en Navegación

A diferencia de los layouts, los **templates** se re-renderizan en cada navegación:

```tsx
// app/dashboard/template.tsx
'use client'

import { useEffect } from 'react'

export default function Template({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // Este efecto se ejecuta en CADA navegación
    console.log('Template montado - nueva página')

    return () => {
      console.log('Template desmontado')
    }
  }, [])

  return <div className="animate-fadeIn">{children}</div>
}
```

### Cuándo usar Templates

| Caso de Uso | Layout | Template |
|-------------|--------|----------|
| Navegación compartida | ✅ | ✅ |
| Mantener estado | ✅ | ❌ |
| Animaciones de entrada | ❌ | ✅ |
| Analytics por página | ❌ | ✅ |
| Reset de formularios | ❌ | ✅ |

## Root Layout Obligatorio

El `app/layout.tsx` es obligatorio y debe incluir `<html>` y `<body>`:

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'Mi Aplicación',
  description: 'Descripción de mi app',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <header>/* Navegación global */</header>
        {children}
        <footer>/* Footer global */</footer>
      </body>
    </html>
  )
}
```

## Layouts con Datos Asíncronos

Los layouts pueden ser async para cargar datos:

```tsx
// app/dashboard/layout.tsx
import { getUser } from '@/lib/auth'

export default async function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const user = await getUser()

  return (
    <div>
      <header>
        <span>Hola, {user.name}</span>
      </header>
      {children}
    </div>
  )
}
```

## Buenas Prácticas

1. **Layouts para UI persistente**: Navegación, sidebars, headers
2. **Templates para efectos por página**: Analytics, animaciones
3. **No pasar datos por props**: Usa fetch en cada componente
4. **Layouts livianos**: Evita lógica pesada que bloquee la navegación

## Resumen

- **Layouts** persisten entre navegaciones, mantienen estado
- **Templates** se re-montan en cada navegación
- Los layouts pueden anidarse infinitamente
- El root layout es obligatorio con `<html>` y `<body>`
