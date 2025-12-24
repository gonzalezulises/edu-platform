# Roles y Permisos

## Introducción

Un sistema robusto de roles y permisos es esencial para aplicaciones multi-usuario. Implementaremos autorización basada en roles (RBAC) en Next.js 14.

## Diseño del sistema

### Modelo de datos

```sql
-- Tabla de roles
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de permisos
CREATE TABLE permissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT UNIQUE NOT NULL,  -- 'courses:create', 'users:delete'
  description TEXT
);

-- Relación roles-permisos
CREATE TABLE role_permissions (
  role_id UUID REFERENCES roles ON DELETE CASCADE,
  permission_id UUID REFERENCES permissions ON DELETE CASCADE,
  PRIMARY KEY (role_id, permission_id)
);

-- Usuario con rol
ALTER TABLE profiles ADD COLUMN role_id UUID REFERENCES roles;

-- Insertar roles base
INSERT INTO roles (name, description) VALUES
  ('admin', 'Acceso total al sistema'),
  ('instructor', 'Puede crear y gestionar cursos'),
  ('student', 'Puede tomar cursos');

-- Insertar permisos
INSERT INTO permissions (name, description) VALUES
  ('users:read', 'Ver usuarios'),
  ('users:write', 'Crear/editar usuarios'),
  ('users:delete', 'Eliminar usuarios'),
  ('courses:read', 'Ver cursos'),
  ('courses:write', 'Crear/editar cursos'),
  ('courses:delete', 'Eliminar cursos'),
  ('enrollments:manage', 'Gestionar inscripciones');
```

### Tipos TypeScript

```tsx
// types/auth.ts
export type Role = 'admin' | 'instructor' | 'student'

export type Permission =
  | 'users:read'
  | 'users:write'
  | 'users:delete'
  | 'courses:read'
  | 'courses:write'
  | 'courses:delete'
  | 'enrollments:manage'

export interface User {
  id: string
  email: string
  name: string
  role: Role
  permissions?: Permission[]
}

// Mapeo de roles a permisos
export const rolePermissions: Record<Role, Permission[]> = {
  admin: [
    'users:read',
    'users:write',
    'users:delete',
    'courses:read',
    'courses:write',
    'courses:delete',
    'enrollments:manage',
  ],
  instructor: [
    'courses:read',
    'courses:write',
    'enrollments:manage',
  ],
  student: [
    'courses:read',
  ],
}
```

## Utilidades de autorización

### Verificar permisos

```tsx
// lib/auth/permissions.ts
import { auth } from '@/auth'
import { rolePermissions, Permission, Role } from '@/types/auth'

export async function getCurrentUser() {
  const session = await auth()
  return session?.user
}

export async function hasPermission(permission: Permission): Promise<boolean> {
  const user = await getCurrentUser()
  if (!user) return false

  const role = user.role as Role
  return rolePermissions[role]?.includes(permission) ?? false
}

export async function hasRole(role: Role | Role[]): Promise<boolean> {
  const user = await getCurrentUser()
  if (!user) return false

  const roles = Array.isArray(role) ? role : [role]
  return roles.includes(user.role as Role)
}

export async function requirePermission(permission: Permission) {
  const allowed = await hasPermission(permission)
  if (!allowed) {
    throw new Error(`Missing permission: ${permission}`)
  }
}

export async function requireRole(role: Role | Role[]) {
  const allowed = await hasRole(role)
  if (!allowed) {
    throw new Error(`Insufficient role`)
  }
}
```

### Higher-Order Function para Server Actions

```tsx
// lib/auth/withAuth.ts
import { auth } from '@/auth'
import { Permission, Role, rolePermissions } from '@/types/auth'

type AuthOptions = {
  permission?: Permission
  role?: Role | Role[]
}

export function withAuth<T extends (...args: any[]) => Promise<any>>(
  action: T,
  options: AuthOptions
): T {
  return (async (...args: Parameters<T>) => {
    const session = await auth()

    if (!session?.user) {
      throw new Error('No autorizado')
    }

    const userRole = session.user.role as Role

    // Verificar rol
    if (options.role) {
      const roles = Array.isArray(options.role) ? options.role : [options.role]
      if (!roles.includes(userRole)) {
        throw new Error('Rol insuficiente')
      }
    }

    // Verificar permiso
    if (options.permission) {
      const userPermissions = rolePermissions[userRole] || []
      if (!userPermissions.includes(options.permission)) {
        throw new Error('Permiso denegado')
      }
    }

    return action(...args)
  }) as T
}
```

## Uso en Server Actions

```tsx
// actions/courses.ts
'use server'

import { withAuth } from '@/lib/auth/withAuth'
import { revalidatePath } from 'next/cache'

async function createCourseAction(formData: FormData) {
  const title = formData.get('title') as string
  const description = formData.get('description') as string

  const course = await db.course.create({
    data: { title, description },
  })

  revalidatePath('/courses')
  return course
}

// Proteger la acción
export const createCourse = withAuth(createCourseAction, {
  permission: 'courses:write',
})

// También por rol
export const deleteCourse = withAuth(
  async (id: string) => {
    await db.course.delete({ where: { id } })
    revalidatePath('/courses')
  },
  { role: 'admin' }
)
```

## Uso en Server Components

### Página protegida

