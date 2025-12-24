# Patrones de Acceso a Datos

## Introducción

Organizar el acceso a datos de forma consistente mejora la mantenibilidad, testeabilidad y performance de tu aplicación. Exploraremos patrones probados para Next.js 14.

## Data Access Layer (DAL)

Centraliza todas las queries en una capa dedicada:

```
src/
├── lib/
│   └── dal/
│       ├── index.ts       # Re-exports
│       ├── users.ts       # Queries de usuarios
│       ├── posts.ts       # Queries de posts
│       └── courses.ts     # Queries de cursos
```

### Estructura básica

```tsx
// lib/dal/users.ts
import { prisma } from '@/lib/prisma'
import { cache } from 'react'

// Tipos
export type User = {
  id: string
  name: string
  email: string
  role: string
}

export type CreateUserInput = {
  name: string
  email: string
  password: string
}

// Queries
export const getUser = cache(async (id: string): Promise<User | null> => {
  return prisma.user.findUnique({
    where: { id },
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
    },
  })
})

export const getUserByEmail = cache(async (email: string): Promise<User | null> => {
  return prisma.user.findUnique({
    where: { email },
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
    },
  })
})

export async function getUsers(): Promise<User[]> {
  return prisma.user.findMany({
    select: {
      id: true,
      name: true,
      email: true,
      role: true,
    },
    orderBy: { createdAt: 'desc' },
  })
}

// Mutations
export async function createUser(input: CreateUserInput): Promise<User> {
  return prisma.user.create({
    data: {
      ...input,
      password: await hashPassword(input.password),
    },
  })
}

export async function updateUser(
  id: string,
  data: Partial<CreateUserInput>
): Promise<User> {
  return prisma.user.update({
    where: { id },
    data,
  })
}

export async function deleteUser(id: string): Promise<void> {
  await prisma.user.delete({ where: { id } })
}
```

### Re-export centralizado

```tsx
// lib/dal/index.ts
export * from './users'
export * from './posts'
export * from './courses'
```

### Uso en componentes

```tsx
// app/users/page.tsx
import { getUsers } from '@/lib/dal'

export default async function UsersPage() {
  const users = await getUsers()

  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

## Repository Pattern

Para aplicaciones más complejas, el patrón Repository añade abstracción:

```tsx
// lib/repositories/base.ts
export interface Repository<T, CreateInput, UpdateInput> {
  findById(id: string): Promise<T | null>
  findAll(): Promise<T[]>
  create(data: CreateInput): Promise<T>
  update(id: string, data: UpdateInput): Promise<T>
  delete(id: string): Promise<void>
}
```

```tsx
// lib/repositories/user.repository.ts
import { prisma } from '@/lib/prisma'
import { Repository } from './base'

export interface User {
  id: string
  name: string
  email: string
}

export interface CreateUserInput {
  name: string
  email: string
  password: string
}

export interface UpdateUserInput {
  name?: string
  email?: string
}

class UserRepository implements Repository<User, CreateUserInput, UpdateUserInput> {
  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
      select: { id: true, name: true, email: true },
    })
  }

  async findAll(): Promise<User[]> {
    return prisma.user.findMany({
      select: { id: true, name: true, email: true },
    })
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email },
      select: { id: true, name: true, email: true },
    })
  }

  async create(data: CreateUserInput): Promise<User> {
    return prisma.user.create({
      data: {
        ...data,
        password: await hashPassword(data.password),
      },
      select: { id: true, name: true, email: true },
    })
  }

  async update(id: string, data: UpdateUserInput): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
      select: { id: true, name: true, email: true },
    })
  }

  async delete(id: string): Promise<void> {
    await prisma.user.delete({ where: { id } })
  }
}

export const userRepository = new UserRepository()
```

## Data Transfer Objects (DTOs)

Separa la representación interna de la externa:

```tsx
// lib/dto/user.dto.ts

// Entidad de BD (interna)
interface UserEntity {
  id: string
  email: string
  password: string  // Nunca exponer
  name: string
  role: string
  createdAt: Date
  updatedAt: Date
}

// DTO público
export interface UserDTO {
  id: string
  email: string
  name: string
  role: string
}

// DTO para listados (menos datos)
export interface UserListDTO {
  id: string
  name: string
}

// Mapper
export function toUserDTO(user: UserEntity): UserDTO {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    role: user.role,
  }
}

export function toUserListDTO(user: UserEntity): UserListDTO {
  return {
    id: user.id,
    name: user.name,
  }
}
```

## Service Layer

Para lógica de negocio compleja, añade una capa de servicios:

```tsx
// lib/services/enrollment.service.ts
import { prisma } from '@/lib/prisma'
import { getUser } from '@/lib/dal/users'
import { getCourse } from '@/lib/dal/courses'

