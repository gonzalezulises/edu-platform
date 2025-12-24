# Optimización de Imágenes

## Introducción

Next.js proporciona el componente `Image` que optimiza imágenes automáticamente: lazy loading, formatos modernos (WebP/AVIF), y redimensionamiento responsive.

## Componente Image básico

```tsx
import Image from 'next/image'

export function Avatar() {
  return (
    <Image
      src="/avatar.jpg"
      alt="Avatar del usuario"
      width={100}
      height={100}
    />
  )
}
```

## Props principales

| Prop | Tipo | Descripción |
|------|------|-------------|
| `src` | string | URL de la imagen (requerido) |
| `alt` | string | Texto alternativo (requerido) |
| `width` | number | Ancho en píxeles |
| `height` | number | Alto en píxeles |
| `fill` | boolean | Llenar contenedor padre |
| `priority` | boolean | Precargar (LCP) |
| `quality` | number | Calidad 1-100 (default: 75) |
| `placeholder` | string | `blur` o `empty` |
| `blurDataURL` | string | Base64 para placeholder |

## Imágenes locales

```tsx
import Image from 'next/image'
import profilePic from '@/public/images/profile.jpg'

export function Profile() {
  // Las dimensiones se infieren automáticamente
  return (
    <Image
      src={profilePic}
      alt="Foto de perfil"
      placeholder="blur"  // blur automático para locales
    />
  )
}
```

## Imágenes remotas

Requieren configuración en `next.config.js`:

```js
// next.config.js
module.exports = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'images.unsplash.com',
        port: '',
        pathname: '/**',
      },
      {
        protocol: 'https',
        hostname: '*.supabase.co',
        pathname: '/storage/v1/object/public/**',
      },
    ],
  },
}
```

```tsx
// Uso con imagen remota
<Image
  src="https://images.unsplash.com/photo-xxx"
  alt="Foto de Unsplash"
  width={800}
  height={600}
/>
```

## fill mode

Para imágenes que deben llenar su contenedor:

```tsx
export function HeroImage() {
  return (
    <div className="relative w-full h-96">
      <Image
        src="/hero.jpg"
        alt="Hero image"
        fill
        style={{ objectFit: 'cover' }}
        priority  // Importante para LCP
      />
    </div>
  )
}
```

## sizes para responsive

```tsx
// Imagen que es 100vw en móvil, 50vw en tablet, 33vw en desktop
<Image
  src="/product.jpg"
  alt="Producto"
  fill
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>
```

El atributo `sizes` ayuda al navegador a elegir el tamaño óptimo.

## Lazy loading y priority

```tsx
// Above the fold - cargar inmediatamente
<Image
  src="/hero.jpg"
  alt="Hero"
  fill
  priority  // No lazy load
/>

// Below the fold - lazy load (default)
<Image
  src="/gallery-1.jpg"
  alt="Galería"
  width={400}
  height={300}
  // loading="lazy" es el default
/>
```

## Placeholder blur

### Imágenes locales (automático)

```tsx
import Image from 'next/image'
import photo from '@/public/photo.jpg'

<Image
  src={photo}
  alt="Foto"
  placeholder="blur"  // Genera blur automáticamente
/>
```

### Imágenes remotas (manual)

```tsx
// Generar blurDataURL con plaiceholder o similar
const blurDataURL = 'data:image/jpeg;base64,/9j/4AAQSkZJRg...'

<Image
  src="https://example.com/photo.jpg"
  alt="Foto"
  width={800}
  height={600}
  placeholder="blur"
  blurDataURL={blurDataURL}
/>
```

### Generar blur en servidor

```tsx
// lib/blur.ts
import { getPlaiceholder } from 'plaiceholder'

export async function getBlurDataURL(src: string) {
  const buffer = await fetch(src).then((res) => res.arrayBuffer())
  const { base64 } = await getPlaiceholder(Buffer.from(buffer))
  return base64
}
```

