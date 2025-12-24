# useFormStatus y useActionState

## Introducción

React 19 introduce hooks especializados para manejar estados de formularios con Server Actions. Estos hooks proporcionan feedback instantáneo al usuario durante operaciones asíncronas.

## useFormStatus

El hook `useFormStatus` proporciona información sobre el estado del formulario padre.

```tsx
'use client'

import { useFormStatus } from 'react-dom'

function SubmitButton() {
  const { pending, data, method, action } = useFormStatus()

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Enviando...' : 'Enviar'}
    </button>
  )
}
```

### Propiedades disponibles

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `pending` | boolean | `true` mientras el formulario se está enviando |
| `data` | FormData \| null | Los datos del formulario siendo enviados |
| `method` | string | El método HTTP (GET o POST) |
| `action` | function | Referencia a la action del formulario |

### Regla importante

El componente que usa `useFormStatus` **debe estar dentro del formulario**:

```tsx
// ❌ No funciona - SubmitButton está fuera
function Page() {
  const status = useFormStatus() // ¡No tiene contexto de formulario!

  return (
    <form action={action}>
      <input name="email" />
      <button>Submit</button>
    </form>
  )
}

// ✅ Funciona - SubmitButton está dentro del form
function Page() {
  return (
    <form action={action}>
      <input name="email" />
      <SubmitButton /> {/* useFormStatus aquí funciona */}
    </form>
  )
}
```

## useActionState

`useActionState` permite manejar el estado de una Server Action con feedback.

```tsx
'use client'

import { useActionState } from 'react'
import { createUser } from './actions'

const initialState = {
  message: '',
  errors: {},
}

export function SignupForm() {
  const [state, formAction, isPending] = useActionState(
    createUser,
    initialState
  )

  return (
    <form action={formAction}>
      <input name="email" type="email" />
      {state.errors?.email && (
        <p className="text-red-500">{state.errors.email}</p>
      )}

      <input name="password" type="password" />
      {state.errors?.password && (
        <p className="text-red-500">{state.errors.password}</p>
      )}

      <button disabled={isPending}>
        {isPending ? 'Creando...' : 'Crear cuenta'}
      </button>

      {state.message && (
        <p className="text-green-500">{state.message}</p>
      )}
    </form>
  )
}
```

### La Server Action con retorno

```tsx
// actions.ts
'use server'

import { z } from 'zod'

const SignupSchema = z.object({
  email: z.string().email('Email inválido'),
  password: z.string().min(8, 'Mínimo 8 caracteres'),
})

export async function createUser(prevState: any, formData: FormData) {
  const rawData = {
    email: formData.get('email'),
    password: formData.get('password'),
  }

  const validatedFields = SignupSchema.safeParse(rawData)

  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: '',
    }
  }

  try {
    await db.user.create({
      data: validatedFields.data,
    })

    return {
      errors: {},
      message: 'Usuario creado exitosamente',
    }
  } catch (error) {
    return {
      errors: {},
      message: 'Error al crear usuario',
    }
  }
}
```

## Comparación de patrones

### Patrón 1: Solo useFormStatus

Para formularios simples sin necesidad de mostrar errores del servidor:

```tsx
'use client'

import { useFormStatus } from 'react-dom'
import { subscribe } from './actions'

function SubmitBtn() {
  const { pending } = useFormStatus()
  return (
    <button disabled={pending}>
      {pending ? 'Suscribiendo...' : 'Suscribirse'}
    </button>
  )
}

export function NewsletterForm() {
  return (
    <form action={subscribe}>
      <input name="email" type="email" required />
      <SubmitBtn />
    </form>
  )
}
```

### Patrón 2: useActionState para validación

Para formularios con validación y feedback del servidor:

```tsx
'use client'

import { useActionState } from 'react'

export function ContactForm() {
  const [state, action, pending] = useActionState(sendMessage, {
    success: false,
    error: null,
  })

  if (state.success) {
    return <p>¡Mensaje enviado!</p>
  }

  return (
    <form action={action}>
      <textarea name="message" required />
      {state.error && <p className="error">{state.error}</p>}
      <button disabled={pending}>
        {pending ? 'Enviando...' : 'Enviar'}
      </button>
    </form>
  )
}
```

### Patrón 3: Combinar ambos hooks

Para la mejor experiencia de usuario:

```tsx
'use client'

import { useFormStatus } from 'react-dom'
import { useActionState } from 'react'
import { createPost } from './actions'

function SubmitButton() {
  const { pending } = useFormStatus()

  return (
    <button
      type="submit"
      disabled={pending}
      className={pending ? 'opacity-50' : ''}
    >
      {pending ? (
        <span className="flex items-center gap-2">
          <Spinner /> Publicando...
        </span>
      ) : (
        'Publicar'
      )}
    </button>
  )
}

export function PostForm() {
  const [state, action] = useActionState(createPost, { errors: {} })

  return (
    <form action={action} className="space-y-4">
      <div>
        <label htmlFor="title">Título</label>
        <input
          id="title"
          name="title"
          className={state.errors.title ? 'border-red-500' : ''}
        />
        {state.errors.title && (
          <p className="text-red-500 text-sm">{state.errors.title}</p>
        )}
      </div>

      <div>
        <label htmlFor="content">Contenido</label>
        <textarea
          id="content"
          name="content"
          rows={5}
          className={state.errors.content ? 'border-red-500' : ''}
        />
        {state.errors.content && (
          <p className="text-red-500 text-sm">{state.errors.content}</p>
        )}
      </div>

      <SubmitButton />
    </form>
  )
}
```

## Optimistic Updates con useOptimistic

Para feedback instantáneo antes de confirmar con el servidor:

```tsx
'use client'

import { useOptimistic } from 'react'
import { likePost } from './actions'

export function LikeButton({ postId, initialLikes }) {
  const [optimisticLikes, addOptimisticLike] = useOptimistic(
    initialLikes,
    (state, _) => state + 1
  )

  async function handleLike() {
    addOptimisticLike(null) // Incrementa inmediatamente
    await likePost(postId)  // Confirma con servidor
  }

  return (
    <form action={handleLike}>
      <button type="submit">
        ❤️ {optimisticLikes}
      </button>
    </form>
  )
}
```

## Manejo de errores

### Con try-catch en la action

```tsx
'use server'

export async function deleteItem(id: string) {
  try {
    await db.item.delete({ where: { id } })
    revalidatePath('/items')
    return { success: true }
  } catch (error) {
    return { success: false, error: 'No se pudo eliminar' }
  }
}
```

### Mostrando errores en el cliente

```tsx
'use client'

export function DeleteButton({ id }) {
  const [state, action, pending] = useActionState(
    deleteItem.bind(null, id),
    null
  )

  return (
    <>
      <form action={action}>
        <button disabled={pending}>
          {pending ? 'Eliminando...' : 'Eliminar'}
        </button>
      </form>
      {state?.error && (
        <p className="text-red-500">{state.error}</p>
      )}
    </>
  )
}
```

## Resumen

| Hook | Uso | Ubicación |
|------|-----|-----------|
| `useFormStatus` | Estado pending del form | Dentro del `<form>` |
| `useActionState` | Estado + errores de la action | Componente del form |
| `useOptimistic` | UI optimista antes de confirmar | Cualquier lugar |

## Buenas prácticas

1. **Usa `useFormStatus` para UI feedback**: Spinners, disabled states
2. **Usa `useActionState` para errores**: Validación y mensajes del servidor
3. **Combina ambos** para la mejor UX
4. **Valida en servidor siempre**: El cliente puede ser bypasseado
5. **Optimistic updates** para acciones frecuentes (likes, toggles)
