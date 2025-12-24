# Testing con Jest y React Testing Library

## Introducción

El testing asegura que tu aplicación funcione correctamente y facilita refactorizaciones seguras. Configuraremos Jest con React Testing Library para Next.js 14.

## Instalación

```bash
npm install -D jest jest-environment-jsdom @testing-library/react @testing-library/jest-dom @testing-library/user-event
```

## Configuración

### jest.config.js

```js
// jest.config.js
const nextJest = require('next/jest')

const createJestConfig = nextJest({
  dir: './', // Path al directorio de Next.js
})

const customJestConfig = {
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jest-environment-jsdom',
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  testPathIgnorePatterns: ['<rootDir>/e2e/'],
}

module.exports = createJestConfig(customJestConfig)
```

### jest.setup.js

```js
// jest.setup.js
import '@testing-library/jest-dom'

// Mock de next/navigation
jest.mock('next/navigation', () => ({
  useRouter() {
    return {
      push: jest.fn(),
      replace: jest.fn(),
      prefetch: jest.fn(),
      back: jest.fn(),
    }
  },
  usePathname() {
    return '/'
  },
  useSearchParams() {
    return new URLSearchParams()
  },
}))
```

### Scripts en package.json

```json
{
  "scripts": {
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

## Primer test

```tsx
// __tests__/components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Button } from '@/components/ui/Button'

describe('Button', () => {
  it('renders with text', () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText('Click me')).toBeInTheDocument()
  })

  it('calls onClick when clicked', async () => {
    const handleClick = jest.fn()
    render(<Button onClick={handleClick}>Click me</Button>)

    await userEvent.click(screen.getByText('Click me'))

    expect(handleClick).toHaveBeenCalledTimes(1)
  })

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Click me</Button>)

    expect(screen.getByText('Click me')).toBeDisabled()
  })
})
```

## Queries de Testing Library

### Por prioridad (orden recomendado)

```tsx
// 1. getByRole - Más accesible
screen.getByRole('button', { name: /submit/i })
screen.getByRole('textbox', { name: /email/i })
screen.getByRole('heading', { level: 1 })

// 2. getByLabelText - Para inputs
screen.getByLabelText(/email/i)

// 3. getByPlaceholderText
screen.getByPlaceholderText(/ingresa tu email/i)

// 4. getByText - Para contenido estático
screen.getByText(/bienvenido/i)

// 5. getByTestId - Último recurso
screen.getByTestId('custom-element')
```

### Variantes

```tsx
// getBy - Lanza error si no encuentra
screen.getByText('Hello')

// queryBy - Retorna null si no encuentra
screen.queryByText('Hello')

// findBy - Async, espera a que aparezca
await screen.findByText('Hello')

// getAllBy - Múltiples elementos
screen.getAllByRole('listitem')
```

## Testing de componentes

### Componente con props

```tsx
// components/UserCard.tsx
interface UserCardProps {
  name: string
  email: string
  isAdmin?: boolean
}

export function UserCard({ name, email, isAdmin }: UserCardProps) {
  return (
    <div className="p-4 border rounded">
      <h2>{name}</h2>
      <p>{email}</p>
      {isAdmin && <span className="badge">Admin</span>}
    </div>
  )
}
```

```tsx
// __tests__/components/UserCard.test.tsx
import { render, screen } from '@testing-library/react'
import { UserCard } from '@/components/UserCard'

describe('UserCard', () => {
  const defaultProps = {
    name: 'John Doe',
    email: 'john@example.com',
  }

  it('renders user name and email', () => {
    render(<UserCard {...defaultProps} />)

    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })

  it('shows admin badge when isAdmin is true', () => {
    render(<UserCard {...defaultProps} isAdmin />)

    expect(screen.getByText('Admin')).toBeInTheDocument()
  })

  it('does not show admin badge when isAdmin is false', () => {
    render(<UserCard {...defaultProps} isAdmin={false} />)

    expect(screen.queryByText('Admin')).not.toBeInTheDocument()
  })
})
```

### Componente con estado

```tsx
// components/Counter.tsx
'use client'

import { useState } from 'react'

export function Counter({ initialCount = 0 }: { initialCount?: number }) {
  const [count, setCount] = useState(initialCount)

  return (
    <div>
      <span data-testid="count">{count}</span>
      <button onClick={() => setCount(c => c + 1)}>+</button>
      <button onClick={() => setCount(c => c - 1)}>-</button>
    </div>
  )
}
```

```tsx
// __tests__/components/Counter.test.tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { Counter } from '@/components/Counter'

