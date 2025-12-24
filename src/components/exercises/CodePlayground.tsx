'use client'

import { useState, useCallback, useEffect } from 'react'
import dynamic from 'next/dynamic'
import { usePyodide } from '@/hooks/usePyodide'
import { ExerciseShell } from './ExerciseShell'
import type { CodeExercise, TestResult, ExerciseProgress } from '@/types/exercises'

// Dynamically import Monaco Editor (client-side only)
const Editor = dynamic(
  () => import('@monaco-editor/react').then(mod => mod.default),
  { ssr: false, loading: () => <EditorSkeleton /> }
)

function EditorSkeleton() {
  return (
    <div className="h-64 bg-gray-100 dark:bg-gray-800 animate-pulse flex items-center justify-center">
      <span className="text-gray-500">Cargando editor...</span>
    </div>
  )
}

interface CodePlaygroundProps {
  exercise: CodeExercise
  progress?: ExerciseProgress
  onProgressUpdate?: (progress: Partial<ExerciseProgress>) => void
  showSolution?: boolean
}

export function CodePlayground({
  exercise,
  progress,
  onProgressUpdate,
  showSolution = false
}: CodePlaygroundProps) {
  const [code, setCode] = useState(progress?.current_code || exercise.starter_code)
  const [output, setOutput] = useState('')
  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [isRunning, setIsRunning] = useState(false)
  const [activeTab, setActiveTab] = useState<'output' | 'tests'>('output')
  const [showSolutionCode, setShowSolutionCode] = useState(false)

  const {
    isLoading: pyodideLoading,
    isReady: pyodideReady,
    loadProgress,
    runCode,
    runTests,
    error: pyodideError
  } = usePyodide({
    packages: exercise.required_packages || ['numpy', 'pandas']
  })

  // Calculate score from test results
  const score = testResults.reduce((sum, r) => sum + r.points_earned, 0)
  const maxScore = exercise.test_cases.reduce((sum, t) => sum + t.points, 0)
  const allTestsPassed = testResults.length > 0 && testResults.every(r => r.passed)

  // Handle code execution (run only)
  const handleRun = useCallback(async () => {
    setIsRunning(true)
    setOutput('')
    setTestResults([])
    setActiveTab('output')

    const result = await runCode(code)

    if (result.success) {
      setOutput(result.stdout || 'Ejecutado correctamente (sin output)')
    } else {
      setOutput(`Error: ${result.error}\n\n${result.stderr}`)
    }

    setIsRunning(false)
  }, [code, runCode])

  // Handle code submission (run + tests)
  const handleSubmit = useCallback(async () => {
    setIsRunning(true)
    setOutput('')
    setTestResults([])
    setActiveTab('tests')

    const result = await runTests(code, exercise.test_cases)

    if (result.stdout || result.stderr) {
      setOutput(result.stdout + (result.stderr ? `\n\nStderr: ${result.stderr}` : ''))
    }

    if (result.error) {
      setOutput(`Error: ${result.error}`)
    }

    if (result.test_results) {
      setTestResults(result.test_results)

      // Update progress
      const newScore = result.test_results.reduce((sum, r) => sum + r.points_earned, 0)
      onProgressUpdate?.({
        current_code: code,
        attempts: (progress?.attempts || 0) + 1,
        score: newScore,
        max_score: maxScore,
        test_results: result.test_results,
        status: result.success ? 'completed' : 'in_progress',
        completed_at: result.success ? new Date().toISOString() : undefined,
        last_attempt_at: new Date().toISOString()
      })
    }

    setIsRunning(false)
  }, [code, exercise.test_cases, runTests, onProgressUpdate, progress?.attempts, maxScore])

  // Reset code to starter
  const handleReset = useCallback(() => {
    setCode(exercise.starter_code)
    setOutput('')
    setTestResults([])
  }, [exercise.starter_code])

  // Keyboard shortcut for running
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'Enter') {
        e.preventDefault()
        handleRun()
      }
      if ((e.metaKey || e.ctrlKey) && e.shiftKey && e.key === 'Enter') {
        e.preventDefault()
        handleSubmit()
      }
    }

    window.addEventListener('keydown', handleKeyDown)
    return () => window.removeEventListener('keydown', handleKeyDown)
  }, [handleRun, handleSubmit])

  return (
    <ExerciseShell
      exercise={exercise}
      score={score}
      maxScore={maxScore}
      attempts={progress?.attempts}
      isSubmitting={isRunning}
    >
      <div className="p-4 space-y-4">
        {/* Pyodide loading state */}
        {pyodideLoading && (
          <div className="bg-blue-50 dark:bg-blue-900/20 rounded-md p-3 flex items-center gap-3">
            <div className="flex-shrink-0">
              <svg className="animate-spin h-5 w-5 text-blue-600" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z" />
              </svg>
            </div>
            <div className="flex-1">
              <p className="text-sm text-blue-700 dark:text-blue-300">
                Cargando Python... {loadProgress}%
              </p>
              <div className="mt-1 w-full bg-blue-200 dark:bg-blue-800 rounded-full h-1.5">
                <div
                  className="bg-blue-600 h-1.5 rounded-full transition-all duration-300"
                  style={{ width: `${loadProgress}%` }}
                />
              </div>
            </div>
          </div>
        )}

        {pyodideError && (
          <div className="bg-red-50 dark:bg-red-900/20 rounded-md p-3 text-sm text-red-700 dark:text-red-300">
            Error cargando Python: {pyodideError.message}
          </div>
        )}

        {/* Code Editor */}
        <div className="border border-gray-200 dark:border-gray-700 rounded-md overflow-hidden">
          <div className="bg-gray-100 dark:bg-gray-800 px-3 py-2 flex items-center justify-between border-b border-gray-200 dark:border-gray-700">
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
              Python
            </span>
            <div className="flex items-center gap-2">
              <button
                onClick={handleReset}
                className="text-xs text-gray-500 hover:text-gray-700 dark:text-gray-400 dark:hover:text-gray-200"
              >
                Reiniciar
              </button>
              {showSolution && (
                <button
                  onClick={() => setShowSolutionCode(!showSolutionCode)}
                  className="text-xs text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-200"
                >
                  {showSolutionCode ? 'Ocultar solución' : 'Ver solución'}
                </button>
              )}
            </div>
          </div>
          <Editor
            height="256px"
            language="python"
            theme="vs-dark"
            value={showSolutionCode ? exercise.solution_code : code}
            onChange={(value) => !showSolutionCode && setCode(value || '')}
            options={{
              minimap: { enabled: false },
              fontSize: 14,
              lineNumbers: 'on',
              scrollBeyondLastLine: false,
              automaticLayout: true,
              tabSize: 4,
              readOnly: showSolutionCode
            }}
          />
        </div>

        {/* Action buttons */}
        <div className="flex items-center gap-3">
          <button
            onClick={handleRun}
            disabled={!pyodideReady || isRunning}
            className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z" />
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Ejecutar
            <kbd className="hidden sm:inline text-xs bg-gray-700 px-1.5 py-0.5 rounded">⌘↵</kbd>
          </button>
          <button
            onClick={handleSubmit}
            disabled={!pyodideReady || isRunning}
            className="flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-md hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            Enviar
            <kbd className="hidden sm:inline text-xs bg-green-700 px-1.5 py-0.5 rounded">⇧⌘↵</kbd>
          </button>
        </div>

        {/* Output / Tests tabs */}
        <div className="border border-gray-200 dark:border-gray-700 rounded-md overflow-hidden">
          <div className="flex border-b border-gray-200 dark:border-gray-700">
            <button
              onClick={() => setActiveTab('output')}
              className={`px-4 py-2 text-sm font-medium ${
                activeTab === 'output'
                  ? 'bg-white dark:bg-gray-800 text-gray-900 dark:text-white border-b-2 border-blue-500'
                  : 'bg-gray-50 dark:bg-gray-900 text-gray-500 dark:text-gray-400 hover:text-gray-700'
              }`}
            >
              Output
            </button>
            <button
              onClick={() => setActiveTab('tests')}
              className={`px-4 py-2 text-sm font-medium flex items-center gap-2 ${
                activeTab === 'tests'
                  ? 'bg-white dark:bg-gray-800 text-gray-900 dark:text-white border-b-2 border-blue-500'
                  : 'bg-gray-50 dark:bg-gray-900 text-gray-500 dark:text-gray-400 hover:text-gray-700'
              }`}
            >
              Tests
              {testResults.length > 0 && (
                <span className={`text-xs px-1.5 py-0.5 rounded ${
                  allTestsPassed
                    ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                    : 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
                }`}>
                  {testResults.filter(r => r.passed).length}/{testResults.length}
                </span>
              )}
            </button>
          </div>

          <div className="p-4 bg-gray-50 dark:bg-gray-900 min-h-[120px]">
            {activeTab === 'output' ? (
              <pre className="text-sm text-gray-700 dark:text-gray-300 whitespace-pre-wrap font-mono">
                {output || 'Ejecuta el código para ver el output...'}
              </pre>
            ) : (
              <div className="space-y-2">
                {testResults.length === 0 ? (
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    Envía tu código para ejecutar los tests...
                  </p>
                ) : (
                  testResults.map((result, index) => {
                    const testCase = exercise.test_cases.find(t => t.id === result.test_id)
                    return (
                      <div
                        key={result.test_id}
                        className={`flex items-center justify-between p-3 rounded-md ${
                          result.passed
                            ? 'bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800'
                            : 'bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800'
                        }`}
                      >
                        <div className="flex items-center gap-2">
                          {result.passed ? (
                            <svg className="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                            </svg>
                          ) : (
                            <svg className="w-5 h-5 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                            </svg>
                          )}
                          <span className={`text-sm font-medium ${
                            result.passed ? 'text-green-700 dark:text-green-300' : 'text-red-700 dark:text-red-300'
                          }`}>
                            {testCase?.name || `Test ${index + 1}`}
                          </span>
                        </div>
                        <div className="flex items-center gap-3">
                          {result.error_message && !testCase?.hidden && (
                            <span className="text-xs text-red-600 dark:text-red-400">
                              {result.error_message}
                            </span>
                          )}
                          <span className={`text-sm ${
                            result.passed ? 'text-green-600 dark:text-green-400' : 'text-gray-400'
                          }`}>
                            {result.points_earned}/{testCase?.points || 0} pts
                          </span>
                          {result.execution_time_ms && (
                            <span className="text-xs text-gray-400">
                              {result.execution_time_ms}ms
                            </span>
                          )}
                        </div>
                      </div>
                    )
                  })
                )}
              </div>
            )}
          </div>
        </div>

        {/* Success message */}
        {allTestsPassed && (
          <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-md p-4 flex items-center gap-3">
            <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <div>
              <p className="font-medium text-green-800 dark:text-green-200">
                Excelente! Todos los tests pasaron.
              </p>
              <p className="text-sm text-green-600 dark:text-green-400">
                Has obtenido {score} de {maxScore} puntos.
              </p>
            </div>
          </div>
        )}
      </div>
    </ExerciseShell>
  )
}
