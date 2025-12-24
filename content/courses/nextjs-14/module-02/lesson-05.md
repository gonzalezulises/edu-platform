# Navegación y Link Component

## Introducción

Next.js proporciona herramientas optimizadas para navegación que incluyen prefetching automático, transiciones suaves y navegación programática.

## El Componente Link

El componente `Link` es la forma principal de navegar entre páginas:

```tsx
import Link from 'next/link'

export default function Navigation() {
  return (
    <nav>
      <Link href="/">Inicio</Link>
      <Link href="/about">Acerca de</Link>
      <Link href="/blog">Blog</Link>
    </nav>
  )
}
```

### Props Importantes

```tsx
<Link
  href="/dashboard"           // URL destino (requerido)
  replace                     // Reemplaza en lugar de push al history
  scroll={false}              // No hacer scroll al top
  prefetch={false}            // Desactivar prefetch
>
  Dashboard
</Link>
```

### Rutas Dinámicas

```tsx
// Con template literals
<Link href={`/blog/${post.slug}`}>
  {post.title}
</Link>

// Con objeto URL
<Link
  href={{
    pathname: '/blog/[slug]',
    query: { slug: post.slug },
  }}
>
  {post.title}
</Link>
```

## Prefetching

Next.js prefetcha automáticamente los links visibles en el viewport:

```tsx
// Prefetch activado por defecto
<Link href="/heavy-page">Ver más</Link>

// Desactivar para páginas muy pesadas
<Link href="/heavy-page" prefetch={false}>Ver más</Link>
```

### Cómo funciona

1. Links en viewport → se prefetcha el JavaScript
2. En producción → prefetch de RSC payload
3. En desarrollo → no hay prefetch (para debugging)

## Navegación Programática

Usa el hook `useRouter` para navegación desde código:

```tsx
'use client'

import { useRouter } from 'next/navigation'

export default function LoginForm() {
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    const success = await login()

    if (success) {
      router.push('/dashboard')  // Navegar
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      {/* campos del formulario */}
      <button type="submit">Iniciar sesión</button>
    </form>
  )
}
```

### Métodos del Router

```tsx
const router = useRouter()

// Navegar a una nueva ruta
router.push('/dashboard')

// Reemplazar la ruta actual (sin agregar al history)
router.replace('/login')

// Volver atrás
router.back()

// Ir adelante
router.forward()

// Refrescar (re-fetch de Server Components)
router.refresh()

// Prefetch manual
router.prefetch('/heavy-page')
```

## usePathname y useSearchParams

Para obtener información de la URL actual:

```tsx
'use client'

import { usePathname, useSearchParams } from 'next/navigation'

export default function Breadcrumb() {
  const pathname = usePathname()
  // pathname = '/blog/my-post'

  const searchParams = useSearchParams()
  // Para /blog?category=tech
  // searchParams.get('category') = 'tech'

  return (
    <nav>
      <span>Estás en: {pathname}</span>
    </nav>
  )
}
```

## Active Links

Detectar el link activo para estilos:

```tsx
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

const links = [
  { href: '/', label: 'Inicio' },
  { href: '/about', label: 'Acerca' },
  { href: '/blog', label: 'Blog' },
]

export default function NavLinks() {
  const pathname = usePathname()

  return (
    <nav className="flex gap-4">
      {links.map((link) => {
        const isActive = pathname === link.href

        return (
          <Link
            key={link.href}
            href={link.href}
            className={`px-3 py-2 rounded ${
              isActive
                ? 'bg-blue-600 text-white'
                : 'text-gray-600 hover:bg-gray-100'
            }`}
          >
            {link.label}
          </Link>
        )
      })}
    </nav>
  )
}
```

## Scroll Behavior

Por defecto, Next.js hace scroll al top en navegación:

```tsx
// Mantener posición de scroll
<Link href="/page" scroll={false}>Link sin scroll</Link>

// Scroll a un elemento específico
<Link href="/page#section">Ir a sección</Link>
```

## redirect() en Server Components

Para redirecciones en el servidor:

```tsx
// app/dashboard/page.tsx
import { redirect } from 'next/navigation'
import { getUser } from '@/lib/auth'

export default async function Dashboard() {
  const user = await getUser()

  if (!user) {
    redirect('/login')  // Redirige antes de renderizar
  }

  return <div>Bienvenido, {user.name}</div>
}
```

## Navegación con Loading States

Combina navegación con estados de carga:

```tsx
'use client'

import { useRouter } from 'next/navigation'
import { useTransition } from 'react'

export default function NavigationButton() {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()

  const handleClick = () => {
    startTransition(() => {
      router.push('/slow-page')
    })
  }

  return (
    <button onClick={handleClick} disabled={isPending}>
      {isPending ? 'Cargando...' : 'Ir a página lenta'}
    </button>
  )
}
```

## Buenas Prácticas

1. **Usa Link para navegación interna**: Optimizado con prefetch
2. **Usa `<a>` para links externos**: O Link con target="_blank"
3. **Evita router.push para links simples**: Link es más semántico
4. **Prefetch selectivo**: Desactiva en páginas muy pesadas
5. **Usa replace para flujos de auth**: Evita que el usuario vuelva al login

## Resumen

| Método | Uso |
|--------|-----|
| `<Link>` | Navegación declarativa con prefetch |
| `router.push()` | Navegación programática |
| `router.replace()` | Navegar sin agregar al history |
| `router.refresh()` | Re-fetch de Server Components |
| `redirect()` | Redirección en Server Component |
