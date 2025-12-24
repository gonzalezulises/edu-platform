# Testing E2E con Playwright

## Introducción

Playwright permite testing end-to-end de tu aplicación Next.js en navegadores reales. Simula usuarios reales interactuando con la aplicación completa.

## Instalación

```bash
npm init playwright@latest
```

Esto crea:
- `playwright.config.ts` - Configuración
- `tests/` - Directorio para tests
- `tests-examples/` - Ejemplos

## Configuración para Next.js

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },
    // Mobile
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
})
```

## Primer test E2E

```ts
// e2e/home.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Home Page', () => {
  test('has title', async ({ page }) => {
    await page.goto('/')

    await expect(page).toHaveTitle(/Next.js/)
  })

  test('has navigation links', async ({ page }) => {
    await page.goto('/')

    await expect(page.getByRole('link', { name: /courses/i })).toBeVisible()
    await expect(page.getByRole('link', { name: /about/i })).toBeVisible()
  })

  test('can navigate to courses', async ({ page }) => {
    await page.goto('/')

    await page.getByRole('link', { name: /courses/i }).click()

    await expect(page).toHaveURL('/courses')
    await expect(page.getByRole('heading', { name: /courses/i })).toBeVisible()
  })
})
```

## Locators y selectors

```ts
// Por rol (preferido - accesible)
page.getByRole('button', { name: /submit/i })
page.getByRole('textbox', { name: /email/i })
page.getByRole('link', { name: /home/i })
page.getByRole('heading', { level: 1 })

// Por texto
page.getByText('Welcome')
page.getByText(/welcome/i) // Case insensitive

// Por label
page.getByLabel('Email')

// Por placeholder
page.getByPlaceholder('Enter email')

// Por test ID
page.getByTestId('submit-button')

// Por CSS selector (evitar si es posible)
page.locator('.my-class')
page.locator('#my-id')
```

## Testing de formularios

```ts
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test'

test.describe('Authentication', () => {
  test('can login with valid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('password123')
    await page.getByRole('button', { name: /sign in/i }).click()

    await expect(page).toHaveURL('/dashboard')
    await expect(page.getByText('Welcome back')).toBeVisible()
  })

  test('shows error for invalid credentials', async ({ page }) => {
    await page.goto('/login')

    await page.getByLabel('Email').fill('wrong@example.com')
    await page.getByLabel('Password').fill('wrongpass')
    await page.getByRole('button', { name: /sign in/i }).click()

    await expect(page.getByText(/invalid credentials/i)).toBeVisible()
    await expect(page).toHaveURL('/login')
  })

  test('validates required fields', async ({ page }) => {
    await page.goto('/login')

    await page.getByRole('button', { name: /sign in/i }).click()

    await expect(page.getByText(/email is required/i)).toBeVisible()
  })
})
```

## Testing con autenticación

### Fixture de autenticación

```ts
// e2e/fixtures/auth.ts
import { test as base, expect } from '@playwright/test'

type AuthFixture = {
  authenticatedPage: Page
}

export const test = base.extend<AuthFixture>({
  authenticatedPage: async ({ page }, use) => {
    // Login
    await page.goto('/login')
    await page.getByLabel('Email').fill('test@example.com')
    await page.getByLabel('Password').fill('password123')
    await page.getByRole('button', { name: /sign in/i }).click()
    await expect(page).toHaveURL('/dashboard')

    await use(page)
  },
})

export { expect }
```

```ts
// e2e/dashboard.spec.ts
import { test, expect } from './fixtures/auth'

test.describe('Dashboard', () => {
  test('shows user courses', async ({ authenticatedPage }) => {
    await authenticatedPage.goto('/dashboard')

    await expect(authenticatedPage.getByText('My Courses')).toBeVisible()
  })
})
```

### Guardar estado de autenticación

```ts
// e2e/global-setup.ts
import { chromium, FullConfig } from '@playwright/test'

async function globalSetup(config: FullConfig) {
  const browser = await chromium.launch()
  const page = await browser.newPage()

  await page.goto('http://localhost:3000/login')
  await page.getByLabel('Email').fill('test@example.com')
  await page.getByLabel('Password').fill('password123')
  await page.getByRole('button', { name: /sign in/i }).click()

  // Guardar estado (cookies, storage)
  await page.context().storageState({ path: './e2e/.auth/user.json' })

  await browser.close()
}

