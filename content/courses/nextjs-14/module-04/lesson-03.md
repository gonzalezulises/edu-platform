# Validación con Zod

## Introducción

Zod es una biblioteca de validación de esquemas TypeScript-first. Se integra perfectamente con Server Actions para validar datos del formulario antes de procesarlos.

## Instalación

```bash
npm install zod
```

## Esquemas básicos

```tsx
import { z } from 'zod'

// Tipos primitivos
const stringSchema = z.string()
const numberSchema = z.number()
const booleanSchema = z.boolean()
const dateSchema = z.date()

// Validaciones encadenadas
const emailSchema = z.string().email()
const ageSchema = z.number().min(18).max(120)
const nameSchema = z.string().min(2).max(50)
```

## Esquemas de objetos

```tsx
const UserSchema = z.object({
  name: z.string().min(2, 'Nombre muy corto'),
  email: z.string().email('Email inválido'),
  age: z.number().min(18, 'Debes ser mayor de edad'),
  website: z.string().url().optional(),
})

// Inferir el tipo TypeScript
type User = z.infer<typeof UserSchema>
// { name: string; email: string; age: number; website?: string }
```

## Integración con Server Actions

### Patrón básico

```tsx
// schemas/user.ts
import { z } from 'zod'

export const CreateUserSchema = z.object({
  name: z.string().min(2, 'El nombre debe tener al menos 2 caracteres'),
  email: z.string().email('Ingresa un email válido'),
  password: z
    .string()
    .min(8, 'La contraseña debe tener al menos 8 caracteres')
    .regex(/[A-Z]/, 'Debe contener al menos una mayúscula')
    .regex(/[0-9]/, 'Debe contener al menos un número'),
})

export type CreateUserInput = z.infer<typeof CreateUserSchema>
```

```tsx
// actions/user.ts
'use server'

import { CreateUserSchema } from '@/schemas/user'
import { revalidatePath } from 'next/cache'

export async function createUser(prevState: any, formData: FormData) {
  // 1. Extraer datos del formulario
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
    password: formData.get('password'),
  }

  // 2. Validar con Zod
  const validatedFields = CreateUserSchema.safeParse(rawData)

  // 3. Si hay errores, retornarlos
  if (!validatedFields.success) {
    return {
      errors: validatedFields.error.flatten().fieldErrors,
      message: 'Por favor corrige los errores',
    }
  }

  // 4. Procesar datos validados
  const { name, email, password } = validatedFields.data

  try {
    await db.user.create({
      data: { name, email, password: await hash(password) },
    })

    revalidatePath('/users')
    return { errors: {}, message: 'Usuario creado exitosamente' }
  } catch (error) {
    return { errors: {}, message: 'Error al crear usuario' }
  }
}
```

### Formulario con errores

```tsx
'use client'

import { useActionState } from 'react'
import { createUser } from '@/actions/user'

const initialState = {
  errors: {},
  message: '',
}

export function UserForm() {
  const [state, action, pending] = useActionState(createUser, initialState)

  return (
    <form action={action} className="space-y-4">
      <div>
        <label htmlFor="name">Nombre</label>
        <input
          id="name"
          name="name"
          type="text"
          className={state.errors.name ? 'border-red-500' : 'border-gray-300'}
        />
        {state.errors.name?.map((error) => (
          <p key={error} className="text-red-500 text-sm mt-1">
            {error}
          </p>
        ))}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          className={state.errors.email ? 'border-red-500' : 'border-gray-300'}
        />
        {state.errors.email?.map((error) => (
          <p key={error} className="text-red-500 text-sm mt-1">
            {error}
          </p>
        ))}
      </div>

      <div>
        <label htmlFor="password">Contraseña</label>
        <input
          id="password"
          name="password"
          type="password"
          className={state.errors.password ? 'border-red-500' : 'border-gray-300'}
        />
        {state.errors.password?.map((error) => (
          <p key={error} className="text-red-500 text-sm mt-1">
            {error}
          </p>
        ))}
      </div>

      <button
        type="submit"
        disabled={pending}
        className="bg-blue-600 text-white px-4 py-2 rounded"
      >
        {pending ? 'Creando...' : 'Crear usuario'}
      </button>

      {state.message && (
        <p className={state.errors ? 'text-red-500' : 'text-green-500'}>
          {state.message}
        </p>
      )}
    </form>
  )
}
```

## Validaciones avanzadas

### Refinements personalizados

```tsx
const PasswordSchema = z.object({
  password: z.string().min(8),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Las contraseñas no coinciden',
  path: ['confirmPassword'], // Campo donde mostrar el error
})
```

### Transformaciones

```tsx
const FormSchema = z.object({
  // Convertir string a número
  age: z.string().transform((val) => parseInt(val, 10)),

  // Trim y lowercase
  email: z.string().email().transform((val) => val.toLowerCase().trim()),

  // Valor por defecto
  role: z.string().default('user'),
})
```

