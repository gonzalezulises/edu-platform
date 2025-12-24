# Mocking y Test Doubles

## Introducción

Los mocks y test doubles permiten aislar el código que estás testeando, controlando dependencias externas como APIs, bases de datos y servicios.

## Tipos de Test Doubles

| Tipo | Descripción | Uso |
|------|-------------|-----|
| **Dummy** | Objeto que se pasa pero no se usa | Llenar parámetros requeridos |
| **Stub** | Retorna valores predefinidos | Simular respuestas |
| **Spy** | Registra llamadas | Verificar interacciones |
| **Mock** | Stub + verificación de comportamiento | Testing completo |
| **Fake** | Implementación funcional simplificada | In-memory DB |

## Jest Mocks básicos

### Mock de funciones

```ts
// Crear mock
const mockFn = jest.fn()

// Con valor de retorno
const mockFn = jest.fn().mockReturnValue('hello')

// Con implementación
const mockFn = jest.fn((x) => x * 2)

// Async
const mockFn = jest.fn().mockResolvedValue({ data: 'result' })
const mockFn = jest.fn().mockRejectedValue(new Error('fail'))
```

### Verificar llamadas

```ts
const mockFn = jest.fn()

mockFn('arg1', 'arg2')
mockFn('arg3')

expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledTimes(2)
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2')
expect(mockFn).toHaveBeenLastCalledWith('arg3')
expect(mockFn).toHaveBeenNthCalledWith(1, 'arg1', 'arg2')
```

## Mock de módulos

### Mock completo

```ts
// __tests__/api.test.ts
jest.mock('@/lib/api')

import { fetchUser, fetchPosts } from '@/lib/api'

test('uses mocked api', async () => {
  ;(fetchUser as jest.Mock).mockResolvedValue({ id: '1', name: 'John' })
  ;(fetchPosts as jest.Mock).mockResolvedValue([{ id: '1', title: 'Post' }])

  // Tu código que usa estas funciones
})
```

### Mock parcial

```ts
jest.mock('@/lib/api', () => ({
  ...jest.requireActual('@/lib/api'), // Mantener funciones reales
  fetchUser: jest.fn(), // Solo mockear esta
}))
```

### Mock manual

```ts
// __mocks__/@/lib/api.ts
export const fetchUser = jest.fn()
export const fetchPosts = jest.fn()
export const createPost = jest.fn()
```

```ts
// __tests__/component.test.ts
jest.mock('@/lib/api') // Usa el mock manual automáticamente

import { fetchUser } from '@/lib/api'
```

## Mock de Prisma

```ts
// __tests__/__mocks__/prisma.ts
import { PrismaClient } from '@prisma/client'
import { mockDeep, DeepMockProxy } from 'jest-mock-extended'

export const prismaMock = mockDeep<PrismaClient>()

jest.mock('@/lib/prisma', () => ({
  prisma: prismaMock,
}))
```

```ts
// __tests__/users.test.ts
import { prismaMock } from './__mocks__/prisma'
import { getUser, createUser } from '@/lib/dal/users'

describe('Users DAL', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  test('getUser returns user', async () => {
    const mockUser = { id: '1', name: 'John', email: 'john@test.com' }
    prismaMock.user.findUnique.mockResolvedValue(mockUser)

    const user = await getUser('1')

    expect(user).toEqual(mockUser)
    expect(prismaMock.user.findUnique).toHaveBeenCalledWith({
      where: { id: '1' },
    })
  })

  test('createUser creates and returns user', async () => {
    const input = { name: 'John', email: 'john@test.com' }
    const mockUser = { id: '1', ...input }
    prismaMock.user.create.mockResolvedValue(mockUser)

    const user = await createUser(input)

    expect(user).toEqual(mockUser)
    expect(prismaMock.user.create).toHaveBeenCalledWith({
      data: input,
    })
  })
})
```

## Mock de fetch

```ts
// Setup global
beforeEach(() => {
  global.fetch = jest.fn()
})

afterEach(() => {
  jest.resetAllMocks()
})

test('fetches data correctly', async () => {
  const mockData = { id: 1, title: 'Test' }

  ;(global.fetch as jest.Mock).mockResolvedValue({
    ok: true,
    json: () => Promise.resolve(mockData),
  })

  const result = await fetchPost('1')

  expect(result).toEqual(mockData)
  expect(fetch).toHaveBeenCalledWith('/api/posts/1')
})

test('handles fetch error', async () => {
  ;(global.fetch as jest.Mock).mockResolvedValue({
    ok: false,
    status: 404,
  })

  await expect(fetchPost('999')).rejects.toThrow('Not found')
})
```

## Mock de Next.js

### next/navigation

