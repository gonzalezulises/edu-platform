# Upload de Archivos con Next.js

## Introducción

Next.js 14 proporciona múltiples formas de manejar uploads. Desde API Routes hasta Server Actions, exploraremos las mejores prácticas para cada caso.

## Server Actions para Upload

### Formulario básico

```tsx
// app/upload/page.tsx
import { UploadForm } from '@/components/UploadForm'

export default function UploadPage() {
  return (
    <div className="max-w-md mx-auto p-6">
      <h1 className="text-2xl font-bold mb-4">Subir archivo</h1>
      <UploadForm />
    </div>
  )
}
```

```tsx
// components/UploadForm.tsx
'use client'

import { useActionState } from 'react'
import { uploadFile } from '@/actions/upload'

export function UploadForm() {
  const [state, action, pending] = useActionState(uploadFile, null)

  return (
    <form action={action} className="space-y-4">
      <div>
        <label className="block text-sm font-medium mb-1">
          Seleccionar archivo
        </label>
        <input
          type="file"
          name="file"
          required
          className="w-full border rounded p-2"
        />
      </div>

      <button
        type="submit"
        disabled={pending}
        className="w-full bg-blue-600 text-white py-2 rounded disabled:opacity-50"
      >
        {pending ? 'Subiendo...' : 'Subir'}
      </button>

      {state?.error && (
        <p className="text-red-500 text-sm">{state.error}</p>
      )}

      {state?.success && (
        <p className="text-green-500 text-sm">
          Archivo subido: {state.fileName}
        </p>
      )}
    </form>
  )
}
```

### Server Action

```tsx
// actions/upload.ts
'use server'

import { writeFile, mkdir } from 'fs/promises'
import path from 'path'
import { revalidatePath } from 'next/cache'

type UploadState = {
  error?: string
  success?: boolean
  fileName?: string
} | null

export async function uploadFile(
  prevState: UploadState,
  formData: FormData
): Promise<UploadState> {
  const file = formData.get('file') as File

  if (!file || file.size === 0) {
    return { error: 'No se seleccionó archivo' }
  }

  // Validar tipo
  const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf']
  if (!allowedTypes.includes(file.type)) {
    return { error: 'Tipo de archivo no permitido' }
  }

  // Validar tamaño (10MB)
  const maxSize = 10 * 1024 * 1024
  if (file.size > maxSize) {
    return { error: 'Archivo muy grande (máximo 10MB)' }
  }

  try {
    // Crear directorio si no existe
    const uploadDir = path.join(process.cwd(), 'public', 'uploads')
    await mkdir(uploadDir, { recursive: true })

    // Generar nombre único
    const ext = path.extname(file.name)
    const uniqueName = `${Date.now()}-${Math.random().toString(36).slice(2)}${ext}`
    const filePath = path.join(uploadDir, uniqueName)

    // Convertir a buffer y guardar
    const bytes = await file.arrayBuffer()
    const buffer = Buffer.from(bytes)
    await writeFile(filePath, buffer)

    revalidatePath('/uploads')

    return {
      success: true,
      fileName: uniqueName,
    }
  } catch (error) {
    console.error('Upload error:', error)
    return { error: 'Error al guardar archivo' }
  }
}
```

## Upload múltiple

