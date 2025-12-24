# Revalidación y Redirecciones

## Introducción

Después de una mutación con Server Actions, necesitas actualizar la UI y posiblemente redirigir al usuario. Next.js proporciona funciones específicas para estos casos.

## revalidatePath

Invalida el cache de una ruta específica, forzando un re-fetch de los datos.

```tsx
'use server'

import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  await db.post.create({
    data: { title: formData.get('title') as string },
  })

  // Invalida el cache de /posts
  revalidatePath('/posts')
}
```

### Tipos de revalidación

```tsx
// Revalidar una página específica
revalidatePath('/blog')

// Revalidar con parámetros dinámicos
revalidatePath('/blog/[slug]', 'page')

// Revalidar un layout (y todas sus páginas hijas)
revalidatePath('/dashboard', 'layout')

// Revalidar toda la app
revalidatePath('/', 'layout')
```

### Cuándo usar cada tipo

| Escenario | Función |
|-----------|---------|
| Actualizar una página | `revalidatePath('/page')` |
| Actualizar lista + detalle | `revalidatePath('/items')` + `revalidatePath('/items/[id]')` |
| Cambio en navegación/sidebar | `revalidatePath('/', 'layout')` |

## revalidateTag

Para invalidación más granular, usa tags en los fetches:

```tsx
// Al hacer fetch, asigna tags
async function getPosts() {
  const res = await fetch('https://api.example.com/posts', {
    next: { tags: ['posts'] },
  })
  return res.json()
}

async function getPost(id: string) {
  const res = await fetch(`https://api.example.com/posts/${id}`, {
    next: { tags: ['posts', `post-${id}`] },
  })
  return res.json()
}
```

```tsx
// En la Server Action, invalida por tag
'use server'

import { revalidateTag } from 'next/cache'

export async function updatePost(id: string, formData: FormData) {
  await db.post.update({
    where: { id },
    data: { title: formData.get('title') as string },
  })

  // Invalida solo este post, no toda la lista
  revalidateTag(`post-${id}`)
}

export async function createPost(formData: FormData) {
  await db.post.create({
    data: { title: formData.get('title') as string },
  })

  // Invalida la lista de posts
  revalidateTag('posts')
}
```

### Tags con unstable_cache

Para funciones que no usan fetch:

```tsx
import { unstable_cache } from 'next/cache'

const getCachedUser = unstable_cache(
  async (id: string) => {
    return db.user.findUnique({ where: { id } })
  },
  ['user-cache'],
  {
    tags: ['users', 'user-data'],
    revalidate: 3600,
  }
)

// Invalidar
export async function updateUser(id: string, data: any) {
  await db.user.update({ where: { id }, data })
  revalidateTag('users')
}
```

## redirect

Redirige al usuario a otra página después de una acción.

```tsx
'use server'

import { redirect } from 'next/navigation'

export async function createPost(formData: FormData) {
  const post = await db.post.create({
    data: { title: formData.get('title') as string },
  })

  // Redirige al post recién creado
  redirect(`/posts/${post.id}`)
}
```

### Patrones comunes

```tsx
'use server'

import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'

// Crear y redirigir al nuevo recurso
export async function createItem(formData: FormData) {
  const item = await db.item.create({ data: {...} })
  revalidatePath('/items')
  redirect(`/items/${item.id}`)
}

// Eliminar y redirigir a la lista
export async function deleteItem(id: string) {
  await db.item.delete({ where: { id } })
  revalidatePath('/items')
  redirect('/items')
}

// Login y redirigir al dashboard
export async function login(formData: FormData) {
  const user = await authenticate(formData)

  if (!user) {
    return { error: 'Credenciales inválidas' }
  }

  redirect('/dashboard')
}

// Logout y redirigir al home
export async function logout() {
  await signOut()
  redirect('/')
}
```

### redirect vs return

```tsx
// ❌ No funciona - return después de redirect
export async function action(formData: FormData) {
  const result = await process(formData)
  redirect('/success')
  return result // ¡Nunca se ejecuta!
}

