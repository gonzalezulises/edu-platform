# Streaming de Video

## Introducción

El streaming de video permite reproducir contenido mientras se descarga, sin esperar la descarga completa. Exploraremos diferentes estrategias para implementar video en Next.js.

## Video nativo HTML5

### Elemento video básico

```tsx
export function VideoPlayer({ src }: { src: string }) {
  return (
    <video
      src={src}
      controls
      className="w-full rounded-lg"
      preload="metadata"
    >
      Tu navegador no soporta video HTML5.
    </video>
  )
}
```

### Múltiples formatos

```tsx
export function VideoPlayer({ sources }: { sources: { src: string; type: string }[] }) {
  return (
    <video controls className="w-full rounded-lg">
      {sources.map((source) => (
        <source key={source.src} src={source.src} type={source.type} />
      ))}
      Tu navegador no soporta video HTML5.
    </video>
  )
}

// Uso
<VideoPlayer
  sources={[
    { src: '/video.webm', type: 'video/webm' },
    { src: '/video.mp4', type: 'video/mp4' },
  ]}
/>
```

## YouTube Embed

```tsx
// components/YouTubePlayer.tsx
interface YouTubePlayerProps {
  videoId: string
  title?: string
}

export function YouTubePlayer({ videoId, title = 'Video' }: YouTubePlayerProps) {
  return (
    <div className="relative w-full aspect-video">
      <iframe
        src={`https://www.youtube.com/embed/${videoId}?rel=0&modestbranding=1`}
        title={title}
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
        className="absolute inset-0 w-full h-full rounded-lg"
      />
    </div>
  )
}
```

### Lazy loading de YouTube

```tsx
'use client'

import { useState } from 'react'
import Image from 'next/image'

export function YouTubeLazy({ videoId, title }: { videoId: string; title: string }) {
  const [isLoaded, setIsLoaded] = useState(false)
  const thumbnailUrl = `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`

  if (!isLoaded) {
    return (
      <button
        onClick={() => setIsLoaded(true)}
        className="relative w-full aspect-video group"
      >
        <Image
          src={thumbnailUrl}
          alt={title}
          fill
          className="object-cover rounded-lg"
        />
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-16 h-16 bg-red-600 rounded-full flex items-center justify-center group-hover:scale-110 transition-transform">
            <svg className="w-8 h-8 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
              <path d="M8 5v14l11-7z" />
            </svg>
          </div>
        </div>
      </button>
    )
  }

  return (
    <div className="relative w-full aspect-video">
      <iframe
        src={`https://www.youtube.com/embed/${videoId}?autoplay=1&rel=0`}
        title={title}
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
        className="absolute inset-0 w-full h-full rounded-lg"
      />
    </div>
  )
}
```

## Vimeo Embed

```tsx
export function VimeoPlayer({ videoId, title = 'Video' }: { videoId: string; title?: string }) {
  return (
    <div className="relative w-full aspect-video">
      <iframe
        src={`https://player.vimeo.com/video/${videoId}?badge=0&autopause=0&quality_selector=1`}
        title={title}
        allow="autoplay; fullscreen; picture-in-picture"
        allowFullScreen
        className="absolute inset-0 w-full h-full rounded-lg"
      />
    </div>
  )
}
```

## Player universal

```tsx
// components/VideoPlayer.tsx
'use client'

interface VideoPlayerProps {
  url: string
  title?: string
}

function getVideoInfo(url: string) {
  // YouTube
  const youtubeMatch = url.match(
    /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&?\s]+)/
  )
  if (youtubeMatch) {
    return { type: 'youtube', id: youtubeMatch[1] }
  }

  // Vimeo
  const vimeoMatch = url.match(/vimeo\.com\/(?:video\/)?(\d+)/)
  if (vimeoMatch) {
    return { type: 'vimeo', id: vimeoMatch[1] }
  }

  // Video directo
  if (url.match(/\.(mp4|webm|ogg)(\?|$)/i)) {
    return { type: 'direct', url }
  }

  return null
}

export function VideoPlayer({ url, title = 'Video' }: VideoPlayerProps) {
  const info = getVideoInfo(url)

  if (!info) {
    return (
      <div className="w-full aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
        <p className="text-gray-500">Video no disponible</p>
      </div>
    )
  }

  if (info.type === 'youtube') {
    return (
      <div className="relative w-full aspect-video">
        <iframe
          src={`https://www.youtube.com/embed/${info.id}?rel=0`}
          title={title}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
          className="absolute inset-0 w-full h-full rounded-lg"
        />
      </div>
    )
  }

  if (info.type === 'vimeo') {
    return (
      <div className="relative w-full aspect-video">
        <iframe
          src={`https://player.vimeo.com/video/${info.id}`}
          title={title}
          allow="autoplay; fullscreen; picture-in-picture"
          allowFullScreen
          className="absolute inset-0 w-full h-full rounded-lg"
        />
      </div>
    )
  }

  // Video directo
  return (
    <video
      src={info.url}
      controls
      className="w-full rounded-lg"
      preload="metadata"
    >
      Tu navegador no soporta video.
    </video>
  )
}
```

## Streaming desde Supabase Storage

### Subir video

```tsx
'use server'