### Validación condicional

```tsx
const PaymentSchema = z.discriminatedUnion('method', [
  z.object({
    method: z.literal('card'),
    cardNumber: z.string().length(16),
    cvv: z.string().length(3),
  }),
  z.object({
    method: z.literal('paypal'),
    paypalEmail: z.string().email(),
  }),
])
```

### Arrays y nested objects

```tsx
const OrderSchema = z.object({
  customer: z.object({
    name: z.string(),
    email: z.string().email(),
  }),
  items: z.array(
    z.object({
      productId: z.string().uuid(),
      quantity: z.number().min(1).max(10),
    })
  ).min(1, 'Debes agregar al menos un producto'),
  notes: z.string().optional(),
})
```

## Validación de FormData

### Helper para extraer datos

```tsx
function formDataToObject(formData: FormData): Record<string, any> {
  const obj: Record<string, any> = {}

  formData.forEach((value, key) => {
    // Manejar arrays (checkboxes con mismo name)
    if (obj[key]) {
      if (Array.isArray(obj[key])) {
        obj[key].push(value)
      } else {
        obj[key] = [obj[key], value]
      }
    } else {
      obj[key] = value
    }
  })

  return obj
}
```

### Coerción de tipos

FormData siempre retorna strings. Usa `z.coerce` para convertir:

```tsx
const ProductSchema = z.object({
  name: z.string().min(1),
  price: z.coerce.number().positive(), // String → Number
  inStock: z.coerce.boolean(),          // "true" → true
  createdAt: z.coerce.date(),           // String → Date
})

// Uso con FormData
export async function createProduct(formData: FormData) {
  const rawData = {
    name: formData.get('name'),
    price: formData.get('price'),
    inStock: formData.get('inStock') === 'true',
    createdAt: formData.get('createdAt'),
  }

  const result = ProductSchema.safeParse(rawData)
  // ...
}
```

## Mensajes de error personalizados

### Por campo

```tsx
const UserSchema = z.object({
  email: z.string({
    required_error: 'El email es requerido',
    invalid_type_error: 'El email debe ser texto',
  }).email({
    message: 'Formato de email inválido',
  }),

  age: z.number({
    required_error: 'La edad es requerida',
  }).min(18, {
    message: 'Debes tener al menos 18 años',
  }),
})
```

### Internacionalización

```tsx
// lib/zod-i18n.ts
import { z } from 'zod'

const customErrorMap: z.ZodErrorMap = (issue, ctx) => {
  if (issue.code === z.ZodIssueCode.too_small) {
    if (issue.type === 'string') {
      return { message: `Mínimo ${issue.minimum} caracteres` }
    }
  }

  if (issue.code === z.ZodIssueCode.invalid_type) {
    if (issue.expected === 'string') {
      return { message: 'Este campo es requerido' }
    }
  }

  return { message: ctx.defaultError }
}

z.setErrorMap(customErrorMap)
```

## Reutilización de esquemas

### Composición

```tsx
// schemas/base.ts
export const AddressSchema = z.object({
  street: z.string().min(5),
  city: z.string().min(2),
  postalCode: z.string().regex(/^\d{5}$/),
})

// schemas/user.ts
export const UserWithAddressSchema = z.object({
  name: z.string(),
  email: z.string().email(),
  address: AddressSchema,
  billingAddress: AddressSchema.optional(),
})
```

### Extensión y modificación

```tsx
const BaseUserSchema = z.object({
  name: z.string(),
  email: z.string().email(),
})

// Agregar campos
const CreateUserSchema = BaseUserSchema.extend({
  password: z.string().min(8),
})

// Hacer campos opcionales
const UpdateUserSchema = BaseUserSchema.partial()

// Omitir campos
const PublicUserSchema = BaseUserSchema.omit({ email: true })

// Pick específico
const UserCredentialsSchema = CreateUserSchema.pick({
  email: true,
  password: true,
})
```

## Resumen

```tsx
// 1. Definir esquema
const Schema = z.object({
  field: z.string().min(1),
})

// 2. Validar en Server Action
const result = Schema.safeParse(data)

if (!result.success) {
  return { errors: result.error.flatten().fieldErrors }
}

// 3. Usar datos validados (tipados)
const { field } = result.data
```

## Buenas prácticas

1. **Centraliza esquemas** en carpeta `/schemas`
2. **Infiere tipos** con `z.infer<typeof Schema>`
3. **Usa coerción** para FormData: `z.coerce.number()`
4. **Mensajes descriptivos** para mejor UX
5. **Reutiliza esquemas** con `.extend()`, `.pick()`, `.omit()`
6. **Valida siempre en servidor** - nunca confíes en el cliente
