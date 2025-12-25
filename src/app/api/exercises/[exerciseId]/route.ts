import { NextRequest, NextResponse } from 'next/server'
import { resolveExercise, loadExercise } from '@/lib/content/loaders'
import { promises as fs } from 'fs'
import path from 'path'
import yaml from 'js-yaml'
import type { Exercise } from '@/types/exercises'

// Direct path to exercises (without module structure)
const CONTENT_PATH = path.join(process.cwd(), 'content', 'courses')

async function loadExerciseDirectly(
  courseSlug: string,
  exerciseId: string
): Promise<Exercise | null> {
  // Try to find the exercise in the course's module exercises directories
  const coursePath = path.join(CONTENT_PATH, courseSlug)

  try {
    const entries = await fs.readdir(coursePath, { withFileTypes: true })
    const moduleDirs = entries.filter(e => e.isDirectory() && e.name.startsWith('module-'))

    for (const moduleDir of moduleDirs) {
      const exercisePath = path.join(coursePath, moduleDir.name, 'exercises', `${exerciseId}.yaml`)
      try {
        const content = await fs.readFile(exercisePath, 'utf-8')
        return yaml.load(content) as Exercise
      } catch {
        // Exercise not in this module, continue searching
      }
    }
  } catch {
    // Course directory doesn't exist or can't be read
  }

  return null
}

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ exerciseId: string }> }
) {
  const { exerciseId } = await params
  const searchParams = request.nextUrl.searchParams
  const courseSlug = searchParams.get('course') || 'python-data-science'
  const moduleId = searchParams.get('module')

  try {
    let exercise: Exercise | null = null
    let datasets = new Map<string, string>()
    let schema: string | undefined

    // If module is provided, try to load with full resolver
    if (moduleId) {
      try {
        const resolved = await resolveExercise(courseSlug, moduleId, exerciseId)
        exercise = resolved.exercise
        datasets = resolved.datasets
        schema = resolved.schema
      } catch {
        // Fall back to direct loading
      }
    }

    // If no module or resolver failed, search all modules
    if (!exercise) {
      exercise = await loadExerciseDirectly(courseSlug, exerciseId)
    }

    if (!exercise) {
      return NextResponse.json(
        { error: 'Exercise not found', exerciseId },
        { status: 404 }
      )
    }

    // Remove solution code from response (don't expose to client)
    const exerciseForClient = {
      ...exercise,
      solution_code: undefined // Remove solution
    }

    return NextResponse.json({
      exercise: exerciseForClient,
      datasets: Object.fromEntries(datasets),
      schema
    })
  } catch (error) {
    console.error('Error loading exercise:', error)
    return NextResponse.json(
      {
        error: 'Failed to load exercise',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    )
  }
}
