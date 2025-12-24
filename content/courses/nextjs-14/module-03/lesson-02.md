# Fetching en Server Components

## Introducción

Los Server Components en Next.js 14 pueden hacer fetch de datos directamente sin useEffect, useState, ni bibliotecas adicionales. El fetching ocurre en el servidor antes de enviar HTML al cliente.

## Fetch Básico

```tsx
// app/posts/page.tsx
async function getPosts() {
  const res = await fetch('https://api.example.com/posts')
  if (!res.ok) throw new Error('Failed to fetch')
  return res.json()
}

export default async function PostsPage() {
  const posts = await getPosts()

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

## Opciones de Cache

Next.js extiende fetch con opciones de cache:

```tsx
// Cache por defecto (force-cache) - SSG behavior
const data = await fetch('https://api.example.com/data')

// Sin cache (no-store) - SSR behavior
const data = await fetch('https://api.example.com/data', {
  cache: 'no-store'
})

// Revalidar cada 60 segundos - ISR behavior
const data = await fetch('https://api.example.com/data', {
  next: { revalidate: 60 }
})

// Tags para revalidación on-demand
const data = await fetch('https://api.example.com/data', {
  next: { tags: ['posts'] }
})
```

## Patrones de Fetching

### Sequential (Waterfall)

```tsx
// ⚠️ Cada fetch espera al anterior
async function Page() {
  const user = await getUser()        // 1s
  const posts = await getPosts(user.id) // 1s
  // Total: 2s

  return <div>{/* ... */}</div>
}
```

### Parallel

```tsx
// ✅ Fetches simultáneos
async function Page() {
  const [user, posts, comments] = await Promise.all([
    getUser(),
    getPosts(),
    getComments(),
  ])
  // Total: max(1s, 1s, 1s) = 1s

  return <div>{/* ... */}</div>
}
```

### Preload Pattern

```tsx
// lib/data.ts
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  const res = await fetch(`/api/users/${id}`)
  return res.json()
})

// Función de preload
export const preloadUser = (id: string) => {
  void getUser(id)
}
```

```tsx
// app/users/[id]/page.tsx
import { getUser, preloadUser } from '@/lib/data'

export default async function UserPage({ params }) {
  // Preload inicia el fetch inmediatamente
  preloadUser(params.id)

  // Otros componentes pueden hacer más trabajo aquí
  // ...

  // Cuando necesitamos los datos, probablemente ya están
  const user = await getUser(params.id)

  return <div>{user.name}</div>
}
```

## Fetch en Componentes Anidados

```tsx
// app/dashboard/page.tsx
export default async function Dashboard() {
  return (
    <div>
      <UserInfo />    {/* Hace su propio fetch */}
      <RecentPosts /> {/* Hace su propio fetch */}
      <Analytics />   {/* Hace su propio fetch */}
    </div>
  )
}

// components/UserInfo.tsx
async function UserInfo() {
  const user = await getUser()
  return <div>{user.name}</div>
}
```

## Request Memoization

React y Next.js deduplicean requests automáticamente:

```tsx
// Aunque llamemos getUser() múltiples veces,
// solo se hace UN request real
async function Layout({ children }) {
  const user = await getUser() // Request 1
  return <div>{children}</div>
}

async function Page() {
  const user = await getUser() // Misma referencia, no re-fetch
  return <div>{user.name}</div>
}
```

## Fetch con Headers

```tsx
import { cookies, headers } from 'next/headers'

async function getData() {
  const cookieStore = await cookies()
  const token = cookieStore.get('token')

  const res = await fetch('https://api.example.com/data', {
    headers: {
      Authorization: `Bearer ${token?.value}`,
    },
  })

  return res.json()
}
```

## Manejo de Errores

```tsx
async function getData() {
  const res = await fetch('https://api.example.com/data')

  if (!res.ok) {
    // Esto activará el error.tsx más cercano
    throw new Error('Failed to fetch data')
  }

  return res.json()
}
```

## Fetching con Bases de Datos

No estás limitado a fetch. Puedes usar cualquier fuente de datos:

```tsx
// Con Prisma
import { prisma } from '@/lib/prisma'

async function getPosts() {
  return prisma.post.findMany({
    include: { author: true },
  })
}

// Con SQL directo
import { sql } from '@vercel/postgres'

async function getUsers() {
  const { rows } = await sql`SELECT * FROM users`
  return rows
}
```

## Segment Config

Configura el comportamiento de toda la ruta:

```tsx
// app/posts/page.tsx

// Forzar comportamiento dinámico
export const dynamic = 'force-dynamic'

// Forzar comportamiento estático
export const dynamic = 'force-static'

// Revalidación por tiempo
export const revalidate = 60

// Runtime
export const runtime = 'edge' // o 'nodejs'
```

## Resumen

| Estrategia | Cuándo usar |
|------------|-------------|
| `cache: 'force-cache'` | Datos que no cambian (default) |
| `cache: 'no-store'` | Datos en tiempo real |
| `next: { revalidate: N }` | Datos que cambian periódicamente |
| `Promise.all()` | Múltiples fetches independientes |
| `cache()` de React | Deduplicar dentro del request |
