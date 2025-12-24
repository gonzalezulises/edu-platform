import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

// Mapeo de videos de YouTube por tema de lección
// Formato: parte del título -> URL del video embed
const videoMappings = [
  // Módulo 1: Fundamentos
  { match: 'Por qué Next.js', video: 'https://www.youtube.com/embed/Sklc_fQBmcs' },
  { match: 'Arquitectura', video: 'https://www.youtube.com/embed/B_u1BAZm2SA' },
  { match: 'Setup', video: 'https://www.youtube.com/embed/n96m8fr5aeU' },
  { match: 'primera página', video: 'https://www.youtube.com/embed/ZVnjOPwW4ZA' },

  // Módulo 2: Routing
  { match: 'Rutas estáticas', video: 'https://www.youtube.com/embed/N4-EkNJ6RFM' },
  { match: 'Layouts anidados', video: 'https://www.youtube.com/embed/f93g238p9tM' },
  { match: 'Loading', video: 'https://www.youtube.com/embed/vuznUqirz5I' },
  { match: 'Parallel Routes', video: 'https://www.youtube.com/embed/4BUIeofMuMs' },
  { match: 'Navegación', video: 'https://www.youtube.com/embed/gSSsZReIFRk' },

  // Módulo 3: Server Components y Data Fetching
  { match: 'Server vs Client', video: 'https://www.youtube.com/embed/8pzIuLFuv6U' },
  { match: 'Fetching en Server', video: 'https://www.youtube.com/embed/WKfPctdIDek' },
  { match: 'Caching y Revalidación', video: 'https://www.youtube.com/embed/PAXWRgEo7Ns' },
  { match: 'composición', video: 'https://www.youtube.com/embed/bKm1rNaCFOo' },
  { match: 'Streaming', video: 'https://www.youtube.com/embed/OPET9XQBHUE' },

  // Módulo 4: Server Actions
  { match: 'Introducción a Server Actions', video: 'https://www.youtube.com/embed/dDpZfOQBMaU' },
  { match: 'Validación', video: 'https://www.youtube.com/embed/UKupfEuUc1M' },
  { match: 'Optimistic', video: 'https://www.youtube.com/embed/W6V91VeghjI' },
  { match: 'Revalidación después', video: 'https://www.youtube.com/embed/gQ2bVQPFS4U' },

  // Módulo 5: Autenticación
  { match: 'Estrategias de autenticación', video: 'https://www.youtube.com/embed/nLgEERINs34' },
  { match: 'NextAuth', video: 'https://www.youtube.com/embed/1MTyCvS05V4' },
  { match: 'Auth.js', video: 'https://www.youtube.com/embed/1MTyCvS05V4' },
  { match: 'Middleware para protección', video: 'https://www.youtube.com/embed/vDgRABNCiqk' },
  { match: 'Roles y permisos', video: 'https://www.youtube.com/embed/MNm1XhDjX1s' },

  // Módulo 6: Base de datos
  { match: 'Opciones de base', video: 'https://www.youtube.com/embed/kobINV9O5fc' },
  { match: 'Prisma vs Drizzle', video: 'https://www.youtube.com/embed/FMnlyi60avU' },
  { match: 'Prisma', video: 'https://www.youtube.com/embed/kobINV9O5fc' },
  { match: 'Queries en Server', video: 'https://www.youtube.com/embed/8DiT-LdYXC0' },
  { match: 'Transacciones', video: 'https://www.youtube.com/embed/5k7ZGhL3pI0' },

  // Módulo 7: Estilos y UI
  { match: 'CSS Modules', video: 'https://www.youtube.com/embed/jMy4pVZMyLM' },
  { match: 'Tailwind', video: 'https://www.youtube.com/embed/jMy4pVZMyLM' },
  { match: 'shadcn', video: 'https://www.youtube.com/embed/s5jPwPZrJhw' },
  { match: 'Fonts', video: 'https://www.youtube.com/embed/3HotNkwgz2Q' },
  { match: 'Animaciones', video: 'https://www.youtube.com/embed/Sbl04kOL1dM' },

  // Módulo 8: Testing
  { match: 'Testing de componentes', video: 'https://www.youtube.com/embed/AS79oJ3Fcf0' },
  { match: 'Vitest', video: 'https://www.youtube.com/embed/g3GFZx1KyWs' },
  { match: 'Testing de Server Actions', video: 'https://www.youtube.com/embed/mJn0B7mXmDI' },
  { match: 'E2E', video: 'https://www.youtube.com/embed/zoC6nNw1oh0' },
  { match: 'Playwright', video: 'https://www.youtube.com/embed/zoC6nNw1oh0' },
  { match: 'Type checking', video: 'https://www.youtube.com/embed/pnLC-9waA44' },

  // Módulo 9: Performance
  { match: 'Core Web Vitals', video: 'https://www.youtube.com/embed/UCrWwfF63Ug' },
  { match: 'Bundle analysis', video: 'https://www.youtube.com/embed/Sk2XRK3tO-A' },
  { match: 'Edge Runtime', video: 'https://www.youtube.com/embed/qIyEwOEKnE0' },
  { match: 'ISR', video: 'https://www.youtube.com/embed/PAXWRgEo7Ns' },

  // Módulo 10: Deployment
  { match: 'Deploy en Vercel', video: 'https://www.youtube.com/embed/9n8Gh4t5byE' },
  { match: 'Vercel', video: 'https://www.youtube.com/embed/AiiGjB2AxqA' },
  { match: 'Docker', video: 'https://www.youtube.com/embed/Wm0Zd2jawAc' },
  { match: 'self-hosted', video: 'https://www.youtube.com/embed/Wm0Zd2jawAc' },
  { match: 'Monitoreo', video: 'https://www.youtube.com/embed/4985tlhdij4' },
  { match: 'observabilidad', video: 'https://www.youtube.com/embed/4985tlhdij4' },
  { match: 'CI/CD', video: 'https://www.youtube.com/embed/eJBQqzXmTeM' },
]

