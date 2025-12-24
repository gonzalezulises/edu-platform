'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import type { SQLExecutionResult } from '@/types/exercises'

// sql.js types
interface SqlJsDatabase {
  run: (sql: string) => void
  exec: (sql: string) => QueryResult[]
  getRowsModified: () => number
  close: () => void
}

interface QueryResult {
  columns: string[]
  values: unknown[][]
}

interface SqlJsStatic {
  Database: new (data?: ArrayLike<number> | null) => SqlJsDatabase
}

declare global {
  interface Window {
    initSqlJs?: (config: { locateFile: (file: string) => string }) => Promise<SqlJsStatic>
  }
}

interface UseSQLiteOptions {
  schema?: string
  csvData?: Map<string, string>
  onLoad?: () => void
  onError?: (error: Error) => void
}

interface UseSQLiteReturn {
  isLoading: boolean
  isReady: boolean
  error: Error | null
  runQuery: (sql: string) => Promise<SQLExecutionResult>
  loadCSV: (tableName: string, csvContent: string) => Promise<void>
  loadSchema: (schema: string) => Promise<void>
  reset: () => Promise<void>
  getTables: () => Promise<string[]>
}

// SQL.js CDN
const SQL_JS_CDN = 'https://sql.js.org/dist/'

export function useSQLite(options: UseSQLiteOptions = {}): UseSQLiteReturn {
  const { schema, csvData, onLoad, onError } = options

  const [isLoading, setIsLoading] = useState(false)
  const [isReady, setIsReady] = useState(false)
  const [error, setError] = useState<Error | null>(null)

  const sqlRef = useRef<SqlJsStatic | null>(null)
  const dbRef = useRef<SqlJsDatabase | null>(null)

  // Load sql.js script
  const loadSqlJsScript = useCallback(async (): Promise<void> => {
    if (typeof window === 'undefined') return
    if (window.initSqlJs) return

    return new Promise((resolve, reject) => {
      const script = document.createElement('script')
      script.src = `${SQL_JS_CDN}sql-wasm.js`
      script.async = true
      script.onload = () => resolve()
      script.onerror = () => reject(new Error('Failed to load sql.js'))
      document.head.appendChild(script)
    })
  }, [])

  // Initialize sql.js
  const initSqlJs = useCallback(async (): Promise<void> => {
    if (dbRef.current) return

    setIsLoading(true)

    try {
      await loadSqlJsScript()

      if (!window.initSqlJs) {
        throw new Error('sql.js not available')
      }

      const SQL = await window.initSqlJs({
        locateFile: (file: string) => `${SQL_JS_CDN}${file}`
      })

      sqlRef.current = SQL
      dbRef.current = new SQL.Database()

      // Load initial schema if provided
      if (schema) {
        dbRef.current.run(schema)
      }

      // Load CSV data if provided
      if (csvData) {
        for (const [tableName, content] of csvData) {
          await loadCSVInternal(tableName, content)
        }
      }

      setIsReady(true)
      onLoad?.()
    } catch (err) {
      const error = err instanceof Error ? err : new Error('Unknown error')
      setError(error)
      onError?.(error)
    } finally {
      setIsLoading(false)
    }
  }, [loadSqlJsScript, schema, csvData, onLoad, onError])

  // Parse CSV to rows
  const parseCSV = useCallback((csv: string): { headers: string[], rows: string[][] } => {
    const lines = csv.trim().split('\n')
    const headers = lines[0].split(',').map(h => h.trim().replace(/^"|"$/g, ''))
    const rows = lines.slice(1).map(line => {
      // Handle quoted fields with commas
      const values: string[] = []
      let current = ''
      let inQuotes = false

      for (const char of line) {
        if (char === '"') {
          inQuotes = !inQuotes
        } else if (char === ',' && !inQuotes) {
          values.push(current.trim())
          current = ''
        } else {
          current += char
        }
      }
      values.push(current.trim())

      return values
    })

    return { headers, rows }
  }, [])

  // Internal CSV loader
  const loadCSVInternal = useCallback(async (
    tableName: string,
    csvContent: string
  ): Promise<void> => {
    if (!dbRef.current) return

    const { headers, rows } = parseCSV(csvContent)

    // Create table
    const columns = headers.map(h => `"${h}" TEXT`).join(', ')
    dbRef.current.run(`CREATE TABLE IF NOT EXISTS "${tableName}" (${columns})`)

    // Insert rows
    const placeholders = headers.map(() => '?').join(', ')
    const insertSql = `INSERT INTO "${tableName}" VALUES (${placeholders})`

    for (const row of rows) {
      // Use parameterized query for safety
      const values = row.map(v => v === '' ? null : v)
      dbRef.current.run(
        `INSERT INTO "${tableName}" (${headers.map(h => `"${h}"`).join(', ')}) VALUES (${values.map(v => v === null ? 'NULL' : `'${v.replace(/'/g, "''")}'`).join(', ')})`
      )
    }
  }, [parseCSV])

  // Run SQL query
  const runQuery = useCallback(async (sql: string): Promise<SQLExecutionResult> => {
    if (!dbRef.current) {
      await initSqlJs()
    }

    if (!dbRef.current) {
      return {
        success: false,
        columns: [],
        rows: [],
        error: 'Database not initialized',
        execution_time_ms: 0
      }
    }

    const startTime = performance.now()

    try {
      const results = dbRef.current.exec(sql)
      const rowsAffected = dbRef.current.getRowsModified()
      const executionTime = Math.round(performance.now() - startTime)

      if (results.length === 0) {
        return {
          success: true,
          columns: [],
          rows: [],
          execution_time_ms: executionTime,
          rows_affected: rowsAffected
        }
      }

      const { columns, values } = results[0]
      const rows = values.map(row => {
        const obj: Record<string, unknown> = {}
        columns.forEach((col, i) => {
          obj[col] = row[i]
        })
        return obj
      })

      return {
        success: true,
        columns,
        rows,
        execution_time_ms: executionTime,
        rows_affected: rowsAffected
      }
    } catch (err) {
      const executionTime = Math.round(performance.now() - startTime)
      const errorMessage = err instanceof Error ? err.message : String(err)

      return {
        success: false,
        columns: [],
        rows: [],
        error: errorMessage,
        execution_time_ms: executionTime
      }
    }
  }, [initSqlJs])

  // Public CSV loader
  const loadCSV = useCallback(async (
    tableName: string,
    csvContent: string
  ): Promise<void> => {
    if (!dbRef.current) {
      await initSqlJs()
    }

    if (dbRef.current) {
      await loadCSVInternal(tableName, csvContent)
    }
  }, [initSqlJs, loadCSVInternal])

  // Load SQL schema
  const loadSchema = useCallback(async (schemaSQL: string): Promise<void> => {
    if (!dbRef.current) {
      await initSqlJs()
    }

    if (dbRef.current) {
      dbRef.current.run(schemaSQL)
    }
  }, [initSqlJs])

  // Reset database
  const reset = useCallback(async (): Promise<void> => {
    if (dbRef.current) {
      dbRef.current.close()
    }

    if (sqlRef.current) {
      dbRef.current = new sqlRef.current.Database()

      // Reload schema if provided
      if (schema) {
        dbRef.current.run(schema)
      }

      // Reload CSV data if provided
      if (csvData) {
        for (const [tableName, content] of csvData) {
          await loadCSVInternal(tableName, content)
        }
      }
    }
  }, [schema, csvData, loadCSVInternal])

  // Get list of tables
  const getTables = useCallback(async (): Promise<string[]> => {
    if (!dbRef.current) {
      await initSqlJs()
    }

    if (!dbRef.current) return []

    const result = dbRef.current.exec(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
    )

    if (result.length === 0) return []

    return result[0].values.map(row => String(row[0]))
  }, [initSqlJs])

  // Initialize on mount
  useEffect(() => {
    if ((schema || csvData) && !isReady && !isLoading) {
      initSqlJs()
    }
  }, [schema, csvData, isReady, isLoading, initSqlJs])

  return {
    isLoading,
    isReady,
    error,
    runQuery,
    loadCSV,
    loadSchema,
    reset,
    getTables
  }
}
