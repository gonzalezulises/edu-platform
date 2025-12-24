'use client'

import { useEffect, useState } from 'react'
import { CodePlayground } from './CodePlayground'
import { SQLPlayground } from './SQLPlayground'
import { ColabLauncher } from './ColabLauncher'
import type {
  Exercise as ExerciseType,
  ExerciseProgress,
  LoadedExercise
} from '@/types/exercises'

interface ExerciseProps {
  exerciseId: string
  courseSlug?: string
  moduleId?: string
  exercise?: ExerciseType
  loadedExercise?: LoadedExercise
  progress?: ExerciseProgress
  onProgressUpdate?: (progress: Partial<ExerciseProgress>) => void
  showSolution?: boolean
}

// Loading skeleton for exercise
function ExerciseSkeleton() {
  return (
    <div className="my-8 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 overflow-hidden animate-pulse">
      <div className="bg-gray-50 dark:bg-gray-900 px-4 py-3 border-b border-gray-200 dark:border-gray-700">
        <div className="h-6 w-48 bg-gray-200 dark:bg-gray-700 rounded"></div>
      </div>
      <div className="p-4 space-y-4">
        <div className="h-4 w-full bg-gray-200 dark:bg-gray-700 rounded"></div>
        <div className="h-4 w-3/4 bg-gray-200 dark:bg-gray-700 rounded"></div>
        <div className="h-48 bg-gray-200 dark:bg-gray-700 rounded"></div>
      </div>
    </div>
  )
}

// Error display
function ExerciseError({ error, exerciseId }: { error: string; exerciseId: string }) {
  return (
    <div className="my-8 rounded-lg border border-red-200 dark:border-red-800 bg-red-50 dark:bg-red-900/20 p-4">
      <div className="flex items-center gap-2 text-red-700 dark:text-red-300">
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
        </svg>
        <span className="font-medium">Error cargando ejercicio</span>
      </div>
      <p className="mt-2 text-sm text-red-600 dark:text-red-400">
        {error}
      </p>
      <p className="mt-1 text-xs text-red-500 dark:text-red-500">
        ID: {exerciseId}
      </p>
    </div>
  )
}

export function Exercise({
  exerciseId,
  courseSlug,
  moduleId,
  exercise: providedExercise,
  loadedExercise,
  progress,
  onProgressUpdate,
  showSolution = false
}: ExerciseProps) {
  const [exercise, setExercise] = useState<ExerciseType | null>(providedExercise || loadedExercise?.exercise || null)
  const [datasets, setDatasets] = useState<Map<string, string>>(loadedExercise?.datasets || new Map())
  const [schema, setSchema] = useState<string | undefined>(loadedExercise?.schema)
  const [isLoading, setIsLoading] = useState(!exercise)
  const [error, setError] = useState<string | null>(null)

  // Load exercise data if not provided
  useEffect(() => {
    if (exercise) return

    async function loadExercise() {
      if (!courseSlug || !moduleId) {
        setError('Missing course or module information')
        setIsLoading(false)
        return
      }

      try {
        // In a real app, this would be an API call
        const response = await fetch(`/api/exercises/${exerciseId}?course=${courseSlug}&module=${moduleId}`)

        if (!response.ok) {
          throw new Error(`Failed to load exercise: ${response.statusText}`)
        }

        const data = await response.json()
        setExercise(data.exercise)
        setDatasets(new Map(Object.entries(data.datasets || {})))
        setSchema(data.schema)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      } finally {
        setIsLoading(false)
      }
    }

    loadExercise()
  }, [exerciseId, courseSlug, moduleId, exercise])

  if (isLoading) {
    return <ExerciseSkeleton />
  }

  if (error || !exercise) {
    return <ExerciseError error={error || 'Exercise not found'} exerciseId={exerciseId} />
  }

  // Render the appropriate playground based on exercise type
  switch (exercise.type) {
    case 'code-python':
      return (
        <CodePlayground
          exercise={exercise}
          progress={progress}
          onProgressUpdate={onProgressUpdate}
          showSolution={showSolution}
        />
      )

    case 'sql':
      return (
        <SQLPlayground
          exercise={exercise}
          schema={schema}
          datasets={datasets}
          progress={progress}
          onProgressUpdate={onProgressUpdate}
          showSolution={showSolution}
        />
      )

    case 'colab':
      return (
        <ColabLauncher
          exercise={exercise}
          progress={progress}
          onProgressUpdate={onProgressUpdate}
        />
      )

    case 'quiz':
      // Quiz exercises would be handled by a QuizPlayground component
      // For now, show a placeholder
      return (
        <div className="my-8 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 p-4">
          <p className="text-gray-600 dark:text-gray-400">
            Quiz exercise: {exercise.title}
          </p>
          <p className="text-sm text-gray-500 mt-1">
            (Quiz component coming soon)
          </p>
        </div>
      )

    default:
      return (
        <ExerciseError
          error={`Unknown exercise type: ${(exercise as { type: string }).type}`}
          exerciseId={exerciseId}
        />
      )
  }
}
