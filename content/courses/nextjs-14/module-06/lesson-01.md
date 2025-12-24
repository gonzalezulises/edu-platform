# Supabase como Backend

## Introducción

Supabase es una alternativa open-source a Firebase que proporciona base de datos PostgreSQL, autenticación, storage y funciones en tiempo real. Se integra perfectamente con Next.js 14.

## Instalación y configuración

```bash
npm install @supabase/supabase-js
```

### Variables de entorno

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Cliente para el navegador

```tsx
// lib/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Cliente para el servidor

```tsx
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Ignorar en Server Components (read-only)
          }
        },
      },
    }
  )
}
```

### Cliente con Service Role (solo servidor)

```tsx
// lib/supabase/admin.ts
import { createClient } from '@supabase/supabase-js'

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
)
```

## Queries en Server Components

### Fetch básico

```tsx
// app/posts/page.tsx
import { createClient } from '@/lib/supabase/server'

export default async function PostsPage() {
  const supabase = await createClient()

  const { data: posts, error } = await supabase
    .from('posts')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    throw new Error('Error cargando posts')
  }

  return (
    <ul>
      {posts?.map((post) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### Con relaciones

```tsx
// Fetch posts con autor
const { data: posts } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    content,
    created_at,
    author:profiles(id, name, avatar_url)
  `)
  .order('created_at', { ascending: false })

// Fetch curso con módulos y lecciones
const { data: course } = await supabase
  .from('courses')
  .select(`
    id,
    title,
    description,
    modules(
      id,
      title,
      order_index,
      lessons(
        id,
        title,
        duration,
        order_index
      )
    )
  `)
  .eq('id', courseId)
  .single()
```

### Filtros avanzados

```tsx
// Múltiples condiciones
const { data } = await supabase
  .from('products')
  .select('*')
  .eq('category', 'electronics')
  .gte('price', 100)
  .lte('price', 500)
  .order('price', { ascending: true })
  .limit(10)

// Búsqueda de texto
const { data } = await supabase
  .from('posts')
  .select('*')
  .ilike('title', `%${searchTerm}%`)

// OR conditions
const { data } = await supabase
  .from('products')
  .select('*')
  .or('category.eq.electronics,category.eq.accessories')

// Array contains
const { data } = await supabase
  .from('posts')
  .select('*')
  .contains('tags', ['javascript', 'react'])
```

## Mutaciones con Server Actions

### Create

```tsx
// actions/posts.ts
'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

export async function createPost(formData: FormData) {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('No autorizado')

  const { error } = await supabase.from('posts').insert({
    title: formData.get('title') as string,
    content: formData.get('content') as string,
    author_id: user.id,
  })

  if (error) {
    return { error: error.message }
  }

  revalidatePath('/posts')
  return { success: true }
}
```

### Update

```tsx
'use server'

export async function updatePost(id: string, formData: FormData) {
  const supabase = await createClient()

  const { error } = await supabase
    .from('posts')
    .update({
      title: formData.get('title') as string,
      content: formData.get('content') as string,
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)

  if (error) {
    return { error: error.message }
  }

  revalidatePath('/posts')
  revalidatePath(`/posts/${id}`)
  return { success: true }
}
```

### Delete

```tsx
'use server'

export async function deletePost(id: string) {
  const supabase = await createClient()

  const { error } = await supabase
    .from('posts')
    .delete()
    .eq('id', id)

  if (error) {
    return { error: error.message }
  }

  revalidatePath('/posts')
  return { success: true }
}
```

## Row Level Security (RLS)

Supabase usa RLS para proteger datos a nivel de base de datos:

```sql
-- Habilitar RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Todos pueden leer posts públicos
CREATE POLICY "Posts públicos son visibles para todos"
ON posts FOR SELECT
USING (is_public = true);

-- Policy: Solo el autor puede editar
CREATE POLICY "Usuarios pueden editar sus propios posts"
ON posts FOR UPDATE
USING (auth.uid() = author_id);

-- Policy: Solo el autor puede eliminar
CREATE POLICY "Usuarios pueden eliminar sus propios posts"
ON posts FOR DELETE
USING (auth.uid() = author_id);

-- Policy: Usuarios autenticados pueden crear
CREATE POLICY "Usuarios autenticados pueden crear posts"
ON posts FOR INSERT
WITH CHECK (auth.uid() = author_id);
```

## Tipos TypeScript con Supabase

### Generar tipos

```bash
npx supabase gen types typescript --project-id xxx > types/database.ts
```

### Usar tipos

```tsx
// types/database.ts (generado)
export interface Database {
  public: {
    Tables: {
      posts: {
        Row: {
          id: string
          title: string
          content: string
          author_id: string
          created_at: string
        }
        Insert: {
          id?: string
          title: string
          content: string
          author_id: string
          created_at?: string
        }
        Update: {
          id?: string
          title?: string
          content?: string
          author_id?: string
          created_at?: string
        }
      }
    }
  }
}
```

```tsx
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { Database } from '@/types/database'

export async function createClient() {
  return createServerClient<Database>(
    // ...
  )
}
```

Ahora tienes autocompletado:

```tsx
const { data } = await supabase
  .from('posts')  // Autocompletado de tablas
  .select('title, content')  // Autocompletado de columnas
  .single()

// data está tipado como Post | null
```

## Resumen

| Operación | Método |
|-----------|--------|
| Leer | `supabase.from('table').select()` |
| Crear | `supabase.from('table').insert()` |
| Actualizar | `supabase.from('table').update().eq()` |
| Eliminar | `supabase.from('table').delete().eq()` |
| Filtrar | `.eq()`, `.gte()`, `.ilike()`, etc. |
| Relaciones | `.select('*, related(*)')` |
| Ordenar | `.order('column', { ascending: false })` |
| Limitar | `.limit(10)` |
| Paginación | `.range(0, 9)` |

## Buenas prácticas

1. **Usa RLS**: Protege datos a nivel de BD, no solo en código
2. **Genera tipos**: `supabase gen types` para type safety
3. **Cliente correcto**: Browser para cliente, Server para SSR
4. **Service Role con cuidado**: Solo en servidor, nunca exponer
5. **Revalida después de mutaciones**: `revalidatePath()` o `revalidateTag()`
