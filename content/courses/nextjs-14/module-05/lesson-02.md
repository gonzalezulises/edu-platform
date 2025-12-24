# Implementando Auth.js (NextAuth v5)

## Introducción

Auth.js (anteriormente NextAuth.js) es la solución de autenticación más popular para Next.js. La versión 5 trae soporte nativo para App Router y Server Components.

## Instalación

```bash
npm install next-auth@beta
```

## Configuración básica

### 1. Crear archivo de configuración

```tsx
// auth.ts (en la raíz del proyecto)
import NextAuth from 'next-auth'
import Credentials from 'next-auth/providers/credentials'
import Google from 'next-auth/providers/google'
import { z } from 'zod'

export const { handlers, signIn, signOut, auth } = NextAuth({
  providers: [
    Google({
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
    }),
    Credentials({
      credentials: {
        email: { label: 'Email', type: 'email' },
        password: { label: 'Password', type: 'password' },
      },
      async authorize(credentials) {
        const parsedCredentials = z
          .object({
            email: z.string().email(),
            password: z.string().min(6),
          })
          .safeParse(credentials)

        if (!parsedCredentials.success) {
          return null
        }

        const { email, password } = parsedCredentials.data
        const user = await getUserByEmail(email)

        if (!user) return null

        const passwordsMatch = await bcrypt.compare(password, user.password)

        if (passwordsMatch) {
          return user
        }

        return null
      },
    }),
  ],
  pages: {
    signIn: '/login',
    error: '/login',
  },
  callbacks: {
    authorized({ auth, request: { nextUrl } }) {
      const isLoggedIn = !!auth?.user
      const isOnDashboard = nextUrl.pathname.startsWith('/dashboard')

      if (isOnDashboard) {
        if (isLoggedIn) return true
        return false // Redirect to login
      }

      return true
    },
    jwt({ token, user }) {
      if (user) {
        token.id = user.id
        token.role = user.role
      }
      return token
    },
    session({ session, token }) {
      if (token) {
        session.user.id = token.id as string
        session.user.role = token.role as string
      }
      return session
    },
  },
})
```

### 2. Crear el API Route Handler

```tsx
// app/api/auth/[...nextauth]/route.ts
import { handlers } from '@/auth'

export const { GET, POST } = handlers
```

### 3. Configurar Middleware

```tsx
// middleware.ts
import { auth } from '@/auth'

export default auth((req) => {
  const isLoggedIn = !!req.auth
  const isAuthPage = req.nextUrl.pathname.startsWith('/login') ||
                     req.nextUrl.pathname.startsWith('/register')

  // Redirigir usuarios autenticados fuera de páginas de auth
  if (isLoggedIn && isAuthPage) {
    return Response.redirect(new URL('/dashboard', req.nextUrl))
  }

  // Redirigir usuarios no autenticados a login
  if (!isLoggedIn && req.nextUrl.pathname.startsWith('/dashboard')) {
    return Response.redirect(new URL('/login', req.nextUrl))
  }
})

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
```

### 4. Variables de entorno

```bash
# .env.local
NEXTAUTH_SECRET=tu-secret-super-seguro-generado-con-openssl
NEXTAUTH_URL=http://localhost:3000

# Google OAuth
GOOGLE_CLIENT_ID=xxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=xxx

# Base de datos (opcional pero recomendado)
DATABASE_URL=postgresql://...
```

Genera el secret:

```bash
openssl rand -base64 32
```

## Usando la sesión

### En Server Components

```tsx
// app/dashboard/page.tsx
import { auth } from '@/auth'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const session = await auth()

  if (!session) {
    redirect('/login')
  }

  return (
    <div>
      <h1>Dashboard</h1>
      <p>Bienvenido, {session.user?.name}</p>
      <p>Email: {session.user?.email}</p>
      <img src={session.user?.image} alt="Avatar" />
    </div>
  )
}
```

### En Client Components

```tsx
'use client'

import { useSession } from 'next-auth/react'

export function UserMenu() {
  const { data: session, status } = useSession()

  if (status === 'loading') {
    return <div>Cargando...</div>
  }

  if (!session) {
    return <a href="/login">Iniciar sesión</a>
  }

  return (
    <div>
      <span>{session.user?.name}</span>
      <img src={session.user?.image} alt="Avatar" />
    </div>
  )
}
```

### Provider para Client Components

```tsx
// app/providers.tsx
'use client'

import { SessionProvider } from 'next-auth/react'

export function Providers({ children }: { children: React.ReactNode }) {
  return <SessionProvider>{children}</SessionProvider>
}
```

