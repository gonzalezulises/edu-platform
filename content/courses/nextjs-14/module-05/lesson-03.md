# Protección de Rutas con Middleware

## Introducción

El Middleware de Next.js permite interceptar requests antes de que lleguen a tus páginas. Es la forma más eficiente de proteger rutas, ya que se ejecuta en el Edge antes del rendering.

## Middleware básico

```tsx
// middleware.ts (en la raíz del proyecto)
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Verificar si hay token de sesión
  const token = request.cookies.get('session-token')

  // Rutas que requieren autenticación
  const protectedPaths = ['/dashboard', '/profile', '/settings']
  const isProtectedPath = protectedPaths.some((path) =>
    request.nextUrl.pathname.startsWith(path)
  )

  if (isProtectedPath && !token) {
    // Redirigir a login con callback URL
    const loginUrl = new URL('/login', request.url)
    loginUrl.searchParams.set('callbackUrl', request.nextUrl.pathname)
    return NextResponse.redirect(loginUrl)
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    // Excluir archivos estáticos y API routes públicos
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
```

## Middleware con Auth.js

Auth.js proporciona un wrapper que simplifica la autenticación:

```tsx
// middleware.ts
import { auth } from '@/auth'

export default auth((req) => {
  const isLoggedIn = !!req.auth
  const { pathname } = req.nextUrl

  // Definir rutas públicas
  const publicPaths = ['/', '/login', '/register', '/about']
  const isPublicPath = publicPaths.includes(pathname)

  // Rutas de autenticación
  const isAuthPath = pathname.startsWith('/login') ||
                     pathname.startsWith('/register')

  // Si está logueado y va a login/register, redirigir a dashboard
  if (isLoggedIn && isAuthPath) {
    return Response.redirect(new URL('/dashboard', req.nextUrl))
  }

  // Si no está logueado y va a ruta protegida
  if (!isLoggedIn && !isPublicPath) {
    const loginUrl = new URL('/login', req.nextUrl)
    loginUrl.searchParams.set('callbackUrl', pathname)
    return Response.redirect(loginUrl)
  }

  // Permitir la request
  return
})

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
}
```

## Protección basada en roles

```tsx
// middleware.ts
import { auth } from '@/auth'

const roleRoutes = {
  admin: ['/admin', '/admin/users', '/admin/settings'],
  instructor: ['/instructor', '/courses/create', '/courses/edit'],
  student: ['/dashboard', '/courses', '/profile'],
}

export default auth((req) => {
  const session = req.auth
  const { pathname } = req.nextUrl

  // Si no hay sesión, redirigir a login
  if (!session) {
    if (!pathname.startsWith('/login')) {
      return Response.redirect(new URL('/login', req.nextUrl))
    }
    return
  }

  const userRole = session.user?.role || 'student'

  // Verificar acceso a rutas de admin
  if (pathname.startsWith('/admin') && userRole !== 'admin') {
    return Response.redirect(new URL('/unauthorized', req.nextUrl))
  }

  // Verificar acceso a rutas de instructor
  if (pathname.startsWith('/instructor') &&
      !['admin', 'instructor'].includes(userRole)) {
    return Response.redirect(new URL('/unauthorized', req.nextUrl))
  }

  return
})
```

## Patrones avanzados

### Múltiples condiciones

```tsx
// middleware.ts
import { auth } from '@/auth'
import { NextResponse } from 'next/server'

export default auth((req) => {
  const session = req.auth
  const { pathname, searchParams } = req.nextUrl

  // 1. Mantenimiento global
  if (process.env.MAINTENANCE_MODE === 'true') {
    if (!pathname.startsWith('/maintenance')) {
      return Response.redirect(new URL('/maintenance', req.nextUrl))
    }
    return
  }

  // 2. Geo-blocking (ejemplo)
  const country = req.geo?.country
  if (country === 'XX' && !pathname.startsWith('/blocked')) {
    return Response.redirect(new URL('/blocked', req.nextUrl))
  }

  // 3. Autenticación
  if (!session && pathname.startsWith('/dashboard')) {
    return Response.redirect(new URL('/login', req.nextUrl))
  }

  // 4. Verificación de email
  if (session && !session.user?.emailVerified) {
    if (!pathname.startsWith('/verify-email') &&
        pathname.startsWith('/dashboard')) {
      return Response.redirect(new URL('/verify-email', req.nextUrl))
    }
  }

  // 5. Onboarding incompleto
  if (session && !session.user?.onboardingComplete) {
    if (!pathname.startsWith('/onboarding') &&
        pathname.startsWith('/dashboard')) {
      return Response.redirect(new URL('/onboarding', req.nextUrl))
    }
  }

  return NextResponse.next()
})
```

