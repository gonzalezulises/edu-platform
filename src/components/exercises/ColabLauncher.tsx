'use client'

import { useState, useCallback } from 'react'
import { ExerciseShell } from './ExerciseShell'
import type { ColabExercise, ExerciseProgress } from '@/types/exercises'

interface ColabLauncherProps {
  exercise: ColabExercise
  progress?: ExerciseProgress
  onProgressUpdate?: (progress: Partial<ExerciseProgress>) => void
}

export function ColabLauncher({
  exercise,
  progress,
  onProgressUpdate
}: ColabLauncherProps) {
  const [isCompleted, setIsCompleted] = useState(progress?.status === 'completed')

  const handleOpenColab = useCallback(() => {
    window.open(exercise.colab_url, '_blank', 'noopener,noreferrer')

    // Mark as in progress
    if (!progress || progress.status === 'not_started') {
      onProgressUpdate?.({
        status: 'in_progress',
        started_at: new Date().toISOString(),
        attempts: (progress?.attempts || 0) + 1
      })
    }
  }, [exercise.colab_url, progress, onProgressUpdate])

  const handleOpenGitHub = useCallback(() => {
    if (exercise.github_url) {
      window.open(exercise.github_url, '_blank', 'noopener,noreferrer')
    }
  }, [exercise.github_url])

  const handleMarkComplete = useCallback(() => {
    setIsCompleted(true)
    onProgressUpdate?.({
      status: 'completed',
      score: exercise.points,
      max_score: exercise.points,
      completed_at: new Date().toISOString()
    })
  }, [exercise.points, onProgressUpdate])

  const handleMarkIncomplete = useCallback(() => {
    setIsCompleted(false)
    onProgressUpdate?.({
      status: 'in_progress',
      score: 0,
      completed_at: undefined
    })
  }, [onProgressUpdate])

  return (
    <ExerciseShell
      exercise={exercise}
      score={isCompleted ? exercise.points : 0}
      maxScore={exercise.points}
      attempts={progress?.attempts}
    >
      <div className="p-6 space-y-6">
        {/* Notebook info */}
        <div className="flex items-center gap-4 p-4 bg-gradient-to-r from-orange-50 to-yellow-50 dark:from-orange-900/20 dark:to-yellow-900/20 rounded-lg border border-orange-200 dark:border-orange-800">
          <div className="flex-shrink-0">
            <svg className="w-12 h-12 text-orange-500" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0C5.372 0 0 5.372 0 12s5.372 12 12 12 12-5.372 12-12S18.628 0 12 0zm-.5 3.5a.5.5 0 01.5-.5h.5a.5.5 0 01.5.5v1a.5.5 0 01-.5.5h-.5a.5.5 0 01-.5-.5v-1zm-2.207 2.793a.5.5 0 01.707 0l.354.354a.5.5 0 010 .707l-.354.353a.5.5 0 01-.707 0l-.353-.353a.5.5 0 010-.707l.353-.354zM6 11.5a.5.5 0 01.5-.5h1a.5.5 0 01.5.5v.5a.5.5 0 01-.5.5h-1a.5.5 0 01-.5-.5v-.5zm1.293 3.793a.5.5 0 01.707 0l.354.354a.5.5 0 010 .707l-.354.353a.5.5 0 01-.707 0l-.353-.353a.5.5 0 010-.707l.353-.354zM12 16a.5.5 0 01.5.5v1a.5.5 0 01-.5.5h-.5a.5.5 0 01-.5-.5v-1a.5.5 0 01.5-.5h.5zm2.207-2.793a.5.5 0 01.707 0l.354.354a.5.5 0 010 .707l-.354.353a.5.5 0 01-.707 0l-.353-.353a.5.5 0 010-.707l.353-.354zM16.5 12a.5.5 0 01-.5.5h-1a.5.5 0 01-.5-.5v-.5a.5.5 0 01.5-.5h1a.5.5 0 01.5.5v.5zm-1.793-4.207a.5.5 0 01-.707 0l-.354-.354a.5.5 0 010-.707l.354-.353a.5.5 0 01.707 0l.353.353a.5.5 0 010 .707l-.353.354zM12 7a5 5 0 100 10 5 5 0 000-10z"/>
            </svg>
          </div>
          <div className="flex-1">
            <h3 className="font-semibold text-orange-800 dark:text-orange-200">
              {exercise.notebook_name}
            </h3>
            <p className="text-sm text-orange-600 dark:text-orange-400">
              Google Colaboratory Notebook
            </p>
          </div>
        </div>

        {/* Description */}
        <div className="prose prose-sm dark:prose-invert max-w-none">
          <p>{exercise.description}</p>
        </div>

        {/* Completion criteria */}
        <div className="p-4 bg-blue-50 dark:bg-blue-900/20 rounded-lg border border-blue-200 dark:border-blue-800">
          <h4 className="font-medium text-blue-800 dark:text-blue-200 mb-2 flex items-center gap-2">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" />
            </svg>
            Criterios de completado
          </h4>
          <p className="text-sm text-blue-700 dark:text-blue-300">
            {exercise.completion_criteria}
          </p>
        </div>

        {/* Action buttons */}
        <div className="flex flex-wrap items-center gap-3">
          <button
            onClick={handleOpenColab}
            className="flex items-center gap-2 px-6 py-3 bg-orange-500 text-white rounded-lg hover:bg-orange-600 transition-colors font-medium shadow-sm"
          >
            <svg className="w-5 h-5" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 0C5.372 0 0 5.372 0 12s5.372 12 12 12 12-5.372 12-12S18.628 0 12 0zm0 3a9 9 0 110 18 9 9 0 010-18zm0 4a5 5 0 100 10 5 5 0 000-10z"/>
            </svg>
            Abrir en Google Colab
          </button>

          {exercise.github_url && (
            <button
              onClick={handleOpenGitHub}
              className="flex items-center gap-2 px-4 py-3 bg-gray-800 dark:bg-gray-700 text-white rounded-lg hover:bg-gray-900 dark:hover:bg-gray-600 transition-colors"
            >
              <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path fillRule="evenodd" clipRule="evenodd" d="M12 2C6.477 2 2 6.477 2 12c0 4.42 2.865 8.166 6.839 9.489.5.092.682-.217.682-.482 0-.237-.009-.866-.013-1.7-2.782.603-3.369-1.342-3.369-1.342-.454-1.155-1.11-1.462-1.11-1.462-.908-.62.069-.608.069-.608 1.003.07 1.531 1.03 1.531 1.03.892 1.529 2.341 1.087 2.91.831.092-.646.35-1.086.636-1.336-2.22-.253-4.555-1.11-4.555-4.943 0-1.091.39-1.984 1.029-2.683-.103-.253-.446-1.27.098-2.647 0 0 .84-.269 2.75 1.025A9.578 9.578 0 0112 6.836c.85.004 1.705.114 2.504.336 1.909-1.294 2.747-1.025 2.747-1.025.546 1.377.203 2.394.1 2.647.64.699 1.028 1.592 1.028 2.683 0 3.842-2.339 4.687-4.566 4.935.359.309.678.919.678 1.852 0 1.336-.012 2.415-.012 2.743 0 .267.18.578.688.48C19.138 20.163 22 16.418 22 12c0-5.523-4.477-10-10-10z"/>
              </svg>
              Ver en GitHub
            </button>
          )}
        </div>

        {/* Manual completion */}
        {exercise.manual_completion && (
          <div className="border-t border-gray-200 dark:border-gray-700 pt-4 mt-4">
            <p className="text-sm text-gray-600 dark:text-gray-400 mb-3">
              Una vez que hayas completado el notebook, marca tu progreso:
            </p>
            {isCompleted ? (
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2 text-green-600 dark:text-green-400">
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                  <span className="font-medium">Completado</span>
                </div>
                <button
                  onClick={handleMarkIncomplete}
                  className="text-sm text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200 underline"
                >
                  Desmarcar
                </button>
              </div>
            ) : (
              <button
                onClick={handleMarkComplete}
                className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 transition-colors"
              >
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                </svg>
                Marcar como completado
              </button>
            )}
          </div>
        )}

        {/* Success state */}
        {isCompleted && (
          <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-md p-4 flex items-center gap-3">
            <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div>
              <p className="font-medium text-green-800 dark:text-green-200">
                Ejercicio completado!
              </p>
              <p className="text-sm text-green-600 dark:text-green-400">
                Has obtenido {exercise.points} puntos.
              </p>
            </div>
          </div>
        )}
      </div>
    </ExerciseShell>
  )
}
