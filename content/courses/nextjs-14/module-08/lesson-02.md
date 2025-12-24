# Testing de Server Components y Actions

## Introducción

Next.js 14 introduce patrones nuevos que requieren estrategias de testing específicas. Aprenderemos a testear Server Components, Server Actions y el flujo completo de datos.

## Testing de Server Components

### El desafío

Los Server Components son async y se ejecutan en el servidor. No podemos renderizarlos directamente con React Testing Library.

### Estrategia 1: Testear la lógica separada

```tsx
// lib/data/posts.ts
export async function getPosts() {
  const res = await fetch('https://api.example.com/posts')
  return res.json()
}

// app/posts/page.tsx
import { getPosts } from '@/lib/data/posts'

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

```tsx
// __tests__/lib/data/posts.test.ts
import { getPosts } from '@/lib/data/posts'

// Mock global fetch
global.fetch = jest.fn()

describe('getPosts', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('returns posts from API', async () => {
    const mockPosts = [
      { id: '1', title: 'Post 1' },
      { id: '2', title: 'Post 2' },
    ]

    ;(global.fetch as jest.Mock).mockResolvedValue({
      json: () => Promise.resolve(mockPosts),
    })

    const posts = await getPosts()

    expect(posts).toEqual(mockPosts)
    expect(fetch).toHaveBeenCalledWith('https://api.example.com/posts')
  })
})
```

### Estrategia 2: Extraer componentes de presentación

```tsx
// components/PostList.tsx (Client Component presentacional)
'use client'

interface Post {
  id: string
  title: string
}

