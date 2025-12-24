# Supabase Storage

## Introducción

Supabase Storage proporciona almacenamiento de archivos escalable con políticas de seguridad integradas. Ideal para imágenes, videos, PDFs y cualquier archivo en tu aplicación Next.js.

## Conceptos básicos

- **Bucket**: Contenedor de archivos (como una carpeta raíz)
- **Object**: Archivo individual dentro de un bucket
- **Policy**: Reglas de acceso (RLS para archivos)

## Configuración

### Crear bucket en Supabase Dashboard

1. Ve a Storage en el dashboard
2. Click "New bucket"
3. Configura:
   - Name: `avatars`
   - Public: true/false
   - File size limit: 5MB

### O vía SQL

```sql
-- Crear bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Políticas de acceso
CREATE POLICY "Avatar images are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload their own avatar"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own avatar"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own avatar"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

## Upload en Server Actions

### Componente de formulario

```tsx
// components/AvatarUpload.tsx
'use client'

import { useRef, useState } from 'react'
import { uploadAvatar } from '@/actions/upload'

export function AvatarUpload({ currentAvatar }: { currentAvatar?: string }) {
  const [preview, setPreview] = useState(currentAvatar)
  const [uploading, setUploading] = useState(false)
  const inputRef = useRef<HTMLInputElement>(null)

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (!file) return

    // Preview local
    const reader = new FileReader()
    reader.onload = (e) => setPreview(e.target?.result as string)
    reader.readAsDataURL(file)

    // Upload
    setUploading(true)
    const formData = new FormData()
    formData.append('file', file)

    try {
      const result = await uploadAvatar(formData)
      if (result.error) {
        alert(result.error)
      }
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="flex items-center gap-4">
      <img
        src={preview || '/default-avatar.png'}
        alt="Avatar"
        className="w-20 h-20 rounded-full object-cover"
      />
      <button
        onClick={() => inputRef.current?.click()}
        disabled={uploading}
        className="px-4 py-2 bg-blue-600 text-white rounded"
      >
        {uploading ? 'Subiendo...' : 'Cambiar foto'}
      </button>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        onChange={handleFileChange}
        className="hidden"
      />
    </div>
  )
}
```

### Server Action

```tsx
// actions/upload.ts
'use server'

import { createClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'

export async function uploadAvatar(formData: FormData) {
  const supabase = await createClient()

  // Verificar autenticación
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) {
    return { error: 'No autorizado' }
  }

  const file = formData.get('file') as File
  if (!file) {
    return { error: 'No se proporcionó archivo' }
  }

  // Validar tipo
  const allowedTypes = ['image/jpeg', 'image/png', 'image/webp']
  if (!allowedTypes.includes(file.type)) {
    return { error: 'Tipo de archivo no permitido' }
  }

  // Validar tamaño (5MB)
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    return { error: 'Archivo muy grande (máximo 5MB)' }
  }

  // Generar nombre único
  const ext = file.name.split('.').pop()
  const fileName = `${user.id}/${Date.now()}.${ext}`

  // Subir a Supabase Storage
  const { data, error } = await supabase.storage
    .from('avatars')
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: true,
    })

  if (error) {
    return { error: 'Error al subir archivo' }
  }

  // Obtener URL pública
  const { data: { publicUrl } } = supabase.storage
    .from('avatars')
    .getPublicUrl(data.path)

  // Actualizar perfil del usuario
  await supabase
    .from('profiles')
    .update({ avatar_url: publicUrl })
    .eq('id', user.id)

  revalidatePath('/profile')

  return { success: true, url: publicUrl }
}
```

## Descarga de archivos

### Archivos públicos

```tsx
// Simplemente usar la URL pública
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl('user-id/avatar.jpg')

// En componente
<img src={publicUrl} alt="Avatar" />
```

### Archivos privados

```tsx
// Generar URL firmada (temporal)
const { data, error } = await supabase.storage
  .from('private-documents')
  .createSignedUrl('document.pdf', 3600) // 1 hora

if (data) {
  // data.signedUrl es válida por 1 hora
}
```

### Descarga directa

```tsx
// Server Action para descarga segura
'use server'