```tsx
// app/admin/page.tsx
import { auth } from '@/auth'
import { redirect } from 'next/navigation'
import { hasRole } from '@/lib/auth/permissions'

export default async function AdminPage() {
  const session = await auth()

  if (!session) {
    redirect('/login')
  }

  const isAdmin = await hasRole('admin')
  if (!isAdmin) {
    redirect('/unauthorized')
  }

  return (
    <div>
      <h1>Panel de Administración</h1>
      {/* Contenido de admin */}
    </div>
  )
}
```

### Renderizado condicional

```tsx
// app/courses/[id]/page.tsx
import { auth } from '@/auth'
import { hasPermission } from '@/lib/auth/permissions'
import { EditButton, DeleteButton } from '@/components/courses'

export default async function CoursePage({ params }) {
  const session = await auth()
  const course = await getCourse(params.id)

  const canEdit = await hasPermission('courses:write')
  const canDelete = await hasPermission('courses:delete')

  return (
    <div>
      <h1>{course.title}</h1>
      <p>{course.description}</p>

      {canEdit && <EditButton courseId={course.id} />}
      {canDelete && <DeleteButton courseId={course.id} />}
    </div>
  )
}
```

## Componentes de autorización

### Componente de protección

```tsx
// components/auth/Authorized.tsx
import { auth } from '@/auth'
import { Permission, Role, rolePermissions } from '@/types/auth'

interface AuthorizedProps {
  children: React.ReactNode
  permission?: Permission
  role?: Role | Role[]
  fallback?: React.ReactNode
}

export async function Authorized({
  children,
  permission,
  role,
  fallback = null,
}: AuthorizedProps) {
  const session = await auth()

  if (!session?.user) {
    return fallback
  }

  const userRole = session.user.role as Role

  // Verificar rol
  if (role) {
    const roles = Array.isArray(role) ? role : [role]
    if (!roles.includes(userRole)) {
      return fallback
    }
  }

  // Verificar permiso
  if (permission) {
    const userPermissions = rolePermissions[userRole] || []
    if (!userPermissions.includes(permission)) {
      return fallback
    }
  }

  return children
}
```

### Uso del componente

```tsx
// app/dashboard/page.tsx
import { Authorized } from '@/components/auth/Authorized'

export default async function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Solo visible para admins */}
      <Authorized role="admin">
        <AdminPanel />
      </Authorized>

      {/* Visible para instructores y admins */}
      <Authorized role={['admin', 'instructor']}>
        <InstructorTools />
      </Authorized>

      {/* Basado en permiso específico */}
      <Authorized permission="courses:write">
        <CreateCourseButton />
      </Authorized>

      {/* Con fallback */}
      <Authorized
        permission="users:read"
        fallback={<p>No tienes acceso a esta sección</p>}
      >
        <UsersList />
      </Authorized>
    </div>
  )
}
```

## Hooks para Client Components

```tsx
// hooks/useAuth.ts
'use client'

import { useSession } from 'next-auth/react'
import { Permission, Role, rolePermissions } from '@/types/auth'

export function useAuth() {
  const { data: session, status } = useSession()

  const user = session?.user
  const role = user?.role as Role | undefined

  const hasPermission = (permission: Permission): boolean => {
    if (!role) return false
    return rolePermissions[role]?.includes(permission) ?? false
  }

  const hasRole = (targetRole: Role | Role[]): boolean => {
    if (!role) return false
    const roles = Array.isArray(targetRole) ? targetRole : [targetRole]
    return roles.includes(role)
  }

  return {
    user,
    role,
    isAuthenticated: !!user,
    isLoading: status === 'loading',
    hasPermission,
    hasRole,
  }
}
```

### Uso del hook

```tsx
'use client'

import { useAuth } from '@/hooks/useAuth'

export function CourseActions({ courseId }: { courseId: string }) {
  const { hasPermission, isLoading } = useAuth()

  if (isLoading) return <Skeleton />

  return (
    <div className="flex gap-2">
      {hasPermission('courses:write') && (
        <button>Editar</button>
      )}
      {hasPermission('courses:delete') && (
        <button className="text-red-600">Eliminar</button>
      )}
    </div>
  )
}
```

## Página de error

```tsx
// app/unauthorized/page.tsx
import Link from 'next/link'

export default function UnauthorizedPage() {
  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-red-600">403</h1>
        <h2 className="text-2xl mt-2">Acceso Denegado</h2>
        <p className="text-gray-600 mt-4">
          No tienes permisos para acceder a esta página.
        </p>
        <Link
          href="/dashboard"
          className="mt-6 inline-block bg-blue-600 text-white px-6 py-2 rounded"
        >
          Volver al Dashboard
        </Link>
      </div>
    </div>
  )
}
```

## Resumen

| Nivel | Implementación |
|-------|----------------|
| Request | Middleware (roles básicos) |
| Página | Server Component con `auth()` |
| UI | Componente `<Authorized>` |
| Action | `withAuth()` HOF |
| Cliente | `useAuth()` hook |

## Buenas prácticas

1. **Verificar en múltiples niveles**: Middleware + Server + Actions
2. **Denegar por defecto**: Si no hay permiso explícito, denegar
3. **Roles simples, permisos granulares**: Evitar demasiados roles
4. **Cache de permisos**: Evitar queries repetidas
5. **Logs de auditoría**: Registrar accesos denegados
6. **Separar autenticación de autorización**: Auth ≠ AuthZ