```tsx
// components/MultiUpload.tsx
'use client'

import { useState } from 'react'
import { uploadFiles } from '@/actions/upload'

export function MultiUpload() {
  const [files, setFiles] = useState<File[]>([])
  const [uploading, setUploading] = useState(false)
  const [results, setResults] = useState<any[]>([])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (files.length === 0) return

    setUploading(true)
    const formData = new FormData()
    files.forEach((file) => formData.append('files', file))

    try {
      const result = await uploadFiles(formData)
      setResults(result.files || [])
      if (result.success) {
        setFiles([])
      }
    } finally {
      setUploading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <input
        type="file"
        multiple
        onChange={(e) => setFiles(Array.from(e.target.files || []))}
        className="w-full border rounded p-2"
      />

      {files.length > 0 && (
        <ul className="text-sm">
          {files.map((file, i) => (
            <li key={i}>{file.name} ({(file.size / 1024).toFixed(1)} KB)</li>
          ))}
        </ul>
      )}

      <button
        type="submit"
        disabled={uploading || files.length === 0}
        className="bg-blue-600 text-white px-4 py-2 rounded"
      >
        {uploading ? 'Subiendo...' : `Subir ${files.length} archivo(s)`}
      </button>

      {results.length > 0 && (
        <ul className="text-sm text-green-600">
          {results.map((r, i) => (
            <li key={i}>{r.success ? '✓' : '✗'} {r.name}</li>
          ))}
        </ul>
      )}
    </form>
  )
}
```

```tsx
// actions/upload.ts
'use server'

export async function uploadFiles(formData: FormData) {
  const files = formData.getAll('files') as File[]
  const results = []

  for (const file of files) {
    try {
      // Procesar cada archivo
      const uniqueName = `${Date.now()}-${file.name}`
      const bytes = await file.arrayBuffer()
      await writeFile(
        path.join(process.cwd(), 'public', 'uploads', uniqueName),
        Buffer.from(bytes)
      )
      results.push({ name: file.name, success: true, path: uniqueName })
    } catch (error) {
      results.push({ name: file.name, success: false, error: 'Error' })
    }
  }

  return { success: true, files: results }
}
```

## Drag and Drop

```tsx
// components/DropZone.tsx
'use client'

import { useState, useCallback } from 'react'
import { uploadFile } from '@/actions/upload'

export function DropZone() {
  const [isDragging, setIsDragging] = useState(false)
  const [file, setFile] = useState<File | null>(null)
  const [uploading, setUploading] = useState(false)

  const handleDrag = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    if (e.type === 'dragenter' || e.type === 'dragover') {
      setIsDragging(true)
    } else if (e.type === 'dragleave') {
      setIsDragging(false)
    }
  }, [])

  const handleDrop = useCallback((e: React.DragEvent) => {
    e.preventDefault()
    e.stopPropagation()
    setIsDragging(false)

    const droppedFile = e.dataTransfer.files[0]
    if (droppedFile) {
      setFile(droppedFile)
    }
  }, [])

  const handleUpload = async () => {
    if (!file) return

    setUploading(true)
    const formData = new FormData()
    formData.append('file', file)

    try {
      await uploadFile(null, formData)
      setFile(null)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="space-y-4">
      <div
        onDragEnter={handleDrag}
        onDragLeave={handleDrag}
        onDragOver={handleDrag}
        onDrop={handleDrop}
        className={`
          border-2 border-dashed rounded-lg p-8 text-center
          transition-colors
          ${isDragging
            ? 'border-blue-500 bg-blue-50'
            : 'border-gray-300 hover:border-gray-400'
          }
        `}
      >
        {file ? (
          <div>
            <p className="font-medium">{file.name}</p>
            <p className="text-sm text-gray-500">
              {(file.size / 1024).toFixed(1)} KB
            </p>
          </div>
        ) : (
          <div>
            <p className="text-gray-500">
              Arrastra un archivo aquí o haz clic para seleccionar
            </p>
            <input
              type="file"
              onChange={(e) => setFile(e.target.files?.[0] || null)}
              className="hidden"
              id="file-input"
            />
            <label
              htmlFor="file-input"
              className="mt-2 inline-block px-4 py-2 bg-gray-100 rounded cursor-pointer"
            >
              Seleccionar archivo
            </label>
          </div>
        )}
      </div>

      {file && (
        <button
          onClick={handleUpload}
          disabled={uploading}
          className="w-full bg-blue-600 text-white py-2 rounded"
        >
          {uploading ? 'Subiendo...' : 'Subir archivo'}
        </button>
      )}
    </div>
  )
}
```