describe('Counter', () => {
  it('starts with initial count', () => {
    render(<Counter initialCount={5} />)

    expect(screen.getByTestId('count')).toHaveTextContent('5')
  })

  it('increments when + is clicked', async () => {
    render(<Counter />)

    await userEvent.click(screen.getByText('+'))

    expect(screen.getByTestId('count')).toHaveTextContent('1')
  })

  it('decrements when - is clicked', async () => {
    render(<Counter initialCount={5} />)

    await userEvent.click(screen.getByText('-'))

    expect(screen.getByTestId('count')).toHaveTextContent('4')
  })
})
```

### Formularios

```tsx
// __tests__/components/LoginForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { LoginForm } from '@/components/LoginForm'

describe('LoginForm', () => {
  it('submits form with email and password', async () => {
    const handleSubmit = jest.fn()
    render(<LoginForm onSubmit={handleSubmit} />)

    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com')
    await userEvent.type(screen.getByLabelText(/password/i), 'password123')
    await userEvent.click(screen.getByRole('button', { name: /submit/i }))

    await waitFor(() => {
      expect(handleSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      })
    })
  })

  it('shows error for invalid email', async () => {
    render(<LoginForm onSubmit={jest.fn()} />)

    await userEvent.type(screen.getByLabelText(/email/i), 'invalid-email')
    await userEvent.click(screen.getByRole('button', { name: /submit/i }))

    expect(await screen.findByText(/email inválido/i)).toBeInTheDocument()
  })
})
```

## Mocking

### Mock de funciones

```tsx
const mockFn = jest.fn()

// Retornar valor específico
mockFn.mockReturnValue('hello')
mockFn.mockReturnValueOnce('first').mockReturnValue('default')

// Retornar promesa
mockFn.mockResolvedValue({ data: 'result' })
mockFn.mockRejectedValue(new Error('fail'))

// Verificar llamadas
expect(mockFn).toHaveBeenCalled()
expect(mockFn).toHaveBeenCalledTimes(2)
expect(mockFn).toHaveBeenCalledWith('arg1', 'arg2')
```

### Mock de módulos

```tsx
// Mock de API
jest.mock('@/lib/api', () => ({
  fetchUser: jest.fn(),
}))

import { fetchUser } from '@/lib/api'

test('loads user data', async () => {
  (fetchUser as jest.Mock).mockResolvedValue({
    id: '1',
    name: 'John',
  })

  render(<UserProfile userId="1" />)

  expect(await screen.findByText('John')).toBeInTheDocument()
})
```

### Mock de hooks

```tsx
// Mock de useRouter
import { useRouter } from 'next/navigation'

jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
}))

test('navigates on click', async () => {
  const push = jest.fn()
  (useRouter as jest.Mock).mockReturnValue({ push })

  render(<NavigateButton />)

  await userEvent.click(screen.getByRole('button'))

  expect(push).toHaveBeenCalledWith('/dashboard')
})
```

## Testing async

```tsx
// Usando findBy (espera automáticamente)
const element = await screen.findByText('Loaded')

// Usando waitFor
await waitFor(() => {
  expect(screen.getByText('Loaded')).toBeInTheDocument()
})

// Con timeout personalizado
await waitFor(
  () => {
    expect(screen.getByText('Loaded')).toBeInTheDocument()
  },
  { timeout: 5000 }
)
```

## Snapshot testing

```tsx
import { render } from '@testing-library/react'
import { Card } from '@/components/Card'

test('Card matches snapshot', () => {
  const { container } = render(
    <Card title="Test" description="Description" />
  )

  expect(container).toMatchSnapshot()
})
```

## Buenas prácticas

1. **Test behavior, no implementation**: Qué hace, no cómo
2. **Use getByRole primero**: Más accesible y robusto
3. **Avoid getByTestId**: Solo como último recurso
4. **Test user interactions**: userEvent > fireEvent
5. **Keep tests simple**: Un concepto por test
6. **Use describe blocks**: Organiza tests relacionados
7. **Mock at boundaries**: APIs, navegación, no lógica interna

## Estructura recomendada

```
__tests__/
├── components/
│   ├── Button.test.tsx
│   └── Card.test.tsx
├── hooks/
│   └── useAuth.test.tsx
└── utils/
    └── format.test.ts
```