export class EnrollmentService {
  async enrollUser(userId: string, courseId: string) {
    // Validaciones de negocio
    const user = await getUser(userId)
    if (!user) throw new Error('Usuario no encontrado')

    const course = await getCourse(courseId)
    if (!course) throw new Error('Curso no encontrado')
    if (!course.isPublished) throw new Error('Curso no disponible')

    // Verificar si ya está inscrito
    const existing = await prisma.enrollment.findUnique({
      where: {
        userId_courseId: { userId, courseId },
      },
    })
    if (existing) throw new Error('Ya estás inscrito')

    // Verificar límite de estudiantes
    const enrollmentCount = await prisma.enrollment.count({
      where: { courseId },
    })
    if (course.maxStudents && enrollmentCount >= course.maxStudents) {
      throw new Error('Curso lleno')
    }

    // Crear inscripción
    const enrollment = await prisma.enrollment.create({
      data: { userId, courseId },
    })

    // Efectos secundarios
    await this.sendWelcomeEmail(user.email, course.title)
    await this.updateCourseStats(courseId)

    return enrollment
  }

  private async sendWelcomeEmail(email: string, courseTitle: string) {
    // Lógica de email
  }

  private async updateCourseStats(courseId: string) {
    // Actualizar contadores
  }
}

export const enrollmentService = new EnrollmentService()
```

## Preload Pattern

Optimiza queries paralelas:

```tsx
// lib/dal/courses.ts
import { cache } from 'react'

export const getCourse = cache(async (id: string) => {
  return prisma.course.findUnique({ where: { id } })
})

export const preloadCourse = (id: string) => {
  void getCourse(id)
}
```

```tsx
// app/courses/[id]/page.tsx
import { getCourse, preloadCourse } from '@/lib/dal'
import { getEnrollment, preloadEnrollment } from '@/lib/dal'

export default async function CoursePage({ params }) {
  // Iniciar ambas queries inmediatamente
  preloadCourse(params.id)
  preloadEnrollment(userId, params.id)

  // Esperar resultados
  const [course, enrollment] = await Promise.all([
    getCourse(params.id),
    getEnrollment(userId, params.id),
  ])

  return <CourseContent course={course} enrollment={enrollment} />
}
```

## Caching con unstable_cache

Para queries que no usan fetch:

```tsx
import { unstable_cache } from 'next/cache'

export const getCachedCourses = unstable_cache(
  async () => {
    return prisma.course.findMany({
      where: { isPublished: true },
    })
  },
  ['courses-list'],
  {
    tags: ['courses'],
    revalidate: 3600, // 1 hora
  }
)

// Invalidar
import { revalidateTag } from 'next/cache'

export async function createCourse(data: CreateCourseInput) {
  const course = await prisma.course.create({ data })
  revalidateTag('courses')
  return course
}
```

## Error Handling

```tsx
// lib/dal/errors.ts
export class NotFoundError extends Error {
  constructor(resource: string, id: string) {
    super(`${resource} con id ${id} no encontrado`)
    this.name = 'NotFoundError'
  }
}

export class ValidationError extends Error {
  constructor(message: string) {
    super(message)
    this.name = 'ValidationError'
  }
}
```

```tsx
// lib/dal/users.ts
import { NotFoundError } from './errors'

export async function getUserOrThrow(id: string): Promise<User> {
  const user = await prisma.user.findUnique({ where: { id } })

  if (!user) {
    throw new NotFoundError('User', id)
  }

  return user
}
```

```tsx
// app/users/[id]/page.tsx
import { getUserOrThrow } from '@/lib/dal'
import { notFound } from 'next/navigation'

export default async function UserPage({ params }) {
  try {
    const user = await getUserOrThrow(params.id)
    return <UserProfile user={user} />
  } catch (error) {
    if (error instanceof NotFoundError) {
      notFound()
    }
    throw error
  }
}
```

## Resumen de patrones

| Patrón | Cuándo usar |
|--------|-------------|
| DAL simple | Apps pequeñas/medianas |
| Repository | Apps grandes, múltiples fuentes de datos |
| Service Layer | Lógica de negocio compleja |
| DTOs | APIs públicas, seguridad de datos |
| Preload | Queries paralelas en Server Components |

## Estructura recomendada

```
src/
├── lib/
│   ├── dal/           # Data Access Layer
│   │   ├── index.ts
│   │   ├── users.ts
│   │   └── courses.ts
│   ├── services/      # Business Logic
│   │   └── enrollment.service.ts
│   ├── dto/           # Data Transfer Objects
│   │   └── user.dto.ts
│   └── prisma.ts      # Cliente Prisma
```
