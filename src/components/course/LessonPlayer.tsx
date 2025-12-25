'use client'

import { useState, useEffect, useRef } from 'react'
import Link from 'next/link'
import { createClient } from '@/lib/supabase/client'
import { MarkdownRenderer } from '@/components/course/MarkdownRenderer'
import { VideoPlayer } from '@/components/course/VideoPlayer'
import type { LessonFull, Quiz } from '@/types'

interface LessonPlayerProps {
  lesson: LessonFull
  userId?: string
  courseId?: string
  courseSlug?: string
  isCompleted?: boolean
  onComplete?: () => void
  quiz?: Quiz | null
}

export default function LessonPlayer({
  lesson,
  userId,
  courseId,
  courseSlug = 'python-data-science',
  isCompleted = false,
  onComplete,
  quiz
}: LessonPlayerProps) {
  const [completed, setCompleted] = useState(isCompleted)
  const [loading, setLoading] = useState(false)
  const [timeSpent, setTimeSpent] = useState(0)
  const startTimeRef = useRef<number>(0)
  const supabase = createClient()

  // Track time spent on lesson
  useEffect(() => {
    if (!userId || !courseId) return

    const now = Date.now()
    startTimeRef.current = now

    // Update course_progress.last_accessed_at and current_lesson_id
    const updateAccess = async () => {
      await supabase.from('course_progress').upsert({
        user_id: userId,
        course_id: courseId,
        current_lesson_id: lesson.id,
        last_accessed_at: new Date().toISOString()
      }, {
        onConflict: 'user_id,course_id'
      })
    }
    updateAccess()

    // Track time every 30 seconds
    const interval = setInterval(() => {
      const elapsed = Math.floor((Date.now() - startTimeRef.current) / 1000)
      setTimeSpent(elapsed)
    }, 30000)

    // Save time on unmount
    return () => {
      clearInterval(interval)
      const totalTime = Math.floor((Date.now() - startTimeRef.current) / 1000)
      if (totalTime > 10) {
        // Only save if more than 10 seconds
        supabase.from('course_progress').upsert({
          user_id: userId,
          course_id: courseId,
          total_time_spent: totalTime,
          last_accessed_at: new Date().toISOString()
        }, {
          onConflict: 'user_id,course_id'
        })
      }
    }
  }, [userId, courseId, lesson.id, supabase])

  const handleMarkComplete = async () => {
    if (!userId || completed) return

    setLoading(true)

    const { error } = await supabase.from('progress').upsert({
      user_id: userId,
      lesson_id: lesson.id,
      completed: true,
      completed_at: new Date().toISOString(),
      time_spent: Math.floor((Date.now() - startTimeRef.current) / 1000)
    }, {
      onConflict: 'user_id,lesson_id'
    })

    if (!error) {
      setCompleted(true)
      onComplete?.()
    }

    setLoading(false)
  }

  const renderContent = () => {
    switch (lesson.lesson_type) {
      case 'video':
        return (
          <div className="mb-6">
            {lesson.video_url ? (
              <VideoPlayer url={lesson.video_url} />
            ) : (
              <div className="aspect-video bg-black rounded-xl overflow-hidden flex items-center justify-center text-gray-400">
                <div className="text-center">
                  <span className="text-6xl block mb-4">🎬</span>
                  <p>Video no disponible</p>
                </div>
              </div>
            )}
          </div>
        )

      case 'text':
        return (
          <div className="mb-6">
            {lesson.parsedContent ? (
              <MarkdownRenderer
                content={lesson.parsedContent}
                courseSlug={courseSlug}
                moduleId="module-01"
              />
            ) : lesson.content ? (
              <MarkdownRenderer
                content={lesson.content}
                courseSlug={courseSlug}
                moduleId="module-01"
              />
            ) : (
              <p className="text-gray-500">Sin contenido disponible.</p>
            )}
          </div>
        )

      case 'quiz':
        return (
          <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-8 text-center mb-6">
            <span className="text-5xl block mb-4">❓</span>
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
              {quiz?.title || 'Quiz disponible'}
            </h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              {quiz?.description || 'Esta leccion incluye un quiz de evaluacion.'}
            </p>
            {quiz && courseId ? (
              <Link
                href={`/courses/${courseId}/quiz/${quiz.id}`}
                className="inline-block px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
              >
                Comenzar Quiz
              </Link>
            ) : (
              <p className="text-gray-500">Quiz no configurado</p>
            )}
          </div>
        )

      case 'assignment':
        return (
          <div className="bg-purple-50 dark:bg-purple-900/20 border border-purple-200 dark:border-purple-800 rounded-xl p-8 text-center mb-6">
            <span className="text-5xl block mb-4">📝</span>
            <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">
              Tarea por entregar
            </h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              {lesson.content || 'Completa la tarea asignada para esta leccion.'}
            </p>
            <button className="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700">
              Subir Entrega
            </button>
          </div>
        )

      default:
        return null
    }
  }

  const formatTime = (seconds: number) => {
    if (seconds < 60) return `${seconds}s`
    const mins = Math.floor(seconds / 60)
    return `${mins}m ${seconds % 60}s`
  }

  return (
    <div>
      {/* Lesson header */}
      <div className="mb-6">
        <div className="flex items-center gap-3 mb-2">
          <span className="text-2xl">
            {lesson.lesson_type === 'video' && '🎬'}
            {lesson.lesson_type === 'text' && '📄'}
            {lesson.lesson_type === 'quiz' && '❓'}
            {lesson.lesson_type === 'assignment' && '📝'}
          </span>
          <h1 className="text-2xl lg:text-3xl font-bold text-gray-900 dark:text-white">
            {lesson.title}
          </h1>
        </div>
        <div className="flex items-center gap-4 text-gray-500 dark:text-gray-400">
          {lesson.duration_minutes && (
            <span>Duracion: {lesson.duration_minutes} minutos</span>
          )}
          {timeSpent > 0 && (
            <span className="text-sm">Tiempo en leccion: {formatTime(timeSpent)}</span>
          )}
        </div>
      </div>

      {/* Main content */}
      {renderContent()}

      {/* Text content below video if exists */}
      {lesson.lesson_type === 'video' && (lesson.parsedContent || lesson.content) && (
        <div className="mb-6">
          <h3 className="text-xl font-semibold text-gray-900 dark:text-white mb-4">Notas de la leccion</h3>
          <MarkdownRenderer
            content={lesson.parsedContent || lesson.content || ''}
            courseSlug={courseSlug}
            moduleId="module-01"
          />
        </div>
      )}

      {/* Quiz section for non-quiz lessons that have an associated quiz */}
      {lesson.lesson_type !== 'quiz' && quiz && courseId && (
        <div className="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-xl p-6 mb-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <span className="text-4xl">❓</span>
              <div>
                <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                  {quiz.title}
                </h3>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  {quiz.description || 'Evalua tu comprension del tema'}
                </p>
              </div>
            </div>
            <Link
              href={`/courses/${courseId}/quiz/${quiz.id}`}
              className="px-5 py-2 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 transition-colors"
            >
              Tomar Quiz
            </Link>
          </div>
        </div>
      )}

      {/* Complete button */}
      {userId && (
        <div className="flex items-center justify-between pt-6 border-t border-gray-200 dark:border-gray-700">
          {completed ? (
            <div className="flex items-center gap-2 text-green-600 dark:text-green-400">
              <span className="text-2xl">✓</span>
              <span className="font-medium">Leccion completada</span>
            </div>
          ) : (
            <button
              onClick={handleMarkComplete}
              disabled={loading}
              className="px-6 py-3 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 disabled:opacity-50 transition-colors"
            >
              {loading ? 'Guardando...' : 'Marcar como completada'}
            </button>
          )}
        </div>
      )}
    </div>
  )
}
