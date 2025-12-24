# Patrones de Composición

## Introducción

React Server Components introducen nuevos patrones de composición que optimizan tanto la experiencia del desarrollador como el rendimiento de la aplicación.

## Server y Client Components Juntos

### Regla Principal

Los Server Components pueden importar Client Components, pero NO al revés:

```tsx
// ✅ Server Component importando Client Component
// app/page.tsx (Server Component por defecto)
import { InteractiveButton } from './InteractiveButton'

export default function Page() {
  return (
    <div>
      <h1>Título (Server)</h1>
      <InteractiveButton /> {/* Client Component */}
    </div>
  )
}
```

```tsx
// components/InteractiveButton.tsx
'use client'

export function InteractiveButton() {
  return <button onClick={() => alert('click')}>Click me</button>
}
```

### Pasar Server Components como Children

```tsx
// ✅ Patrón correcto: Server Component como children
// app/page.tsx
import { ClientWrapper } from './ClientWrapper'
import { ServerData } from './ServerData'

export default function Page() {
  return (
    <ClientWrapper>
      <ServerData /> {/* Server Component pasado como children */}
    </ClientWrapper>
  )
}
```

```tsx
// ClientWrapper.tsx
'use client'

export function ClientWrapper({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children} {/* Server Component renderizado aquí */}
    </div>
  )
}
```

## Composición de Data Fetching

### Colocación de Datos

Cada componente hace fetch de sus propios datos:

```tsx
// app/dashboard/page.tsx
export default function Dashboard() {
  return (
    <div className="grid grid-cols-3 gap-4">
      <UserCard />      {/* Hace fetch de usuario */}
      <StatsPanel />    {/* Hace fetch de estadísticas */}
      <RecentActivity /> {/* Hace fetch de actividad */}
    </div>
  )
}

// components/UserCard.tsx
async function UserCard() {
  const user = await getUser() // Fetch propio
  return <div>{user.name}</div>
}

// components/StatsPanel.tsx
async function StatsPanel() {
  const stats = await getStats() // Fetch propio
  return <div>{stats.total} usuarios</div>
}
```

### Parallel Data Fetching

```tsx
// Iniciar todos los fetches en paralelo
export default async function Dashboard() {
  // Inicia los fetches pero no await todavía
  const userPromise = getUser()
  const statsPromise = getStats()
  const activityPromise = getRecentActivity()

  return (
    <div>
      <UserCard userPromise={userPromise} />
      <StatsPanel statsPromise={statsPromise} />
      <ActivityFeed activityPromise={activityPromise} />
    </div>
  )
}

// Cada componente await su promesa
async function UserCard({ userPromise }) {
  const user = await userPromise
  return <div>{user.name}</div>
}
```

## Provider Pattern

Providers deben ser Client Components, pero pueden envolver Server Components:

```tsx
// app/providers.tsx
'use client'

import { ThemeProvider } from 'next-themes'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider attribute="class">
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  )
}
```

```tsx
// app/layout.tsx
import { Providers } from './providers'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Providers>
          {children} {/* Server Components aquí */}
        </Providers>
      </body>
    </html>
  )
}
```

## Compound Components

```tsx
// components/Card/index.tsx (Server)
import { CardHeader } from './CardHeader'
import { CardBody } from './CardBody'
import { CardFooter } from './CardFooter'

async function Card({ children }: { children: React.ReactNode }) {
  return <div className="rounded-lg shadow">{children}</div>
}

Card.Header = CardHeader   // Server Component
Card.Body = CardBody       // Server Component
Card.Footer = CardFooter   // Client Component con interacción

export { Card }
```

```tsx
// Uso
import { Card } from '@/components/Card'

export default async function Page() {
  const data = await getData()

  return (
    <Card>
      <Card.Header title={data.title} />
      <Card.Body>{data.content}</Card.Body>
      <Card.Footer onShare={() => {}} /> {/* Client */}
    </Card>
  )
}
```

## Container/Presentational

Separa la lógica de datos de la presentación:

```tsx
// containers/UserListContainer.tsx (Server)
import { UserList } from '@/components/UserList'

export async function UserListContainer() {
  const users = await getUsers()
  return <UserList users={users} />
}
```

```tsx
// components/UserList.tsx (puede ser Server o Client)
interface UserListProps {
  users: User[]
}

export function UserList({ users }: UserListProps) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

## Render Props con Server Components

```tsx
// components/DataFetcher.tsx (Server)
interface DataFetcherProps<T> {
  fetcher: () => Promise<T>
  children: (data: T) => React.ReactNode
}

export async function DataFetcher<T>({
  fetcher,
  children,
}: DataFetcherProps<T>) {
  const data = await fetcher()
  return <>{children(data)}</>
}
```

```tsx
// Uso
import { DataFetcher } from '@/components/DataFetcher'

export default function Page() {
  return (
    <DataFetcher fetcher={getUsers}>
      {(users) => (
        <ul>
          {users.map(u => <li key={u.id}>{u.name}</li>)}
        </ul>
      )}
    </DataFetcher>
  )
}
```

## Cuándo Usar Cada Tipo

| Server Components | Client Components |
|-------------------|-------------------|
| Fetch de datos | useState, useEffect |
| Acceso a backend | Event handlers |
| Tokens/secrets | Browser APIs |
| Dependencias grandes | Interactividad |
| SEO crítico | Animaciones |

## Resumen

1. **Default a Server**: Solo usa 'use client' cuando necesites interactividad
2. **Children pattern**: Para mezclar Server y Client
3. **Providers en Client**: Pero envuelven Server Components
4. **Colocación de datos**: Cada componente hace su fetch
5. **Composición flexible**: Los patrones clásicos siguen funcionando