## Progress de Upload

Para uploads grandes, usa un endpoint API con streaming:

```tsx
// app/api/upload/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { writeFile } from 'fs/promises'
import path from 'path'

export async function POST(request: NextRequest) {
  const formData = await request.formData()
  const file = formData.get('file') as File

  if (!file) {
    return NextResponse.json(
      { error: 'No file provided' },
      { status: 400 }
    )
  }

  const bytes = await file.arrayBuffer()
  const buffer = Buffer.from(bytes)

  const uploadDir = path.join(process.cwd(), 'public', 'uploads')
  const filePath = path.join(uploadDir, file.name)

  await writeFile(filePath, buffer)

  return NextResponse.json({
    success: true,
    name: file.name,
    size: file.size,
  })
}

export const config = {
  api: {
    bodyParser: false, // Necesario para manejar FormData
  },
}
```

```tsx
// components/UploadWithProgress.tsx
'use client'

import { useState } from 'react'

export function UploadWithProgress() {
  const [progress, setProgress] = useState(0)
  const [uploading, setUploading] = useState(false)

  const handleUpload = async (file: File) => {
    setUploading(true)
    setProgress(0)

    const formData = new FormData()
    formData.append('file', file)

    const xhr = new XMLHttpRequest()

    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        const percent = Math.round((e.loaded / e.total) * 100)
        setProgress(percent)
      }
    })

    xhr.addEventListener('load', () => {
      setUploading(false)
      if (xhr.status === 200) {
        alert('Upload completo!')
      }
    })

    xhr.open('POST', '/api/upload')
    xhr.send(formData)
  }

  return (
    <div className="space-y-4">
      <input
        type="file"
        onChange={(e) => {
          const file = e.target.files?.[0]
          if (file) handleUpload(file)
        }}
        disabled={uploading}
      />

      {uploading && (
        <div>
          <div className="h-2 bg-gray-200 rounded overflow-hidden">
            <div
              className="h-full bg-blue-600 transition-all"
              style={{ width: `${progress}%` }}
            />
          </div>
          <p className="text-sm text-center mt-1">{progress}%</p>
        </div>
      )}
    </div>
  )
}
```

## Validación de archivos

```tsx
// lib/validation/files.ts
type ValidationResult = {
  valid: boolean
  error?: string
}

const FILE_TYPES = {
  image: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
  document: ['application/pdf', 'application/msword'],
  video: ['video/mp4', 'video/webm'],
}

export function validateFile(
  file: File,
  options: {
    maxSize?: number          // en bytes
    allowedTypes?: string[]
    category?: keyof typeof FILE_TYPES
  }
): ValidationResult {
  const { maxSize = 10 * 1024 * 1024, allowedTypes, category } = options

  // Validar tamaño
  if (file.size > maxSize) {
    return {
      valid: false,
      error: `Archivo muy grande. Máximo ${maxSize / 1024 / 1024}MB`,
    }
  }

  // Validar tipo
  const types = allowedTypes || (category ? FILE_TYPES[category] : null)
  if (types && !types.includes(file.type)) {
    return {
      valid: false,
      error: `Tipo de archivo no permitido. Permitidos: ${types.join(', ')}`,
    }
  }

  return { valid: true }
}
```

## Resumen

| Método | Cuándo usar |
|--------|-------------|
| Server Action | Formularios simples, archivos pequeños |
| API Route | Progress, archivos grandes, procesamiento |
| Supabase Storage | Producción, CDN, transformaciones |
| Sistema de archivos | Desarrollo, archivos temporales |

## Buenas prácticas

1. **Validar siempre**: Tipo, tamaño, contenido
2. **Nombres únicos**: UUID o timestamp
3. **No guardar en `public/`** en producción: Usa storage externo
4. **Límites de tamaño**: Configurar en servidor y cliente
5. **Progress para UX**: En archivos > 1MB
6. **Limpiar archivos temporales**: Cron job o proceso
