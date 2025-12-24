'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import type { Course, Profile } from '@/types'
import Navbar from '@/components/Navbar'

export default function AdminCoursesPage() {
  const [courses, setCourses] = useState<Course[]>([])
  const [user, setUser] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [saving, setSaving] = useState(false)
  const supabase = createClient()
  const router = useRouter()

  useEffect(() => {
    const init = async () => {
      const { data: { user: authUser } } = await supabase.auth.getUser()

      if (!authUser) {
        router.push('/login')
        return
      }

      const { data: profile } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', authUser.id)
        .single()

      if (!profile || (profile.role !== 'admin' && profile.role !== 'instructor')) {
        router.push('/courses')
        return
      }

      setUser(profile)

      const { data: coursesData } = await supabase
        .from('courses')
        .select('*')
        .eq('instructor_id', authUser.id)
        .order('created_at', { ascending: false })

      setCourses(coursesData || [])
      setLoading(false)
    }

    init()
  }, [supabase, router])

  const handleCreateCourse = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!user) return

    setSaving(true)

    const { data, error } = await supabase
      .from('courses')
      .insert({
        title,
        description,
        instructor_id: user.id,
        is_published: false,
      })
      .select()
      .single()

    if (error) {
      alert('Error creando curso: ' + error.message)
      setSaving(false)
      return
    }

    setCourses([data, ...courses])
    setTitle('')
    setDescription('')
    setShowForm(false)
    setSaving(false)
  }

  const handlePublish = async (courseId: string, publish: boolean) => {
    const { error } = await supabase
      .from('courses')
      .update({ is_published: publish })
      .eq('id', courseId)

    if (!error) {
      setCourses(courses.map(c =>
        c.id === courseId ? { ...c, is_published: publish } : c
      ))
    }
  }

  const handleDelete = async (courseId: string) => {
    if (!confirm('¿Eliminar este curso?')) return

    const { error } = await supabase
      .from('courses')
      .delete()
      .eq('id', courseId)

    if (!error) {
      setCourses(courses.filter(c => c.id !== courseId))
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
        <Navbar />
        <div className="flex items-center justify-center h-64">
          <div className="text-gray-500">Cargando...</div>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <Navbar />
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="flex justify-between items-center mb-8">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Administrar Cursos
          </h1>
          <button
            onClick={() => setShowForm(!showForm)}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
          >
            {showForm ? 'Cancelar' : '+ Nuevo Curso'}
          </button>
        </div>

        {showForm && (
          <form onSubmit={handleCreateCourse} className="bg-white dark:bg-gray-800 rounded-xl p-6 mb-8 shadow-sm">
            <h2 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">
              Crear nuevo curso
            </h2>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Titulo del curso
                </label>
                <input
                  type="text"
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  required
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg dark:bg-gray-700 dark:text-white"
                  placeholder="Ej: Introduccion a React"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Descripcion
                </label>
                <textarea
                  value={description}
                  onChange={(e) => setDescription(e.target.value)}
                  rows={3}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-700 rounded-lg dark:bg-gray-700 dark:text-white"
                  placeholder="Describe el contenido del curso..."
                />
              </div>
              <button
                type="submit"
                disabled={saving}
                className="px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
              >
                {saving ? 'Guardando...' : 'Crear Curso'}
              </button>
            </div>
          </form>
        )}

        {courses.length > 0 ? (
          <div className="space-y-4">
            {courses.map((course) => (
              <div
                key={course.id}
                className="bg-white dark:bg-gray-800 rounded-xl p-6 shadow-sm flex justify-between items-center"
              >
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                    {course.title}
                  </h3>
                  <p className="text-gray-600 dark:text-gray-400 text-sm mt-1">
                    {course.description || 'Sin descripcion'}
                  </p>
                  <span className={`inline-block mt-2 text-xs px-2 py-1 rounded-full ${
                    course.is_published
                      ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400'
                      : 'bg-yellow-100 text-yellow-700 dark:bg-yellow-900/30 dark:text-yellow-400'
                  }`}>
                    {course.is_published ? 'Publicado' : 'Borrador'}
                  </span>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => handlePublish(course.id, !course.is_published)}
                    className={`px-3 py-1 rounded-lg text-sm ${
                      course.is_published
                        ? 'bg-yellow-100 text-yellow-700 hover:bg-yellow-200'
                        : 'bg-green-100 text-green-700 hover:bg-green-200'
                    }`}
                  >
                    {course.is_published ? 'Despublicar' : 'Publicar'}
                  </button>
                  <button
                    onClick={() => handleDelete(course.id)}
                    className="px-3 py-1 bg-red-100 text-red-700 rounded-lg text-sm hover:bg-red-200"
                  >
                    Eliminar
                  </button>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-12 bg-white dark:bg-gray-800 rounded-xl">
            <div className="text-4xl mb-4">📝</div>
            <p className="text-gray-600 dark:text-gray-400">
              No tienes cursos aun. Crea tu primer curso!
            </p>
          </div>
        )}
      </div>
    </div>
  )
}
