import { createClient } from '@supabase/supabase-js'
import { config } from 'dotenv'

config({ path: '.env.local' })

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
)

const { data: lessons, error } = await supabase
  .from('lessons')
  .select('id, title, video_url, module_id')
  .order('module_id')
  .order('order_index')

if (error) {
  console.error('Error:', error)
  process.exit(1)
}

console.log('=== ESTADO DE VIDEOS EN LECCIONES ===\n')

let withVideo = 0
let withoutVideo = 0

for (const lesson of lessons || []) {
  const hasVideo = lesson.video_url && lesson.video_url.trim() !== ''
  if (hasVideo) withVideo++
  else withoutVideo++

  console.log(`Module ${lesson.module_id} | ${lesson.title}`)
  console.log(`  Video: ${lesson.video_url || '❌ SIN VIDEO'}`)
  console.log('')
}

console.log(`\n=== RESUMEN ===`)
console.log(`Con video: ${withVideo}`)
console.log(`Sin video: ${withoutVideo}`)
