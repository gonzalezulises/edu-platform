# Prisma ORM

## Introducción

Prisma es un ORM moderno para Node.js y TypeScript. Proporciona un cliente de base de datos type-safe, migraciones declarativas y una excelente experiencia de desarrollo.

## Instalación

```bash
npm install prisma @prisma/client
npx prisma init
```

Esto crea:
- `prisma/schema.prisma` - Definición del modelo
- `.env` - Variables de entorno

## Configuración del Schema

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  password  String
  role      Role     @default(USER)
  posts     Post[]
  profile   Profile?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Profile {
  id     String  @id @default(cuid())
  bio    String?
  avatar String?
  userId String  @unique
  user   User    @relation(fields: [userId], references: [id], onDelete: Cascade)
}

model Post {
  id        String   @id @default(cuid())
  title     String
  content   String?
  published Boolean  @default(false)
  authorId  String
  author    User     @relation(fields: [authorId], references: [id])
  tags      Tag[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Tag {
  id    String @id @default(cuid())
  name  String @unique
  posts Post[]
}

enum Role {
  USER
  ADMIN
  MODERATOR
}
```

## Migraciones

```bash
# Crear migración
npx prisma migrate dev --name init

# Aplicar migraciones en producción
npx prisma migrate deploy

# Reset de BD (desarrollo)
npx prisma migrate reset

# Ver estado de migraciones
npx prisma migrate status
```

## Cliente Prisma

### Singleton pattern

```tsx
// lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma = globalForPrisma.prisma ?? new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query'] : [],
})

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}
```

## Queries en Server Components

### Fetch básico

```tsx
// app/posts/page.tsx
import { prisma } from '@/lib/prisma'

export default async function PostsPage() {
  const posts = await prisma.post.findMany({
    where: { published: true },
    orderBy: { createdAt: 'desc' },
  })

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### Con relaciones

```tsx
const posts = await prisma.post.findMany({
  include: {
    author: {
      select: {
        name: true,
        email: true,
      },
    },
    tags: true,
  },
})

// O con select específico
const posts = await prisma.post.findMany({
  select: {
    id: true,
    title: true,
    author: {
      select: { name: true },
    },
  },
})
```

### Filtros avanzados

```tsx
// Múltiples condiciones
const posts = await prisma.post.findMany({
  where: {
    AND: [
      { published: true },
      { authorId: userId },
    ],
  },
})

// OR
const posts = await prisma.post.findMany({
  where: {
    OR: [
      { title: { contains: searchTerm } },
      { content: { contains: searchTerm } },
    ],
  },
})

// NOT
const posts = await prisma.post.findMany({
  where: {
    NOT: { authorId: bannedUserId },
  },
})

// Filtros de texto
const posts = await prisma.post.findMany({
  where: {
    title: {
      contains: 'prisma',
      mode: 'insensitive', // Case insensitive
    },
  },
})

// Relaciones
const users = await prisma.user.findMany({
  where: {
    posts: {
      some: { published: true },
    },
  },
})
```

### Paginación

```tsx
// Offset pagination
const page = 1
const pageSize = 10

const posts = await prisma.post.findMany({
  skip: (page - 1) * pageSize,
  take: pageSize,
  orderBy: { createdAt: 'desc' },
})

// Cursor pagination (más eficiente)
const posts = await prisma.post.findMany({
  take: 10,
  cursor: { id: lastPostId },
  skip: 1, // Saltar el cursor
  orderBy: { createdAt: 'desc' },
})
```

## Mutaciones con Server Actions

### Create

```tsx
'use server'

import { prisma } from '@/lib/prisma'
import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const post = await prisma.post.create({
    data: {
      title: formData.get('title') as string,
      content: formData.get('content') as string,
      authorId: 'user-id', // Obtener de sesión
    },
  })

  revalidatePath('/posts')
  return post
}
```

### Create con relaciones

```tsx
// Crear post con tags
const post = await prisma.post.create({
  data: {
    title: 'Mi post',
    content: 'Contenido...',
    author: {
      connect: { id: userId },
    },
    tags: {
      connectOrCreate: [
        {
          where: { name: 'javascript' },
          create: { name: 'javascript' },
        },
        {
          where: { name: 'prisma' },
          create: { name: 'prisma' },
        },
      ],
    },
  },
})
```

### Update

```tsx
'use server'

export async function updatePost(id: string, formData: FormData) {
  const post = await prisma.post.update({
    where: { id },
    data: {
      title: formData.get('title') as string,
      content: formData.get('content') as string,
    },
  })

  revalidatePath('/posts')
  revalidatePath(`/posts/${id}`)
  return post
}
```

### Upsert

```tsx
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { name: 'Nombre actualizado' },
  create: {
    email: 'user@example.com',
    name: 'Nuevo usuario',
    password: hashedPassword,
  },
})
```

### Delete

```tsx
'use server'

export async function deletePost(id: string) {
  await prisma.post.delete({
    where: { id },
  })

  revalidatePath('/posts')
}
```

## Transacciones

```tsx
// Transacción interactiva
const result = await prisma.$transaction(async (tx) => {
  // Decrementar stock
  const product = await tx.product.update({
    where: { id: productId },
    data: { stock: { decrement: quantity } },
  })

  if (product.stock < 0) {
    throw new Error('Stock insuficiente')
  }

  // Crear orden
  const order = await tx.order.create({
    data: {
      productId,
      quantity,
      userId,
    },
  })

  return order
})

// Transacción batch
const [posts, users] = await prisma.$transaction([
  prisma.post.findMany(),
  prisma.user.count(),
])
```

## Agregaciones

```tsx
// Count
const count = await prisma.post.count({
  where: { published: true },
})

// Group by
const postsByAuthor = await prisma.post.groupBy({
  by: ['authorId'],
  _count: { id: true },
  orderBy: { _count: { id: 'desc' } },
})

// Aggregate
const stats = await prisma.product.aggregate({
  _avg: { price: true },
  _max: { price: true },
  _min: { price: true },
  _sum: { price: true },
})
```

## Prisma Studio

Interfaz gráfica para explorar y editar datos:

```bash
npx prisma studio
```

Abre http://localhost:5555 con una UI para ver y editar tablas.

## Optimizaciones

### Preload pattern

```tsx
import { cache } from 'react'

export const getUser = cache(async (id: string) => {
  return prisma.user.findUnique({ where: { id } })
})

export const preloadUser = (id: string) => {
  void getUser(id)
}
```

### Select solo lo necesario

```tsx
// ❌ Trae todo
const user = await prisma.user.findUnique({
  where: { id },
  include: { posts: true, profile: true },
})

// ✅ Solo lo necesario
const user = await prisma.user.findUnique({
  where: { id },
  select: {
    id: true,
    name: true,
    email: true,
  },
})
```

## Resumen

| Operación | Método Prisma |
|-----------|---------------|
| Leer uno | `findUnique`, `findFirst` |
| Leer muchos | `findMany` |
| Crear | `create`, `createMany` |
| Actualizar | `update`, `updateMany` |
| Upsert | `upsert` |
| Eliminar | `delete`, `deleteMany` |
| Contar | `count` |
| Agregar | `aggregate`, `groupBy` |

## Prisma vs Supabase

| Aspecto | Prisma | Supabase |
|---------|--------|----------|
| Tipo | ORM | BaaS |
| Query Builder | Type-safe | SDK |
| Migraciones | Sí | Sí |
| RLS | No (código) | Sí (BD) |
| Real-time | No | Sí |
| Storage | No | Sí |
| Auth | No | Sí |