// Función para encontrar video apropiado para una lección
function findVideoForLesson(title) {
  const lowerTitle = title.toLowerCase()
  for (const mapping of videoMappings) {
    if (lowerTitle.includes(mapping.match.toLowerCase())) {
      return mapping.video
    }
  }
  return null
}

async function updateVideos() {
  // Obtener todas las lecciones
  const { data: lessons, error } = await supabase
    .from('lessons')
    .select('id, title, video_url, module_id')
    .order('module_id')
    .order('order_index')

  if (error) {
    console.error('Error obteniendo lecciones:', error)
    process.exit(1)
  }

  console.log('=== ACTUALIZANDO VIDEOS ===\n')

  let updated = 0
  let skipped = 0
  let notFound = 0

  for (const lesson of lessons || []) {
    // Si ya tiene video, saltar
    if (lesson.video_url && lesson.video_url.trim() !== '') {
      console.log(`⏭️  ${lesson.title} - Ya tiene video`)
      skipped++
      continue
    }

    // Buscar video apropiado
    const videoUrl = findVideoForLesson(lesson.title)

    if (!videoUrl) {
      console.log(`❌ ${lesson.title} - No se encontró video`)
      notFound++
      continue
    }

    // Actualizar en la base de datos
    const { error: updateError } = await supabase
      .from('lessons')
      .update({ video_url: videoUrl })
      .eq('id', lesson.id)

    if (updateError) {
      console.error(`Error actualizando ${lesson.title}:`, updateError)
      continue
    }

    console.log(`✅ ${lesson.title}`)
    console.log(`   → ${videoUrl}`)
    updated++
  }

  console.log('\n=== RESUMEN ===')
  console.log(`Actualizados: ${updated}`)
  console.log(`Ya tenían video: ${skipped}`)
  console.log(`Sin video disponible: ${notFound}`)
}

updateVideos()