// ✅ Correcto - redirect es terminal
export async function action(formData: FormData) {
  const result = await process(formData)

  if (result.success) {
    redirect('/success')
  }

  return { error: result.error }
}
```

## permanentRedirect

Para redirecciones permanentes (301):

```tsx
import { permanentRedirect } from 'next/navigation'

export async function migrateUser(oldId: string) {
  const user = await db.user.findUnique({ where: { oldId } })

  if (user?.newId) {
    // SEO: indica que la URL cambió permanentemente
    permanentRedirect(`/users/${user.newId}`)
  }
}
```

## Combinando revalidación y redirección

### Flujo típico de CRUD

```tsx
'use server'

import { revalidatePath, revalidateTag } from 'next/cache'
import { redirect } from 'next/navigation'

// CREATE
export async function createProduct(formData: FormData) {
  const product = await db.product.create({
    data: {
      name: formData.get('name') as string,
      price: Number(formData.get('price')),
    },
  })

  revalidateTag('products')
  redirect(`/products/${product.id}`)
}

// UPDATE
export async function updateProduct(id: string, formData: FormData) {
  await db.product.update({
    where: { id },
    data: {
      name: formData.get('name') as string,
      price: Number(formData.get('price')),
    },
  })

  revalidatePath(`/products/${id}`)
  revalidateTag('products') // También actualiza la lista
  redirect(`/products/${id}`)
}

// DELETE
export async function deleteProduct(id: string) {
  await db.product.delete({ where: { id } })

  revalidateTag('products')
  redirect('/products')
}
```

### Con manejo de errores

```tsx
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'

type ActionResult = {
  success: boolean
  error?: string
}

export async function updateProfile(
  formData: FormData
): Promise<ActionResult> {
  try {
    await db.profile.update({
      where: { id: formData.get('id') as string },
      data: {
        name: formData.get('name') as string,
        bio: formData.get('bio') as string,
      },
    })

    revalidatePath('/profile')

    // redirect lanza un error especial que Next.js maneja
    redirect('/profile')
  } catch (error) {
    // Si el error es de redirect, re-lanzarlo
    if (error instanceof Error && error.message === 'NEXT_REDIRECT') {
      throw error
    }

    return {
      success: false,
      error: 'Error al actualizar perfil',
    }
  }
}
```

## Revalidación On-Demand via API

Para webhooks o eventos externos:

```tsx
// app/api/revalidate/route.ts
import { revalidatePath, revalidateTag } from 'next/cache'
import { NextRequest } from 'next/server'

export async function POST(request: NextRequest) {
  const secret = request.headers.get('x-revalidate-secret')

  if (secret !== process.env.REVALIDATE_SECRET) {
    return Response.json({ error: 'Invalid secret' }, { status: 401 })
  }

  const body = await request.json()

  if (body.tag) {
    revalidateTag(body.tag)
  }

  if (body.path) {
    revalidatePath(body.path)
  }

  return Response.json({ revalidated: true, now: Date.now() })
}
```

```bash
# Llamada desde webhook externo
curl -X POST https://mysite.com/api/revalidate \
  -H "Content-Type: application/json" \
  -H "x-revalidate-secret: my-secret" \
  -d '{"tag": "products"}'
```

## Resumen

| Función | Uso | Cuándo usar |
|---------|-----|-------------|
| `revalidatePath` | Invalida cache de ruta | CRUD en páginas específicas |
| `revalidateTag` | Invalida cache por tag | Invalidación granular |
| `redirect` | Navega a otra página | Después de create/delete |
| `permanentRedirect` | Redirect 301 | Cambios de URL permanentes |

## Buenas prácticas

1. **Siempre revalida** después de mutaciones
2. **Usa tags** para invalidación precisa
3. **Redirige después de create/delete** para evitar resubmits
4. **No mezcles redirect con return** - redirect es terminal
5. **Maneja errores** antes de redirect
6. **Protege endpoints de revalidación** con secrets