export async function uploadVideo(formData: FormData) {
  const supabase = await createClient()
  const file = formData.get('video') as File

  if (!file) return { error: 'No file' }

  // Validar tipo y tamaño
  const allowedTypes = ['video/mp4', 'video/webm']
  if (!allowedTypes.includes(file.type)) {
    return { error: 'Tipo no permitido' }
  }

  const maxSize = 500 * 1024 * 1024 // 500MB
  if (file.size > maxSize) {
    return { error: 'Video muy grande' }
  }

  const fileName = `videos/${Date.now()}-${file.name}`

  const { data, error } = await supabase.storage
    .from('content')
    .upload(fileName, file, {
      cacheControl: '3600',
      contentType: file.type,
    })

  if (error) return { error: 'Error al subir' }

  const { data: { publicUrl } } = supabase.storage
    .from('content')
    .getPublicUrl(data.path)

  return { success: true, url: publicUrl }
}
```

### Reproducir desde Supabase

```tsx
export async function LessonVideo({ lessonId }: { lessonId: string }) {
  const supabase = await createClient()

  const { data: lesson } = await supabase
    .from('lessons')
    .select('video_url, title')
    .eq('id', lessonId)
    .single()

  if (!lesson?.video_url) {
    return <p>Video no disponible</p>
  }

  return <VideoPlayer url={lesson.video_url} title={lesson.title} />
}
```

## Tracking de progreso

```tsx
'use client'

import { useRef, useEffect } from 'react'
import { updateProgress } from '@/actions/progress'

export function TrackedVideo({
  lessonId,
  videoUrl,
}: {
  lessonId: string
  videoUrl: string
}) {
  const videoRef = useRef<HTMLVideoElement>(null)
  const progressRef = useRef(0)

  useEffect(() => {
    const video = videoRef.current
    if (!video) return

    const handleTimeUpdate = () => {
      const progress = (video.currentTime / video.duration) * 100
      // Solo guardar cada 5%
      if (progress - progressRef.current >= 5) {
        progressRef.current = progress
        updateProgress(lessonId, progress)
      }
    }

    const handleEnded = () => {
      updateProgress(lessonId, 100)
    }

    video.addEventListener('timeupdate', handleTimeUpdate)
    video.addEventListener('ended', handleEnded)

    return () => {
      video.removeEventListener('timeupdate', handleTimeUpdate)
      video.removeEventListener('ended', handleEnded)
    }
  }, [lessonId])

  return (
    <video
      ref={videoRef}
      src={videoUrl}
      controls
      className="w-full rounded-lg"
    />
  )
}
```

## Video protegido (signed URLs)

```tsx
// actions/video.ts
'use server'

export async function getVideoUrl(lessonId: string) {
  const supabase = await createClient()

  // Verificar acceso
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) throw new Error('No autorizado')

  const hasAccess = await checkEnrollment(user.id, lessonId)
  if (!hasAccess) throw new Error('No tienes acceso')

  // Generar URL firmada (expira en 1 hora)
  const { data, error } = await supabase.storage
    .from('private-videos')
    .createSignedUrl(`lessons/${lessonId}.mp4`, 3600)

  if (error) throw new Error('Error al generar URL')

  return data.signedUrl
}
```

```tsx
// components/ProtectedVideo.tsx
'use client'

import { useEffect, useState } from 'react'
import { getVideoUrl } from '@/actions/video'

export function ProtectedVideo({ lessonId }: { lessonId: string }) {
  const [url, setUrl] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    getVideoUrl(lessonId)
      .then(setUrl)
      .catch((e) => setError(e.message))
  }, [lessonId])

  if (error) return <p className="text-red-500">{error}</p>
  if (!url) return <p>Cargando video...</p>

  return (
    <video src={url} controls className="w-full rounded-lg" />
  )
}
```

## Resumen

| Fuente | Componente |
|--------|------------|
| YouTube | iframe con embed URL |
| Vimeo | iframe con player URL |
| MP4/WebM | elemento `<video>` |
| Supabase | URL pública o firmada |

## Buenas prácticas

1. **Lazy load embeds**: Mostrar thumbnail primero
2. **aspect-video**: Mantener ratio 16:9
3. **preload="metadata"**: Cargar solo info básica
4. **Signed URLs para privado**: Expiración corta
5. **Track progress**: Para cursos, marcar visto
6. **Fallback**: Mensaje cuando no hay video
