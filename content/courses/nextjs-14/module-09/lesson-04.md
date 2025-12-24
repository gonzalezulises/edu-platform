# SEO y Metadata

## Introducción

Next.js 14 proporciona una API de Metadata poderosa para SEO. Los metadatos se generan en el servidor, asegurando que los crawlers vean contenido optimizado.

## Metadata estática

```tsx
// app/layout.tsx
import { Metadata } from 'next'

export const metadata: Metadata = {
  title: {
    template: '%s | Mi Plataforma',
    default: 'Mi Plataforma Educativa',
  },
  description: 'Aprende programación con cursos de alta calidad',
  keywords: ['cursos', 'programación', 'next.js', 'react'],
  authors: [{ name: 'Tu Nombre' }],
  creator: 'Tu Empresa',
  metadataBase: new URL('https://midominio.com'),
  openGraph: {
    type: 'website',
    locale: 'es_ES',
    siteName: 'Mi Plataforma',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Mi Plataforma Educativa',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    creator: '@tuhandle',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-image-preview': 'large',
    },
  },
}
```

## Metadata dinámica

```tsx
// app/courses/[slug]/page.tsx
import { Metadata } from 'next'
import { getCourse } from '@/lib/dal'

type Props = {
  params: { slug: string }
}

export async function generateMetadata({ params }: Props): Promise<Metadata> {
  const course = await getCourse(params.slug)

  if (!course) {
    return {
      title: 'Curso no encontrado',
    }
  }

  return {
    title: course.title,
    description: course.description,
    openGraph: {
      title: course.title,
      description: course.description,
      images: [
        {
          url: course.thumbnail,
          width: 1200,
          height: 630,
          alt: course.title,
        },
      ],
    },
    twitter: {
      card: 'summary_large_image',
      title: course.title,
      description: course.description,
      images: [course.thumbnail],
    },
  }
}
```

## Imágenes Open Graph dinámicas

```tsx
// app/og/route.tsx
import { ImageResponse } from 'next/og'

export const runtime = 'edge'

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url)
  const title = searchParams.get('title') || 'Mi Plataforma'

  return new ImageResponse(
    (
      <div
        style={{
          height: '100%',
          width: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          backgroundColor: '#1a1a2e',
          color: 'white',
        }}
      >
        <div style={{ fontSize: 60, fontWeight: 'bold' }}>{title}</div>
        <div style={{ fontSize: 30, marginTop: 20 }}>Mi Plataforma</div>
      </div>
    ),
    {
      width: 1200,
      height: 630,
    }
  )
}
```

```tsx
// Uso en metadata
export async function generateMetadata({ params }): Promise<Metadata> {
  const course = await getCourse(params.slug)

  return {
    openGraph: {
      images: [`/og?title=${encodeURIComponent(course.title)}`],
    },
  }
}
```

## Sitemap.xml

```tsx
// app/sitemap.ts
import { MetadataRoute } from 'next'
import { getCourses, getPosts } from '@/lib/dal'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = 'https://midominio.com'

  // Páginas estáticas
  const staticPages = [
    {
      url: baseUrl,
      lastModified: new Date(),
      changeFrequency: 'weekly' as const,
      priority: 1,
    },
    {
      url: `${baseUrl}/about`,
      lastModified: new Date(),
      changeFrequency: 'monthly' as const,
      priority: 0.8,
    },
    {
      url: `${baseUrl}/courses`,
      lastModified: new Date(),
      changeFrequency: 'daily' as const,
      priority: 0.9,
    },
  ]

  // Páginas dinámicas
  const courses = await getCourses()
  const coursePages = courses.map((course) => ({
    url: `${baseUrl}/courses/${course.slug}`,
    lastModified: course.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.7,
  }))

  const posts = await getPosts()
  const postPages = posts.map((post) => ({
    url: `${baseUrl}/blog/${post.slug}`,
    lastModified: post.updatedAt,
    changeFrequency: 'weekly' as const,
    priority: 0.6,
  }))

  return [...staticPages, ...coursePages, ...postPages]
}
```

## Robots.txt

```tsx
// app/robots.ts
import { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin/', '/api/', '/dashboard/'],
      },
    ],
    sitemap: 'https://midominio.com/sitemap.xml',
  }
}
```

## JSON-LD (Structured Data)

```tsx
// components/JsonLd.tsx
interface CourseJsonLdProps {
  course: {
    title: string
    description: string
    instructor: string
    price: number
    image: string
    rating: number
    reviewCount: number
  }
}

export function CourseJsonLd({ course }: CourseJsonLdProps) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Course',
    name: course.title,
    description: course.description,
    provider: {
      '@type': 'Organization',
      name: 'Mi Plataforma',
      sameAs: 'https://midominio.com',
    },
    instructor: {
      '@type': 'Person',
      name: course.instructor,
    },
    offers: {
      '@type': 'Offer',
      price: course.price,
      priceCurrency: 'USD',
    },
    image: course.image,
    aggregateRating: {
      '@type': 'AggregateRating',
      ratingValue: course.rating,
      reviewCount: course.reviewCount,
    },
  }

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
    />
  )
}

// Uso en página
export default function CoursePage({ course }) {
  return (
    <>
      <CourseJsonLd course={course} />
      <CourseContent course={course} />
    </>
  )
}
```

## Canonical URLs

```tsx
// app/courses/[slug]/page.tsx
export async function generateMetadata({ params }): Promise<Metadata> {
  return {
    alternates: {
      canonical: `/courses/${params.slug}`,
      languages: {
        'es-ES': `/es/courses/${params.slug}`,
        'en-US': `/en/courses/${params.slug}`,
      },
    },
  }
}
```

## Títulos por sección

```tsx
// app/layout.tsx
export const metadata: Metadata = {
  title: {
    template: '%s | Mi Plataforma',
    default: 'Mi Plataforma',
  },
}

// app/courses/page.tsx
export const metadata: Metadata = {
  title: 'Cursos',  // Renderiza: "Cursos | Mi Plataforma"
}

// app/courses/[slug]/page.tsx
export async function generateMetadata({ params }): Promise<Metadata> {
  const course = await getCourse(params.slug)
  return {
    title: course.title,  // Renderiza: "Título del Curso | Mi Plataforma"
  }
}
```

## Verificación de motores

```tsx
// app/layout.tsx
export const metadata: Metadata = {
  verification: {
    google: 'google-verification-code',
    yandex: 'yandex-verification-code',
    yahoo: 'yahoo-verification-code',
  },
}
```

## Checklist SEO

### Técnico
- [ ] Sitemap.xml generado
- [ ] Robots.txt configurado
- [ ] URLs canónicas
- [ ] HTTPS activo
- [ ] Mobile-friendly

### Contenido
- [ ] Títulos únicos por página
- [ ] Descripciones descriptivas (150-160 chars)
- [ ] Headers jerárquicos (H1, H2, H3)
- [ ] Alt text en imágenes
- [ ] Contenido de calidad

### Social
- [ ] Open Graph tags
- [ ] Twitter cards
- [ ] Imágenes OG optimizadas (1200x630)

### Structured Data
- [ ] JSON-LD para tipo de contenido
- [ ] Validar en Rich Results Test

## Herramientas

- [Google Search Console](https://search.google.com/search-console)
- [Rich Results Test](https://search.google.com/test/rich-results)
- [Schema Markup Validator](https://validator.schema.org/)
- [Open Graph Debugger](https://developers.facebook.com/tools/debug/)
- [Twitter Card Validator](https://cards-dev.twitter.com/validator)
