'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import type { PythonExecutionResult, TestCase, TestResult } from '@/types/exercises'

// Pyodide CDN URL
const PYODIDE_CDN = 'https://cdn.jsdelivr.net/pyodide/v0.24.1/full/'

// Type definitions for Pyodide
interface PyodideInterface {
  runPython: (code: string) => unknown
  runPythonAsync: (code: string) => Promise<unknown>
  loadPackage: (packages: string | string[]) => Promise<void>
  loadPackagesFromImports: (code: string) => Promise<void>
  globals: {
    get: (name: string) => unknown
    set: (name: string, value: unknown) => void
  }
  setStdout: (options: { batched: (msg: string) => void }) => void
  setStderr: (options: { batched: (msg: string) => void }) => void
}

declare global {
  interface Window {
    loadPyodide?: (config: { indexURL: string }) => Promise<PyodideInterface>
  }
}

interface UsePyodideOptions {
  packages?: string[]
  onLoad?: () => void
  onError?: (error: Error) => void
}

interface UsePyodideReturn {
  isLoading: boolean
  isReady: boolean
  error: Error | null
  loadProgress: number
  runCode: (code: string) => Promise<PythonExecutionResult>
  runTests: (code: string, tests: TestCase[]) => Promise<PythonExecutionResult>
  installPackages: (packages: string[]) => Promise<void>
  reset: () => Promise<void>
}

export function usePyodide(options: UsePyodideOptions = {}): UsePyodideReturn {
  const { packages = [], onLoad, onError } = options

  const [isLoading, setIsLoading] = useState(false)
  const [isReady, setIsReady] = useState(false)
  const [error, setError] = useState<Error | null>(null)
  const [loadProgress, setLoadProgress] = useState(0)

  const pyodideRef = useRef<PyodideInterface | null>(null)
  const stdoutRef = useRef<string>('')
  const stderrRef = useRef<string>('')

  // Load Pyodide script
  const loadPyodideScript = useCallback(async (): Promise<void> => {
    if (typeof window === 'undefined') return

    // Check if already loaded
    if (window.loadPyodide) return

    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = `${PYODIDE_CDN}pyodide.js`
      script.async = true
      script.onload = () => resolve()
      script.onerror = () => reject(new Error('Failed to load Pyodide script'))
      document.head.appendChild(script)
    })
  }, [])

  // Initialize Pyodide
  const initPyodide = useCallback(async (): Promise<void> => {
    if (pyodideRef.current) return

    setIsLoading(true)
    setLoadProgress(10)

    try {
      // Load the script first
      await loadPyodideScript()
      setLoadProgress(30)

      // Initialize Pyodide
      if (!window.loadPyodide) {
        throw new Error('Pyodide not available')
      }

      const pyodide = await window.loadPyodide({
        indexURL: PYODIDE_CDN
      })
      setLoadProgress(60)

      // Set up stdout/stderr capture
      pyodide.setStdout({
        batched: (msg: string) => {
          stdoutRef.current += msg + '\n'
        }
      })

      pyodide.setStderr({
        batched: (msg: string) => {
          stderrRef.current += msg + '\n'
        }
      })

      // Load default packages
      if (packages.length > 0) {
        await pyodide.loadPackage(packages)
      }
      setLoadProgress(90)

      pyodideRef.current = pyodide
      setIsReady(true)
      setLoadProgress(100)
      onLoad?.()
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error')
      setError(error)
      onError?.(error)
    } finally {
      setIsLoading(false)
    }
  }, [loadPyodideScript, packages, onLoad, onError])

  // Run Python code
  const runCode = useCallback(async (code: string): Promise<PythonExecutionResult> => {
    if (!pyodideRef.current) {
      await initPyodide()
    }

    if (!pyodideRef.current) {
      return {
        success: false,
        stdout: '',
        stderr: '',
        error: 'Pyodide not initialized',
        execution_time_ms: 0
      }
    }

    // Reset output buffers
    stdoutRef.current = ''
    stderrRef.current = ''

    const startTime = performance.now()

    try {
      // Auto-load packages from imports
      await pyodideRef.current.loadPackagesFromImports(code)

      // Run the code
      await pyodideRef.current.runPythonAsync(code)

      const executionTime = performance.now() - startTime

      return {
        success: true,
        stdout: stdoutRef.current.trim(),
        stderr: stderrRef.current.trim(),
        execution_time_ms: Math.round(executionTime)
      }
    } catch (err) {
      const executionTime = performance.now() - startTime
      const errorMessage = err instanceof Error ? err.message : String(err)

      return {
        success: false,
        stdout: stdoutRef.current.trim(),
        stderr: stderrRef.current.trim(),
        error: errorMessage,
        execution_time_ms: Math.round(executionTime)
      }
    }
  }, [initPyodide])

  // Run code with test cases
  const runTests = useCallback(async (
    code: string,
    tests: TestCase[]
  ): Promise<PythonExecutionResult> => {
    // First run the user's code
    const codeResult = await runCode(code)

    if (!codeResult.success) {
      return codeResult
    }

    if (!pyodideRef.current) {
      return {
        ...codeResult,
        success: false,
        error: 'Pyodide not available for tests'
      }
    }

    const testResults: TestResult[] = []
    let totalPoints = 0
    let earnedPoints = 0

    for (const test of tests) {
      totalPoints += test.points
      const testStartTime = performance.now()

      try {
        // Run the test code
        await pyodideRef.current.runPythonAsync(test.test_code)

        testResults.push({
          test_id: test.id,
          passed: true,
          points_earned: test.points,
          execution_time_ms: Math.round(performance.now() - testStartTime)
        })
        earnedPoints += test.points
      } catch (err) {
        const errorMessage = err instanceof Error ? err.message : String(err)
        testResults.push({
          test_id: test.id,
          passed: false,
          points_earned: 0,
          error_message: test.error_message || errorMessage,
          execution_time_ms: Math.round(performance.now() - testStartTime)
        })
      }
    }

    const allPassed = testResults.every(r => r.passed)

    return {
      ...codeResult,
      success: allPassed,
      test_results: testResults
    }
  }, [runCode])

  // Install additional packages
  const installPackages = useCallback(async (packageList: string[]): Promise<void> => {
    if (!pyodideRef.current) {
      await initPyodide()
    }

    if (pyodideRef.current) {
      await pyodideRef.current.loadPackage(packageList)
    }
  }, [initPyodide])

  // Reset Pyodide state
  const reset = useCallback(async (): Promise<void> => {
    if (pyodideRef.current) {
      // Clear all user-defined variables
      await pyodideRef.current.runPythonAsync(`
import sys
# Get list of user-defined variables (exclude builtins and modules)
user_vars = [name for name in dir() if not name.startswith('_') and name not in sys.modules]
for var in user_vars:
    try:
        del globals()[var]
    except:
        pass
`)
    }
    stdoutRef.current = ''
    stderrRef.current = ''
  }, [])

  // Initialize on mount if packages are specified
  useEffect(() => {
    if (packages.length > 0 && !isReady && !isLoading) {
      initPyodide()
    }
  }, [packages.length, isReady, isLoading, initPyodide])

  return {
    isLoading,
    isReady,
    error,
    loadProgress,
    runCode,
    runTests,
    installPackages,
    reset
  }
}