```ts
// jest.setup.js
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(() => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
    prefetch: jest.fn(),
  })),
  usePathname: jest.fn(() => '/'),
  useSearchParams: jest.fn(() => new URLSearchParams()),
  redirect: jest.fn(),
}))
```

```ts
// test
import { useRouter, redirect } from 'next/navigation'

test('redirects after action', async () => {
  await myAction()

  expect(redirect).toHaveBeenCalledWith('/success')
})

test('navigates on button click', async () => {
  const push = jest.fn()
  ;(useRouter as jest.Mock).mockReturnValue({ push })

  render(<MyComponent />)
  await userEvent.click(screen.getByRole('button'))

  expect(push).toHaveBeenCalledWith('/dashboard')
})
```

### next/cache

```ts
jest.mock('next/cache', () => ({
  revalidatePath: jest.fn(),
  revalidateTag: jest.fn(),
  unstable_cache: jest.fn((fn) => fn),
}))

import { revalidatePath } from 'next/cache'

test('revalidates after create', async () => {
  await createPost({ title: 'Test' })

  expect(revalidatePath).toHaveBeenCalledWith('/posts')
})
```

### next/headers

```ts
jest.mock('next/headers', () => ({
  cookies: jest.fn(() => ({
    get: jest.fn(),
    set: jest.fn(),
    delete: jest.fn(),
    getAll: jest.fn(() => []),
  })),
  headers: jest.fn(() => new Headers()),
}))
```

## Spies

Los spies observan funciones reales sin reemplazarlas:

```ts
// Spy en método existente
const consoleSpy = jest.spyOn(console, 'log')

myFunction()

expect(consoleSpy).toHaveBeenCalledWith('expected message')

consoleSpy.mockRestore() // Restaurar original
```

```ts
// Spy con mock de implementación
const dateSpy = jest.spyOn(Date, 'now').mockReturnValue(1234567890)

const result = getTimestamp()

expect(result).toBe(1234567890)

dateSpy.mockRestore()
```

## Fake implementations

```ts
// Fake in-memory storage
class FakeStorage implements Storage {
  private store: Record<string, string> = {}

  get length() {
    return Object.keys(this.store).length
  }

  key(index: number) {
    return Object.keys(this.store)[index] || null
  }

  getItem(key: string) {
    return this.store[key] || null
  }

  setItem(key: string, value: string) {
    this.store[key] = value
  }

  removeItem(key: string) {
    delete this.store[key]
  }

  clear() {
    this.store = {}
  }
}

// Uso en tests
beforeEach(() => {
  Object.defineProperty(window, 'localStorage', {
    value: new FakeStorage(),
  })
})
```

## Testing con timers

```ts
// Usar fake timers
jest.useFakeTimers()

test('debounce waits before calling', () => {
  const callback = jest.fn()
  const debounced = debounce(callback, 1000)

  debounced()
  debounced()
  debounced()

  expect(callback).not.toHaveBeenCalled()

  jest.advanceTimersByTime(1000)

  expect(callback).toHaveBeenCalledTimes(1)
})

// Limpiar
afterEach(() => {
  jest.useRealTimers()
})
```

## Patrón de inyección de dependencias

```ts
// lib/email.ts
interface EmailService {
  send(to: string, subject: string, body: string): Promise<void>
}

export class RealEmailService implements EmailService {
  async send(to: string, subject: string, body: string) {
    // Enviar email real
  }
}

// Para testing
export class FakeEmailService implements EmailService {
  sentEmails: Array<{ to: string; subject: string; body: string }> = []

  async send(to: string, subject: string, body: string) {
    this.sentEmails.push({ to, subject, body })
  }
}
```

```ts
// Test
test('sends welcome email', async () => {
  const emailService = new FakeEmailService()

  await registerUser({ email: 'test@example.com' }, emailService)

  expect(emailService.sentEmails).toHaveLength(1)
  expect(emailService.sentEmails[0].to).toBe('test@example.com')
  expect(emailService.sentEmails[0].subject).toContain('Welcome')
})
```

## Resumen

| Técnica | Cuándo usar |
|---------|-------------|
| `jest.fn()` | Mock de funciones individuales |
| `jest.mock()` | Mock de módulos completos |
| `jest.spyOn()` | Observar sin reemplazar |
| Fake | Implementación alternativa simple |
| DI | Código más testeable |

## Buenas prácticas

1. **Mock en límites**: APIs, DB, servicios externos
2. **No mockear todo**: Código bajo test debe ser real
3. **Limpiar mocks**: `beforeEach` con `jest.clearAllMocks()`
4. **Verificar llamadas**: Asegurar que mocks se usaron correctamente
5. **Usar tipos**: `as jest.Mock` para TypeScript
6. **Considerar DI**: Hace código más testeable