export default globalSetup
```

```ts
// playwright.config.ts
export default defineConfig({
  globalSetup: require.resolve('./e2e/global-setup'),
  projects: [
    {
      name: 'authenticated',
      use: {
        storageState: './e2e/.auth/user.json',
      },
    },
  ],
})
```

## Testing de flujos completos

```ts
// e2e/course-enrollment.spec.ts
import { test, expect } from './fixtures/auth'

test.describe('Course Enrollment', () => {
  test('can enroll in a course', async ({ authenticatedPage: page }) => {
    // 1. Ir a catálogo
    await page.goto('/courses')

    // 2. Seleccionar curso
    await page.getByRole('link', { name: /next.js basics/i }).click()
    await expect(page).toHaveURL(/\/courses\//)

    // 3. Verificar detalles
    await expect(page.getByRole('heading', { name: /next.js basics/i })).toBeVisible()
    await expect(page.getByText(/\$49/)).toBeVisible()

    // 4. Inscribirse
    await page.getByRole('button', { name: /enroll/i }).click()

    // 5. Verificar confirmación
    await expect(page.getByText(/successfully enrolled/i)).toBeVisible()
    await expect(page.getByRole('button', { name: /start learning/i })).toBeVisible()

    // 6. Verificar en dashboard
    await page.goto('/dashboard')
    await expect(page.getByText(/next.js basics/i)).toBeVisible()
  })

  test('can complete a lesson', async ({ authenticatedPage: page }) => {
    await page.goto('/courses/nextjs-basics/lessons/1')

    // Esperar video
    await expect(page.locator('video, iframe')).toBeVisible()

    // Marcar como completado
    await page.getByRole('button', { name: /mark complete/i }).click()

    // Verificar progreso
    await expect(page.getByText(/completed/i)).toBeVisible()

    // Siguiente lección
    await page.getByRole('button', { name: /next lesson/i }).click()
    await expect(page).toHaveURL(/lessons\/2/)
  })
})
```

## Visual testing

```ts
// e2e/visual.spec.ts
import { test, expect } from '@playwright/test'

test('home page looks correct', async ({ page }) => {
  await page.goto('/')

  await expect(page).toHaveScreenshot('home.png')
})

test('course card looks correct', async ({ page }) => {
  await page.goto('/courses')

  const card = page.getByTestId('course-card').first()
  await expect(card).toHaveScreenshot('course-card.png')
})
```

Para actualizar screenshots:

```bash
npx playwright test --update-snapshots
```

## API testing

```ts
// e2e/api.spec.ts
import { test, expect } from '@playwright/test'

test.describe('API', () => {
  test('GET /api/courses returns courses', async ({ request }) => {
    const response = await request.get('/api/courses')

    expect(response.ok()).toBeTruthy()

    const data = await response.json()
    expect(data).toHaveProperty('courses')
    expect(Array.isArray(data.courses)).toBe(true)
  })

  test('POST /api/courses requires auth', async ({ request }) => {
    const response = await request.post('/api/courses', {
      data: { title: 'New Course' },
    })

    expect(response.status()).toBe(401)
  })
})
```

## Debugging

```ts
// Pausar ejecución
await page.pause()

// Logs
console.log(await page.content())
console.log(await page.locator('.my-class').textContent())

// Screenshot en falla
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== testInfo.expectedStatus) {
    await page.screenshot({ path: `./screenshots/${testInfo.title}.png` })
  }
})
```

Comandos:

```bash
# Ejecutar con UI
npx playwright test --ui

# Ejecutar con headed
npx playwright test --headed

# Debug mode
npx playwright test --debug

# Ver reporte
npx playwright show-report
```

## Scripts en package.json

```json
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:headed": "playwright test --headed"
  }
}
```

## Resumen

| Tipo de test | Cuándo usar |
|--------------|-------------|
| Unit (Jest) | Funciones, hooks, utils |
| Component (RTL) | UI components aislados |
| E2E (Playwright) | Flujos de usuario completos |

## Buenas prácticas

1. **Tests independientes**: No depender de orden
2. **Locators accesibles**: getByRole > CSS
3. **Fixtures para auth**: Reutilizar login
4. **Parallel cuando sea posible**: Más rápido
5. **Visual testing con cuidado**: Puede ser frágil
6. **CI/CD**: Correr en cada PR
