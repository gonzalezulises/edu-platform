'use client'

import { useState, useCallback, useEffect } from 'react'
import dynamic from 'next/dynamic'
import { useSQLite } from '@/hooks/useSQLite'
import { ExerciseShell } from './ExerciseShell'
import type { SQLExercise, ExerciseProgress } from '@/types/exercises'

// Dynamically import Monaco Editor
const Editor = dynamic(
  () => import('@monaco-editor/react').then(mod => mod.default),
  { ssr: false, loading: () => <EditorSkeleton /> }
)

function EditorSkeleton() {
  return (
    <div className="h-48 bg-gray-100 dark:bg-gray-800 animate-pulse flex items-center justify-center">
      <span className="text-gray-500">Cargando editor...</span>
    </div>
  )
}

interface SQLPlaygroundProps {
  exercise: SQLExercise
  schema?: string
  datasets?: Map<string, string>
  progress?: ExerciseProgress
  onProgressUpdate?: (progress: Partial<ExerciseProgress>) => void
  showSolution?: boolean
}

export function SQLPlayground({
  exercise,
  schema,
  datasets,
  progress,
  onProgressUpdate,
  showSolution = false
}: SQLPlaygroundProps) {
  const [query, setQuery] = useState(progress?.current_code || exercise.starter_code)
  const [showSolutionQuery, setShowSolutionQuery] = useState(false)
  const [isRunning, setIsRunning] = useState(false)
  const [resultColumns, setResultColumns] = useState<string[]>([])
  const [resultRows, setResultRows] = useState<Record<string, unknown>[]>([])
  const [error, setError] = useState<string | null>(null)
  const [executionTime, setExecutionTime] = useState<number | null>(null)
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null)

  const {
    isLoading,
    isReady,
    error: sqlError,
    runQuery: executeQuery,
    reset: resetDb
  } = useSQLite({
    schema,
    csvData: datasets
  })

  // Calculate score
  const score = isCorrect ? exercise.points : 0

  // Run query
  const handleRun = useCallback(async () => {
    setIsRunning(true)
    setError(null)
    setIsCorrect(null)

    const result = await executeQuery(query)

    if (result.success) {
      setResultColumns(result.columns)
      setResultRows(result.rows)
      setExecutionTime(result.execution_time_ms)

      // Check if result matches expected output
      if (exercise.expected_output) {
        const expectedJson = JSON.stringify(exercise.expected_output)
        const resultJson = JSON.stringify(result.rows)
        const correct = expectedJson === resultJson
        setIsCorrect(correct)

        // Update progress
        onProgressUpdate?.({
          current_code: query,
          attempts: (progress?.attempts || 0) + 1,
          score: correct ? exercise.points : 0,
          max_score: exercise.points,
          status: correct ? 'completed' : 'in_progress',
          completed_at: correct ? new Date().toISOString() : undefined,
          last_attempt_at: new Date().toISOString()
        })
      }
    } else {
      setError(result.error || 'Error desconocido')
      setResultColumns([])
      setResultRows([])
    }

    setIsRunning(false)
  }, [query, executeQuery, exercise.expected_output, exercise.points, onProgressUpdate, progress?.attempts])

  // Reset to starter code
  const handleReset = useCallback(async () => {
    setQuery(exercise.starter_code)
    setResultColumns([])
    setResultRows([])
    setError(null)
    setIsCorrect(null)
    await resetDb()
  }, [exercise.starter_code, resetDb])

  // Keyboard shortcut
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
        e.preventDefault()
        handleRun()
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [handleRun])

  return (
    <ExerciseShell
      exercise={exercise}
      score={score}
      maxScore={exercise.points}
      attempts={progress?.attempts}
      isSubmitting={isRunning}
    >
      <div className="p-4 space-y-4">
        {/* Loading state */}
        {isLoading && (
          <div className="bg-blue-50 dark:bg-blue-900/20 rounded-md p-3 flex items-center gap-3">
            <svg className="animate-spin h-5 w-5 text-blue-600" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
            </svg>
            <p className="text-sm text-blue-700 dark:text-blue-300">Cargando base de datos...</p>
          </div>
        )}

        {sqlError && (
          <div className="bg-red-50 dark:bg-red-900/20 rounded-md p-3 text-sm text-red-700 dark:text-red-300">
            Error inicializando SQLite: {sqlError.message}
          </div>
        )}

        {/* SQL Editor */}
        <div className="border border-gray-200 dark:border-gray-700 rounded-md overflow-hidden">
          <div className="bg-gray-100 dark:bg-gray-800 px-3 py-2 flex items-center justify-between border-b border-gray-200 dark:border-gray-700">
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300">SQL</span>
            <div className="flex items-center gap-2">
              <button
                onClick={handleReset}
                className="text-xs text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
              >
                Reiniciar
              </button>
              {showSolution && (
                <button
                  onClick={() => setShowSolutionQuery(!showSolutionQuery)}
                  className="text-xs text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-200"
                >
                  {showSolutionQuery ? 'Ocultar solución' : 'Ver solución'}
                </button>
              )}
            </div>
          </div>
          <Editor
            height="192px"
            language="sql"
            theme="vs-dark"
            value={showSolutionQuery ? exercise.solution_query : query}
            onChange={(value) => !showSolutionQuery && setQuery(value || '')}
            options={{
              minimap: { enabled: false },
              fontSize: 14,
              lineNumbers: 'on',
              scrollBeyondLastLine: false,
              automaticLayout: true,
              tabSize: 2,
              readOnly: showSolutionQuery
            }}
          />
        </div>

        {/* Run button */}
        <div className="flex items-center gap-3">
          <button
            onClick={handleRun}
            disabled={!isReady || isRunning}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Ejecutar Query
            <kbd className="hidden sm:inline text-xs bg-blue-700 px-1.5 py-0.5 rounded">⌘↵</kbd>
          </button>

          {executionTime !== null && (
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {executionTime}ms
            </span>
          )}
        </div>

        {/* Error display */}
        {error && (
          <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md p-3">
            <p className="text-sm text-red-700 dark:text-red-300 font-mono">{error}</p>
          </div>
        )}

        {/* Result table */}
        {resultColumns.length > 0 && (
          <div className="border border-gray-200 dark:border-gray-700 rounded-md overflow-hidden">
            <div className="bg-gray-100 dark:bg-gray-800 px-3 py-2 flex items-center justify-between border-b border-gray-200 dark:border-gray-700">
              <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
                Resultados ({resultRows.length} filas)
              </span>
              {isCorrect !== null && (
                <span className={`text-sm font-medium ${isCorrect ? 'text-green-600' : 'text-red-600'}`}>
                  {isCorrect ? 'Correcto!' : 'Incorrecto'}
                </span>
              )}
            </div>
            <div className="overflow-x-auto max-h-64">
              <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead className="bg-gray-50 dark:bg-gray-800 sticky top-0">
                  <tr>
                    {resultColumns.map((col, i) => (
                      <th
                        key={i}
                        className="px-3 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider"
                      >
                        {col}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody className="bg-white dark:bg-gray-900 divide-y divide-gray-200 dark:divide-gray-700">
                  {resultRows.slice(0, 100).map((row, rowIndex) => (
                    <tr key={rowIndex}>
                      {resultColumns.map((col, colIndex) => (
                        <td
                          key={colIndex}
                          className="px-3 py-2 whitespace-nowrap text-sm text-gray-700 dark:text-gray-300 font-mono"
                        >
                          {row[col] === null ? (
                            <span className="text-gray-400 italic">NULL</span>
                          ) : (
                            String(row[col])
                          )}
                        </td>
                      ))}
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            {resultRows.length > 100 && (
              <div className="bg-gray-50 dark:bg-gray-800 px-3 py-2 text-sm text-gray-500 border-t border-gray-200 dark:border-gray-700">
                Mostrando 100 de {resultRows.length} filas
              </div>
            )}
          </div>
        )}

        {/* Success message */}
        {isCorrect && (
          <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-md p-4 flex items-center gap-3">
            <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div>
              <p className="font-medium text-green-800 dark:text-green-200">
                Query correcta!
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