### Headers de seguridad

```tsx
// middleware.ts
import { NextResponse } from 'next/server'

export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Agregar headers de seguridad
  response.headers.set('X-Frame-Options', 'DENY')
  response.headers.set('X-Content-Type-Options', 'nosniff')
  response.headers.set('Referrer-Policy', 'strict-origin-when-cross-origin')
  response.headers.set(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline';"
  )

  return response
}
```

### Rate limiting básico

```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_URL!,
  token: process.env.UPSTASH_REDIS_TOKEN!,
})

const ratelimit = new Ratelimit({
  redis,
  limiter: Ratelimit.slidingWindow(10, '10 s'), // 10 requests por 10 segundos
})

export async function middleware(request: NextRequest) {
  // Solo aplicar a API routes
  if (request.nextUrl.pathname.startsWith('/api')) {
    const ip = request.ip ?? '127.0.0.1'
    const { success, limit, reset, remaining } = await ratelimit.limit(ip)

    if (!success) {
      return NextResponse.json(
        { error: 'Too many requests' },
        {
          status: 429,
          headers: {
            'X-RateLimit-Limit': limit.toString(),
            'X-RateLimit-Remaining': remaining.toString(),
            'X-RateLimit-Reset': reset.toString(),
          },
        }
      )
    }
  }

  return NextResponse.next()
}
```

## Matcher configuration

El `matcher` define qué rutas procesan el middleware:

```tsx
export const config = {
  matcher: [
    // Todas las rutas excepto API, static, etc.
    '/((?!api|_next/static|_next/image|favicon.ico).*)',

    // Solo rutas específicas
    '/dashboard/:path*',
    '/admin/:path*',

    // Rutas con parámetros
    '/users/:id/settings',

    // Negación con regex
    '/((?!public|health).*)',
  ],
}
```

### Patrones comunes de matcher

```tsx
// Solo rutas de dashboard
matcher: ['/dashboard/:path*']

// Múltiples rutas protegidas
matcher: ['/dashboard/:path*', '/settings/:path*', '/admin/:path*']

// Todo excepto archivos estáticos
matcher: ['/((?!_next/static|_next/image|favicon.ico).*)']

// Solo API routes
matcher: ['/api/:path*']
```

## Protección en componentes

Además del middleware, valida en el servidor:

```tsx
// app/dashboard/page.tsx
import { auth } from '@/auth'
import { redirect } from 'next/navigation'

export default async function DashboardPage() {
  const session = await auth()

  // Doble verificación (el middleware ya debería haber redirigido)
  if (!session) {
    redirect('/login')
  }

  // Verificar rol
  if (session.user.role !== 'admin') {
    redirect('/unauthorized')
  }

  return <div>Dashboard de Admin</div>
}
```

## Debugging

### Logs en desarrollo

```tsx
export function middleware(request: NextRequest) {
  console.log('Middleware executing for:', request.nextUrl.pathname)
  console.log('Cookies:', request.cookies.getAll())
  console.log('Headers:', Object.fromEntries(request.headers))

  // ...
}
```

### Verificar ejecución

```tsx
export function middleware(request: NextRequest) {
  const response = NextResponse.next()

  // Header para verificar que el middleware se ejecutó
  response.headers.set('x-middleware-cache', 'no-cache')

  return response
}
```

## Resumen

| Tarea | Ubicación |
|-------|-----------|
| Autenticación global | Middleware |
| Autorización por roles | Middleware + Server Component |
| Rate limiting | Middleware |
| Headers de seguridad | Middleware |
| Redirecciones | Middleware |
| Validación de datos | Server Actions |

## Buenas prácticas

1. **Middleware es para protección global**: No lógica de negocio compleja
2. **Doble verificación**: Middleware + Server Components
3. **Usa matcher específico**: Evita procesamiento innecesario
4. **No hagas queries pesadas**: Middleware debe ser rápido
5. **Logs en desarrollo**: Facilita debugging
6. **Variables de entorno**: Para feature flags y mantenimiento