export function PostList({ posts }: { posts: Post[] }) {
  if (posts.length === 0) {
    return <p>No hay posts</p>
  }

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

```tsx
// __tests__/components/PostList.test.tsx
import { render, screen } from '@testing-library/react'
import { PostList } from '@/components/PostList'

describe('PostList', () => {
  it('renders list of posts', () => {
    const posts = [
      { id: '1', title: 'First Post' },
      { id: '2', title: 'Second Post' },
    ]

    render(<PostList posts={posts} />)

    expect(screen.getByText('First Post')).toBeInTheDocument()
    expect(screen.getByText('Second Post')).toBeInTheDocument()
  })

  it('shows empty message when no posts', () => {
    render(<PostList posts={[]} />)

    expect(screen.getByText('No hay posts')).toBeInTheDocument()
  })
})
```

## Testing de Server Actions

### Setup para testing de actions

```tsx
// __tests__/actions/posts.test.ts
import { createPost, deletePost } from '@/actions/posts'
import { prisma } from '@/lib/prisma'
import { revalidatePath } from 'next/cache'

// Mock de Prisma
jest.mock('@/lib/prisma', () => ({
  prisma: {
    post: {
      create: jest.fn(),
      delete: jest.fn(),
    },
  },
}))

// Mock de next/cache
jest.mock('next/cache', () => ({
  revalidatePath: jest.fn(),
}))

// Mock de auth
jest.mock('@/auth', () => ({
  auth: jest.fn(() => Promise.resolve({ user: { id: 'user-1' } })),
}))
```

### Testing de action de creación

```tsx
// actions/posts.ts
'use server'

import { auth } from '@/auth'
import { prisma } from '@/lib/prisma'
import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const session = await auth()
  if (!session?.user) {
    return { error: 'No autorizado' }
  }

  const title = formData.get('title') as string
  if (!title || title.length < 3) {
    return { error: 'Título muy corto' }
  }

  const post = await prisma.post.create({
    data: {
      title,
      authorId: session.user.id,
    },
  })

  revalidatePath('/posts')
  return { success: true, post }
}
```

```tsx
// __tests__/actions/posts.test.ts
describe('createPost', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('creates post successfully', async () => {
    const mockPost = { id: '1', title: 'Test Post' }
    ;(prisma.post.create as jest.Mock).mockResolvedValue(mockPost)

    const formData = new FormData()
    formData.append('title', 'Test Post')

    const result = await createPost(formData)

    expect(result.success).toBe(true)
    expect(result.post).toEqual(mockPost)
    expect(prisma.post.create).toHaveBeenCalledWith({
      data: {
        title: 'Test Post',
        authorId: 'user-1',
      },
    })
    expect(revalidatePath).toHaveBeenCalledWith('/posts')
  })

  it('returns error for short title', async () => {
    const formData = new FormData()
    formData.append('title', 'AB')

    const result = await createPost(formData)

    expect(result.error).toBe('Título muy corto')
    expect(prisma.post.create).not.toHaveBeenCalled()
  })

  it('returns error when not authenticated', async () => {
    const { auth } = require('@/auth')
    auth.mockResolvedValueOnce(null)

    const formData = new FormData()
    formData.append('title', 'Test Post')

    const result = await createPost(formData)

    expect(result.error).toBe('No autorizado')
  })
})
```

## Testing de validación con Zod

```tsx
// __tests__/schemas/post.test.ts
import { CreatePostSchema } from '@/schemas/post'

describe('CreatePostSchema', () => {
  it('validates correct input', () => {
    const result = CreatePostSchema.safeParse({
      title: 'Valid Title',
      content: 'This is valid content',
    })

    expect(result.success).toBe(true)
  })

  it('rejects empty title', () => {
    const result = CreatePostSchema.safeParse({
      title: '',
      content: 'Content',
    })

    expect(result.success).toBe(false)
    if (!result.success) {
      expect(result.error.issues[0].path).toContain('title')
    }
  })

  it('rejects short title', () => {
    const result = CreatePostSchema.safeParse({
      title: 'Ab',
      content: 'Content',
    })

    expect(result.success).toBe(false)
  })
})
```

## Integration Testing con formularios

```tsx
// __tests__/integration/CreatePostForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { CreatePostForm } from '@/components/CreatePostForm'
import { createPost } from '@/actions/posts'

jest.mock('@/actions/posts')

describe('CreatePostForm integration', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('submits form and shows success', async () => {
    ;(createPost as jest.Mock).mockResolvedValue({
      success: true,
      post: { id: '1', title: 'New Post' },
    })

    render(<CreatePostForm />)

    await userEvent.type(
      screen.getByLabelText(/título/i),
      'New Post'
    )
    await userEvent.click(
      screen.getByRole('button', { name: /crear/i })
    )

    await waitFor(() => {
      expect(screen.getByText(/post creado/i)).toBeInTheDocument()
    })
  })

  it('shows validation error', async () => {
    ;(createPost as jest.Mock).mockResolvedValue({
      error: 'Título muy corto',
    })

    render(<CreatePostForm />)

    await userEvent.type(screen.getByLabelText(/título/i), 'Ab')
    await userEvent.click(screen.getByRole('button', { name: /crear/i }))

    await waitFor(() => {
      expect(screen.getByText(/título muy corto/i)).toBeInTheDocument()
    })
  })

  it('disables button while submitting', async () => {
    ;(createPost as jest.Mock).mockImplementation(
      () => new Promise((resolve) => setTimeout(resolve, 100))
    )

    render(<CreatePostForm />)

    await userEvent.type(screen.getByLabelText(/título/i), 'New Post')
    await userEvent.click(screen.getByRole('button', { name: /crear/i }))

    expect(screen.getByRole('button')).toBeDisabled()
  })
})
```

## Testing de hooks personalizados

```tsx
// hooks/useAuth.ts
'use client'

import { useSession } from 'next-auth/react'

export function useAuth() {
  const { data: session, status } = useSession()

  return {
    user: session?.user,
    isLoading: status === 'loading',
    isAuthenticated: status === 'authenticated',
  }
}
```

```tsx
// __tests__/hooks/useAuth.test.tsx
import { renderHook } from '@testing-library/react'
import { useAuth } from '@/hooks/useAuth'
import { useSession } from 'next-auth/react'

jest.mock('next-auth/react')

describe('useAuth', () => {
  it('returns loading state', () => {
    ;(useSession as jest.Mock).mockReturnValue({
      data: null,
      status: 'loading',
    })

    const { result } = renderHook(() => useAuth())

    expect(result.current.isLoading).toBe(true)
    expect(result.current.isAuthenticated).toBe(false)
  })

  it('returns authenticated user', () => {
    ;(useSession as jest.Mock).mockReturnValue({
      data: { user: { id: '1', name: 'John' } },
      status: 'authenticated',
    })

    const { result } = renderHook(() => useAuth())

    expect(result.current.isAuthenticated).toBe(true)
    expect(result.current.user?.name).toBe('John')
  })
})
```

## Testing de Data Access Layer

```tsx
// __tests__/lib/dal/users.test.ts
import { getUser, createUser } from '@/lib/dal/users'
import { prisma } from '@/lib/prisma'

jest.mock('@/lib/prisma')

describe('Users DAL', () => {
  describe('getUser', () => {
    it('returns user by id', async () => {
      const mockUser = { id: '1', name: 'John', email: 'john@test.com' }
      ;(prisma.user.findUnique as jest.Mock).mockResolvedValue(mockUser)

      const user = await getUser('1')

      expect(user).toEqual(mockUser)
      expect(prisma.user.findUnique).toHaveBeenCalledWith({
        where: { id: '1' },
        select: expect.any(Object),
      })
    })

    it('returns null for non-existent user', async () => {
      ;(prisma.user.findUnique as jest.Mock).mockResolvedValue(null)

      const user = await getUser('999')

      expect(user).toBeNull()
    })
  })
})
```

## Resumen

| Qué testear | Cómo |
|-------------|------|
| Funciones de datos | Mock fetch/DB, test directamente |
| Server Components | Extraer presentación, testear lógica |
| Server Actions | Mock deps, test con FormData |
| Validación | Test schemas directamente |
| Hooks | renderHook con mocks |

## Buenas prácticas

1. **Separar lógica de presentación**: Facilita testing
2. **Mock en los límites**: DB, APIs, auth
3. **Test happy path + errores**: Ambos casos
4. **Usa FormData real**: Para testing de actions
5. **Limpia mocks**: beforeEach con jest.clearAllMocks()
6. **Test integración**: Formularios completos
