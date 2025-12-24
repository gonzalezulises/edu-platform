# Monitoreo y Logging

## Introducción

Una vez en producción, necesitas visibilidad sobre el comportamiento de tu aplicación. El monitoreo y logging te permiten detectar y diagnosticar problemas rápidamente.

## Vercel Analytics

### Speed Insights

```tsx
// app/layout.tsx
import { SpeedInsights } from '@vercel/speed-insights/next'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <SpeedInsights />
      </body>
    </html>
  )
}
```

Métricas que captura:
- LCP (Largest Contentful Paint)
- FID (First Input Delay)
- CLS (Cumulative Layout Shift)
- TTFB (Time to First Byte)

### Web Analytics

```tsx
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

Datos que captura:
- Page views
- Unique visitors
- Top pages
- Referrers
- Países y dispositivos

## Error Tracking con Sentry

### Instalación

```bash
npx @sentry/wizard@latest -i nextjs
```

### Configuración

```tsx
// sentry.client.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
  integrations: [
    Sentry.replayIntegration(),
  ],
})
```

```tsx
// sentry.server.config.ts
import * as Sentry from '@sentry/nextjs'

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
})
```

### Capturar errores manualmente

```tsx
import * as Sentry from '@sentry/nextjs'

try {
  await riskyOperation()
} catch (error) {
  Sentry.captureException(error)
  throw error
}

// Con contexto adicional
Sentry.captureException(error, {
  tags: { section: 'checkout' },
  extra: { orderId: order.id },
})
```

### Error Boundary global

```tsx
// app/global-error.tsx
'use client'

import * as Sentry from '@sentry/nextjs'
import { useEffect } from 'react'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    Sentry.captureException(error)
  }, [error])

  return (
    <html>
      <body>
        <h2>Algo salió mal</h2>
        <button onClick={() => reset()}>Intentar de nuevo</button>
      </body>
    </html>
  )
}
```

## Logging estructurado

### Pino

```bash
npm install pino pino-pretty
```

```tsx
// lib/logger.ts
import pino from 'pino'

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: process.env.NODE_ENV === 'development'
    ? { target: 'pino-pretty' }
    : undefined,
})

// Crear loggers con contexto
export const createLogger = (context: string) => {
  return logger.child({ context })
}
```

```tsx
// Uso
import { createLogger } from '@/lib/logger'

const log = createLogger('checkout')

log.info({ orderId: order.id }, 'Order created')
log.error({ error, userId }, 'Payment failed')
log.debug({ items }, 'Cart contents')
```

### Logging en Server Actions

```tsx
'use server'

import { createLogger } from '@/lib/logger'

const log = createLogger('actions/checkout')

export async function createOrder(formData: FormData) {
  const startTime = Date.now()

  try {
    log.info('Starting order creation')

    const order = await processOrder(formData)

    log.info(
      { orderId: order.id, duration: Date.now() - startTime },
      'Order created successfully'
    )

    return { success: true, order }
  } catch (error) {
    log.error({ error, duration: Date.now() - startTime }, 'Order creation failed')
    throw error
  }
}
```

## Application Performance Monitoring (APM)

### Sentry Performance

```tsx
import * as Sentry from '@sentry/nextjs'

// Transacción manual
const transaction = Sentry.startTransaction({
  name: 'processPayment',
  op: 'payment',
})

try {
  const span = transaction.startChild({
    op: 'stripe.charge',
    description: 'Create Stripe charge',
  })

  await stripe.charges.create(chargeData)

  span.finish()
} finally {
  transaction.finish()
}
```

### Instrumentación automática

Next.js con Sentry instrumenta automáticamente:
- Server Components
- API Routes
- Server Actions
- Database queries (con integración)

## Alertas

### Vercel Alerts

En Vercel Dashboard:
1. Project Settings → Notifications
2. Configurar alertas para:
   - Deployment failures
   - Domain expiration
   - Usage limits

### Sentry Alerts

```
Project Settings → Alerts → Create Alert Rule

Condiciones:
- Error frequency > 10/hour
- New issue type
- Specific error message
```

## Health Checks

```tsx
// app/api/health/route.ts
import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'

export async function GET() {
  const checks = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    checks: {} as Record<string, boolean>,
  }

  // Check database
  try {
    await prisma.$queryRaw`SELECT 1`
    checks.checks.database = true
  } catch {
    checks.checks.database = false
    checks.status = 'unhealthy'
  }

  // Check external services
  try {
    const res = await fetch('https://api.stripe.com/v1/health')
    checks.checks.stripe = res.ok
  } catch {
    checks.checks.stripe = false
  }

  const statusCode = checks.status === 'healthy' ? 200 : 503

  return NextResponse.json(checks, { status: statusCode })
}
```

## Uptime Monitoring

### Better Uptime / UptimeRobot

Configuración típica:
- URL: https://tudominio.com/api/health
- Intervalo: 5 minutos
- Alertas: Email, Slack, PagerDuty

### Vercel Cron para self-monitoring

```tsx
// app/api/cron/health/route.ts
import { NextResponse } from 'next/server'

export async function GET() {
  const checks = await runHealthChecks()

  if (!checks.healthy) {
    // Notificar (Slack, email, etc.)
    await notifyTeam(checks)
  }

  return NextResponse.json(checks)
}
```

```json
// vercel.json
{
  "crons": [
    {
      "path": "/api/cron/health",
      "schedule": "*/5 * * * *"
    }
  ]
}
```

## Dashboard de métricas

### Custom Web Vitals

```tsx
// app/layout.tsx
'use client'

import { useReportWebVitals } from 'next/web-vitals'

export function WebVitalsReporter() {
  useReportWebVitals((metric) => {
    // Enviar a tu servicio de analytics
    fetch('/api/analytics/vitals', {
      method: 'POST',
      body: JSON.stringify({
        name: metric.name,
        value: metric.value,
        id: metric.id,
        page: window.location.pathname,
      }),
    })
  })

  return null
}
```

## Checklist de producción

### Monitoreo
- [ ] Vercel Analytics activado
- [ ] Sentry configurado
- [ ] Health check endpoint
- [ ] Uptime monitoring externo

### Logging
- [ ] Logger estructurado (Pino)
- [ ] Logs con contexto
- [ ] Log levels apropiados
- [ ] No logging de datos sensibles

### Alertas
- [ ] Error rate alerts
- [ ] Downtime alerts
- [ ] Performance degradation alerts
- [ ] Notificaciones a Slack/email

### Dashboard
- [ ] Core Web Vitals visibles
- [ ] Error trends
- [ ] Request latency
- [ ] Active users

## Resumen

| Herramienta | Propósito |
|-------------|-----------|
| Vercel Analytics | Page views, visitantes |
| Speed Insights | Core Web Vitals |
| Sentry | Errors, performance |
| Pino | Logging estructurado |
| Health checks | Status de servicios |
