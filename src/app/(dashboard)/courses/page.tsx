import { createClient } from '@/lib/supabase/server'
import Link from 'next/link'
import Navbar from '@/components/Navbar'

export default async function CoursesPage() {
  const supabase = await createClient()

  const { data: courses } = await supabase
    .from('courses')
    .select(`
      *,
      instructor:profiles(full_name, avatar_url)
    `)
    .eq('is_published', true)
    .order('created_at', { ascending: false })

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Navbar />
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Cursos disponibles
          </h1>
        </div>

        {courses && courses.length > 0 ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {courses.map((course) => (
              <Link
                key={course.id}
                href={`/courses/${course.id}`}
                className="bg-white dark:bg-gray-800 rounded-xl shadow-sm hover:shadow-md transition-shadow overflow-hidden"
              >
                {course.thumbnail_url ? (
                  <img
                    src={course.thumbnail_url}
                    alt={course.title}
                    className="w-full h-48 object-cover"
                  />
                ) : (
                  <div className="w-full h-48 bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center">
                    <span className="text-white text-4xl font-bold">
                      {course.title.charAt(0)}
                    </span>
                  </div>
                )}
                <div className="p-6">
                  <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                    {course.title}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-400 text-sm line-clamp-2 mb-4">
                    {course.description}
                  </p>
                  {course.instructor && (
                    <div className="flex items-center">
                      <div className="w-8 h-8 rounded-full bg-gray-200 dark:bg-gray-700 flex items-center justify-center">
                        {course.instructor.avatar_url ? (
                          <img
                            src={course.instructor.avatar_url}
                            alt={course.instructor.full_name}
                            className="w-8 h-8 rounded-full"
                          />
                        ) : (
                          <span className="text-sm font-medium text-gray-600 dark:text-gray-400">
                            {course.instructor.full_name?.charAt(0) || 'I'}
                          </span>
                        )}
                      </div>
                      <span className="ml-2 text-sm text-gray-600 dark:text-gray-400">
                        {course.instructor.full_name || 'Instructor'}
                      </span>
                    </div>
                  )}
                </div>
              </Link>
            ))}
          </div>
        ) : (
          <div className="text-center py-12">
            <div className="text-gray-400 dark:text-gray-600 text-6xl mb-4">📚</div>
            <h3 className="text-xl font-medium text-gray-900 dark:text-white mb-2">
              No hay cursos disponibles
            </h3>
            <p className="text-gray-600 dark:text-gray-400">
              Pronto tendras nuevos cursos para explorar.
            </p>
          </div>
        )}
      </div>
    </div>
  )
}