export async function downloadFile(path: string) {
  const supabase = await createClient()

  // Verificar permisos
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('No autorizado')

  const { data, error } = await supabase.storage
    .from('documents')
    .download(path)

  if (error) throw new Error('Error al descargar')

  // Retornar como base64 o buffer
  const arrayBuffer = await data.arrayBuffer()
  return Buffer.from(arrayBuffer).toString('base64')
}
```

## Listar archivos

```tsx
// Listar archivos en un folder
const { data, error } = await supabase.storage
  .from('documents')
  .list('user-id/invoices', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'created_at', order: 'desc' },
  })

// data contiene:
// [{ name: 'invoice-001.pdf', id: '...', created_at: '...', ... }]
```

## Eliminar archivos

```tsx
'use server'

export async function deleteFile(path: string) {
  const supabase = await createClient()

  const { error } = await supabase.storage
    .from('documents')
    .remove([path])

  if (error) {
    return { error: 'Error al eliminar' }
  }

  revalidatePath('/documents')
  return { success: true }
}
```

## Transformaciones de imagen

Supabase soporta transformaciones on-the-fly:

```tsx
const { data: { publicUrl } } = supabase.storage
  .from('avatars')
  .getPublicUrl('avatar.jpg', {
    transform: {
      width: 200,
      height: 200,
      resize: 'cover',
      quality: 80,
    },
  })
```

### Opciones de transformación

| Opción | Valores |
|--------|---------|
| `width` | Número en píxeles |
| `height` | Número en píxeles |
| `resize` | `cover`, `contain`, `fill` |
| `quality` | 1-100 |
| `format` | `origin`, `webp` |

## Componente Image optimizado

```tsx
// components/StorageImage.tsx
import Image from 'next/image'
import { createClient } from '@/lib/supabase/server'

interface StorageImageProps {
  bucket: string
  path: string
  alt: string
  width: number
  height: number
  className?: string
}

export async function StorageImage({
  bucket,
  path,
  alt,
  width,
  height,
  className,
}: StorageImageProps) {
  const supabase = await createClient()

  const { data: { publicUrl } } = supabase.storage
    .from(bucket)
    .getPublicUrl(path, {
      transform: { width, height, resize: 'cover' },
    })

  return (
    <Image
      src={publicUrl}
      alt={alt}
      width={width}
      height={height}
      className={className}
    />
  )
}
```

## Manejo de errores comunes

```tsx
export async function uploadFile(formData: FormData) {
  try {
    const { data, error } = await supabase.storage
      .from('files')
      .upload(path, file)

    if (error) {
      // Errores comunes
      if (error.message.includes('Payload too large')) {
        return { error: 'Archivo muy grande' }
      }
      if (error.message.includes('Invalid file type')) {
        return { error: 'Tipo de archivo no permitido' }
      }
      if (error.message.includes('duplicate')) {
        return { error: 'El archivo ya existe' }
      }

      return { error: 'Error al subir archivo' }
    }

    return { success: true, path: data.path }
  } catch (e) {
    return { error: 'Error inesperado' }
  }
}
```

## Resumen

| Operación | Método |
|-----------|--------|
| Upload | `storage.from('bucket').upload(path, file)` |
| Download | `storage.from('bucket').download(path)` |
| URL pública | `storage.from('bucket').getPublicUrl(path)` |
| URL firmada | `storage.from('bucket').createSignedUrl(path, expiry)` |
| Listar | `storage.from('bucket').list(folder)` |
| Eliminar | `storage.from('bucket').remove([paths])` |
| Mover | `storage.from('bucket').move(from, to)` |
| Copiar | `storage.from('bucket').copy(from, to)` |

## Buenas prácticas

1. **Validar en servidor**: Tipo, tamaño, permisos
2. **Nombres únicos**: Usar UUID o timestamp
3. **Estructura de carpetas**: `user-id/tipo/archivo`
4. **RLS para seguridad**: Nunca confiar solo en cliente
5. **Transformaciones**: Usar para optimizar imágenes
6. **Limpiar huérfanos**: Eliminar archivos cuando se elimina el registro