```tsx
// app/layout.tsx
import { Providers } from './providers'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

## Formularios de autenticación

### Página de Login

```tsx
// app/login/page.tsx
import { LoginForm } from '@/components/auth/LoginForm'
import { auth } from '@/auth'
import { redirect } from 'next/navigation'

export default async function LoginPage() {
  const session = await auth()

  if (session) {
    redirect('/dashboard')
  }

  return (
    <div className="min-h-screen flex items-center justify-center">
      <div className="max-w-md w-full space-y-8">
        <h1 className="text-2xl font-bold text-center">Iniciar Sesión</h1>
        <LoginForm />
      </div>
    </div>
  )
}
```

### Componente de Login

```tsx
// components/auth/LoginForm.tsx
'use client'

import { useActionState } from 'react'
import { authenticate } from '@/actions/auth'

export function LoginForm() {
  const [state, action, pending] = useActionState(authenticate, undefined)

  return (
    <form action={action} className="space-y-4">
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          required
          className="w-full border rounded px-3 py-2"
        />
      </div>

      <div>
        <label htmlFor="password">Contraseña</label>
        <input
          id="password"
          name="password"
          type="password"
          required
          className="w-full border rounded px-3 py-2"
        />
      </div>

      {state?.error && (
        <p className="text-red-500 text-sm">{state.error}</p>
      )}

      <button
        type="submit"
        disabled={pending}
        className="w-full bg-blue-600 text-white py-2 rounded"
      >
        {pending ? 'Iniciando...' : 'Iniciar Sesión'}
      </button>

      <div className="relative my-4">
        <div className="absolute inset-0 flex items-center">
          <div className="w-full border-t" />
        </div>
        <div className="relative flex justify-center text-sm">
          <span className="bg-white px-2 text-gray-500">o continúa con</span>
        </div>
      </div>

      <GoogleSignInButton />
    </form>
  )
}
```

### Server Action de autenticación

```tsx
// actions/auth.ts
'use server'

import { signIn, signOut } from '@/auth'
import { AuthError } from 'next-auth'

export async function authenticate(
  prevState: { error?: string } | undefined,
  formData: FormData
) {
  try {
    await signIn('credentials', {
      email: formData.get('email'),
      password: formData.get('password'),
      redirectTo: '/dashboard',
    })
  } catch (error) {
    if (error instanceof AuthError) {
      switch (error.type) {
        case 'CredentialsSignin':
          return { error: 'Email o contraseña incorrectos' }
        default:
          return { error: 'Algo salió mal' }
      }
    }
    throw error
  }
}

export async function googleSignIn() {
  await signIn('google', { redirectTo: '/dashboard' })
}

export async function logout() {
  await signOut({ redirectTo: '/' })
}
```

### Botón de Google

```tsx
// components/auth/GoogleSignInButton.tsx
import { googleSignIn } from '@/actions/auth'

export function GoogleSignInButton() {
  return (
    <form action={googleSignIn}>
      <button
        type="submit"
        className="w-full flex items-center justify-center gap-2 border rounded py-2 hover:bg-gray-50"
      >
        <GoogleIcon />
        Continuar con Google
      </button>
    </form>
  )
}
```

### Botón de Logout

```tsx
// components/auth/LogoutButton.tsx
import { logout } from '@/actions/auth'

export function LogoutButton() {
  return (
    <form action={logout}>
      <button type="submit" className="text-red-600 hover:underline">
        Cerrar Sesión
      </button>
    </form>
  )
}
```

## Tipos de TypeScript

### Extender tipos de sesión

```tsx
// types/next-auth.d.ts
import NextAuth, { DefaultSession } from 'next-auth'

declare module 'next-auth' {
  interface Session {
    user: {
      id: string
      role: string
    } & DefaultSession['user']
  }

  interface User {
    role: string
  }
}

declare module 'next-auth/jwt' {
  interface JWT {
    id: string
    role: string
  }
}
```

## Resumen

1. **Instalar**: `npm install next-auth@beta`
2. **Configurar**: `auth.ts` con providers y callbacks
3. **API Route**: `app/api/auth/[...nextauth]/route.ts`
4. **Middleware**: Proteger rutas automáticamente
5. **Server Components**: `await auth()`
6. **Client Components**: `useSession()` con `SessionProvider`
7. **Actions**: `signIn()`, `signOut()` para formularios