```tsx
// app/photos/[id]/page.tsx
import { getBlurDataURL } from '@/lib/blur'

export default async function PhotoPage({ params }) {
  const photo = await getPhoto(params.id)
  const blurDataURL = await getBlurDataURL(photo.url)

  return (
    <Image
      src={photo.url}
      alt={photo.title}
      width={1200}
      height={800}
      placeholder="blur"
      blurDataURL={blurDataURL}
    />
  )
}
```

## Galería de imágenes

```tsx
// components/Gallery.tsx
import Image from 'next/image'

interface Photo {
  id: string
  url: string
  title: string
  width: number
  height: number
}

export function Gallery({ photos }: { photos: Photo[] }) {
  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
      {photos.map((photo, index) => (
        <div key={photo.id} className="relative aspect-square">
          <Image
            src={photo.url}
            alt={photo.title}
            fill
            sizes="(max-width: 768px) 50vw, (max-width: 1200px) 33vw, 25vw"
            style={{ objectFit: 'cover' }}
            className="rounded-lg"
            priority={index < 4}  // Primeras 4 sin lazy load
          />
        </div>
      ))}
    </div>
  )
}
```

## Background images

Para fondos, usa CSS con el loader:

```tsx
// Con loader personalizado
import { unstable_getImgProps as getImgProps } from 'next/image'

export function Hero() {
  const { props: imgProps } = getImgProps({
    src: '/hero-bg.jpg',
    alt: '',
    width: 1920,
    height: 1080,
    quality: 80,
  })

  return (
    <section
      className="h-screen flex items-center justify-center"
      style={{
        backgroundImage: `url(${imgProps.src})`,
        backgroundSize: 'cover',
        backgroundPosition: 'center',
      }}
    >
      <h1 className="text-white text-5xl font-bold">
        Hero Title
      </h1>
    </section>
  )
}
```

## Loader personalizado

Para CDNs externos como Cloudinary, Imgix:

```tsx
// lib/imageLoader.ts
import { ImageLoaderProps } from 'next/image'

export function cloudinaryLoader({ src, width, quality }: ImageLoaderProps) {
  const params = ['f_auto', 'c_limit', `w_${width}`, `q_${quality || 'auto'}`]
  return `https://res.cloudinary.com/demo/image/upload/${params.join(',')}${src}`
}
```

```tsx
import Image from 'next/image'
import { cloudinaryLoader } from '@/lib/imageLoader'

<Image
  loader={cloudinaryLoader}
  src="/sample.jpg"
  alt="Sample"
  width={800}
  height={600}
/>
```

O configurar globalmente:

```js
// next.config.js
module.exports = {
  images: {
    loader: 'custom',
    loaderFile: './lib/imageLoader.ts',
  },
}
```

## Formatos modernos

Next.js sirve automáticamente:
- **WebP** si el navegador lo soporta
- **AVIF** para navegadores compatibles (mejor compresión)

Configurar formatos:

```js
// next.config.js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
  },
}
```

## Debugging

```tsx
// Ver qué imagen se está sirviendo
<Image
  src="/photo.jpg"
  alt="Photo"
  width={800}
  height={600}
  onLoad={(e) => {
    console.log('Loaded:', e.currentTarget.currentSrc)
  }}
/>
```

## Resumen de optimizaciones

| Optimización | Cómo activar |
|--------------|--------------|
| Lazy loading | Automático (default) |
| WebP/AVIF | Automático |
| Responsive | `sizes` prop |
| Blur placeholder | `placeholder="blur"` |
| Priority loading | `priority` prop |
| Quality | `quality` prop |

## Buenas prácticas

1. **Siempre usar `alt`**: Accesibilidad y SEO
2. **`priority` para LCP**: Hero images, above the fold
3. **`sizes` para responsive**: Ayuda al navegador
4. **Dimensiones conocidas**: Evita layout shift
5. **Placeholder blur**: Mejor UX en carga
6. **Formatos modernos**: WebP/AVIF automáticos
7. **Loader para CDN**: Cloudinary, Imgix, etc.
