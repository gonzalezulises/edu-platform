import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

async function seedPythonCourse() {
  console.log('=== CREANDO CURSO DE PYTHON ===\n')

  // 1. Verificar si el curso ya existe
  const { data: existingCourse } = await supabase
    .from('courses')
    .select('id')
    .eq('title', 'Introduccion a Python')
    .single()

  let courseId

  if (existingCourse) {
    console.log(`⏭️  Curso ya existe (ID: ${existingCourse.id})`)
    courseId = existingCourse.id
  } else {
    // Crear el curso
    const { data: course, error: courseError } = await supabase
      .from('courses')
      .insert({
        title: 'Introduccion a Python',
        description: 'Aprende Python desde cero con ejercicios practicos interactivos. Ideal para principiantes que quieren dar sus primeros pasos en programacion.',
        thumbnail_url: 'https://upload.wikimedia.org/wikipedia/commons/c/c3/Python-logo-notext.svg',
        is_published: true
      })
      .select()
      .single()

    if (courseError) {
      console.error('Error creando curso:', courseError)
      process.exit(1)
    }

    console.log(`✅ Curso creado: ${course.title} (ID: ${course.id})`)
    courseId = course.id
  }

  // 2. Verificar si el modulo ya existe
  const { data: existingModule } = await supabase
    .from('modules')
    .select('id')
    .eq('course_id', courseId)
    .eq('order_index', 1)
    .single()

  let moduleId

  if (existingModule) {
    console.log(`⏭️  Modulo ya existe (ID: ${existingModule.id})`)
    moduleId = existingModule.id
  } else {
    const { data: module, error: moduleError } = await supabase
      .from('modules')
      .insert({
        course_id: courseId,
        title: 'Fundamentos de Python',
        description: 'Variables, operadores, control de flujo, listas y funciones',
        order_index: 1,
        is_locked: false
      })
      .select()
      .single()

    if (moduleError) {
      console.error('Error creando modulo:', moduleError)
      process.exit(1)
    }

    console.log(`✅ Modulo creado: ${module.title} (ID: ${module.id})`)
    moduleId = module.id
  }

  // 3. Crear las lecciones
  const lessons = [
    {
      title: 'Variables y Tipos de Datos',
      content: 'Aprende sobre variables, strings, integers, floats y booleans',
      lesson_type: 'text',
      order_index: 1,
      duration_minutes: 20,
      is_required: true,
      video_url: 'https://www.youtube.com/embed/Z1Yd7upQsXY'
    },
    {
      title: 'Operadores y Expresiones',
      content: 'Operadores aritmeticos, de comparacion y logicos',
      lesson_type: 'text',
      order_index: 2,
      duration_minutes: 15,
      is_required: true,
      video_url: 'https://www.youtube.com/embed/v5MR5JnKcZI'
    },
    {
      title: 'Estructuras de Control',
      content: 'Condicionales if, elif, else para tomar decisiones',
      lesson_type: 'text',
      order_index: 3,
      duration_minutes: 20,
      is_required: true,
      video_url: 'https://www.youtube.com/embed/PqFKRqpHrjw'
    },
    {
      title: 'Listas y Bucles',
      content: 'Listas, bucles for y while para iterar',
      lesson_type: 'text',
      order_index: 4,
      duration_minutes: 25,
      is_required: true,
      video_url: 'https://www.youtube.com/embed/ohCDWZgNIU0'
    },
    {
      title: 'Funciones',
      content: 'Crear y usar funciones reutilizables',
      lesson_type: 'text',
      order_index: 5,
      duration_minutes: 25,
      is_required: true,
      video_url: 'https://www.youtube.com/embed/u-OmVr_fT4s'
    }
  ]

  console.log('\nCreando lecciones...')

  for (const lessonData of lessons) {
    // Verificar si la leccion ya existe
    const { data: existingLesson } = await supabase
      .from('lessons')
      .select('id, title')
      .eq('module_id', moduleId)
      .eq('order_index', lessonData.order_index)
      .single()

    if (existingLesson) {
      console.log(`  ⏭️  ${existingLesson.title} (ya existe)`)
      continue
    }

    const { data: lesson, error: lessonError } = await supabase
      .from('lessons')
      .insert({
        course_id: courseId,
        module_id: moduleId,
        ...lessonData
      })
      .select()
      .single()

    if (lessonError) {
      console.error(`Error creando leccion ${lessonData.title}:`, lessonError)
    } else {
      console.log(`  ✅ ${lesson.title}`)
    }
  }

  console.log('\n=== CURSO CREADO EXITOSAMENTE ===')
  console.log(`\nURL del curso: /courses/${courseId}`)
}

seedPythonCourse()
