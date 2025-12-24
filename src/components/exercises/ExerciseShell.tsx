'use client'

import { useState } from 'react'
import type { BaseExercise, DifficultyLevel } from '@/types/exercises'

interface ExerciseShellProps {
  exercise: BaseExercise
  children: React.ReactNode
  score?: number
  maxScore?: number
  attempts?: number
  isSubmitting?: boolean
}

const difficultyColors: Record<DifficultyLevel, string> = {
  beginner: 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200',
  intermediate: 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200',
  advanced: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
}

const difficultyLabels: Record<DifficultyLevel, string> = {
  beginner: 'Principiante',
  intermediate: 'Intermedio',
  advanced: 'Avanzado'
}

export function ExerciseShell({
  exercise,
  children,
  score,
  maxScore,
  attempts = 0,
  isSubmitting = false
}: ExerciseShellProps) {
  const [showHints, setShowHints] = useState(false)
  const [currentHintIndex, setCurrentHintIndex] = useState(0)

  const hasHints = exercise.hints && exercise.hints.length > 0
  const scorePercentage = maxScore ? Math.round((score || 0) / maxScore * 100) : 0

  return (
    <div className="my-8 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 shadow-sm overflow-hidden">
      {/* Header */}
      <div className="border-b border-gray-200 dark:border-gray-700 bg-gray-50 dark:bg-gray-900 px-4 py-3">
        <div className="flex items-center justify-between flex-wrap gap-2">
          <div className="flex items-center gap-3">
            <span className="text-lg font-semibold text-gray-900 dark:text-white">
              {exercise.title}
            </span>
            <span className={`px-2 py-0.5 text-xs font-medium rounded ${difficultyColors[exercise.difficulty]}`}>
              {difficultyLabels[exercise.difficulty]}
            </span>
          </div>

          <div className="flex items-center gap-4 text-sm text-gray-600 dark:text-gray-400">
            <span className="flex items-center gap-1">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
              </svg>
              ~{exercise.estimated_time_minutes} min
            </span>
            <span className="flex items-center gap-1">
              <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" />
              </svg>
              {exercise.points} pts
            </span>
            {attempts > 0 && (
              <span className="flex items-center gap-1">
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
                </svg>
                {attempts} intentos
              </span>
            )}
          </div>
        </div>

        {/* Progress bar if score exists */}
        {maxScore !== undefined && score !== undefined && (
          <div className="mt-3">
            <div className="flex items-center justify-between text-xs mb-1">
              <span className="text-gray-600 dark:text-gray-400">Progreso</span>
              <span className="font-medium text-gray-900 dark:text-white">{score}/{maxScore} pts ({scorePercentage}%)</span>
            </div>
            <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
              <div
                className={`h-2 rounded-full transition-all duration-300 ${
                  scorePercentage === 100
                    ? 'bg-green-500'
                    : scorePercentage > 0
                    ? 'bg-blue-500'
                    : 'bg-gray-300'
                }`}
                style={{ width: `${scorePercentage}%` }}
              />
            </div>
          </div>
        )}
      </div>

      {/* Instructions */}
      <div className="px-4 py-3 bg-blue-50 dark:bg-blue-900/20 border-b border-gray-200 dark:border-gray-700">
        <h4 className="text-sm font-medium text-blue-800 dark:text-blue-200 mb-1">Instrucciones</h4>
        <p className="text-sm text-blue-700 dark:text-blue-300">{exercise.instructions}</p>
      </div>

      {/* Main content (playground) */}
      <div className="relative">
        {isSubmitting && (
          <div className="absolute inset-0 bg-white/50 dark:bg-gray-800/50 flex items-center justify-center z-10">
            <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
              <svg className="animate-spin h-5 w-5" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
              </svg>
              Ejecutando...
            </div>
          </div>
        )}
        {children}
      </div>

      {/* Hints section */}
      {hasHints && (
        <div className="border-t border-gray-200 dark:border-gray-700 px-4 py-3">
          <button
            onClick={() => setShowHints(!showHints)}
            className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-white transition-colors"
          >
            <svg className={`w-4 h-4 transition-transform ${showHints ? 'rotate-90' : ''}`} fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
            </svg>
            {showHints ? 'Ocultar pistas' : `Ver pistas (${exercise.hints!.length} disponibles)`}
          </button>

          {showHints && exercise.hints && (
            <div className="mt-3 space-y-2">
              {exercise.hints.slice(0, currentHintIndex + 1).map((hint, index) => (
                <div
                  key={index}
                  className="p-3 bg-yellow-50 dark:bg-yellow-900/20 rounded-md border border-yellow-200 dark:border-yellow-800"
                >
                  <div className="flex items-start gap-2">
                    <span className="text-yellow-600 dark:text-yellow-400 font-medium text-sm">
                      Pista {index + 1}:
                    </span>
                    <span className="text-sm text-yellow-700 dark:text-yellow-300">{hint}</span>
                  </div>
                </div>
              ))}

              {currentHintIndex < exercise.hints.length - 1 && (
                <button
                  onClick={() => setCurrentHintIndex(prev => prev + 1)}
                  className="text-sm text-yellow-600 dark:text-yellow-400 hover:text-yellow-800 dark:hover:text-yellow-200 underline"
                >
                  Mostrar siguiente pista
                </button>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
