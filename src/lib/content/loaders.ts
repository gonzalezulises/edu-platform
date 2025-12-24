import { promises as fs } from 'fs'
import path from 'path'
import yaml from 'js-yaml'
import type {
  Exercise,
  RuntimeConfig,
  CourseExerciseConfig,
  LoadedExercise,
  DatasetReference
} from '@/types/exercises'

// Base paths
const CONFIG_PATH = path.join(process.cwd(), 'config')
const CONTENT_PATH = path.join(process.cwd(), 'content')
const COURSES_PATH = path.join(CONTENT_PATH, 'courses')
const SHARED_PATH = path.join(CONTENT_PATH, 'shared')

// Environment configuration
export async function loadEnvironmentConfig(): Promise<RuntimeConfig> {
  const configPath = path.join(CONFIG_PATH, 'environments.yaml')
  const content = await fs.readFile(configPath, 'utf-8')
  return yaml.load(content) as RuntimeConfig
}

// Course configuration
export interface CourseConfig {
  id: string
  title: string
  description: string
  slug: string
  instructor_id: string | null
  is_published: boolean
  exercise_config: CourseExerciseConfig
  modules: ModuleReference[]
  prerequisites: string[]
  tags: string[]
}

export interface ModuleReference {
  id: string
  title: string
  description: string
  order: number
}

export async function loadCourseConfig(courseSlug: string): Promise<CourseConfig> {
  const configPath = path.join(COURSES_PATH, courseSlug, 'course.yaml')
  const content = await fs.readFile(configPath, 'utf-8')
  return yaml.load(content) as CourseConfig
}

// Module configuration
export interface ModuleConfig {
  id: string
  title: string
  description: string
  order: number
  lessons: LessonReference[]
  exercises: ExerciseReference[]
}

export interface LessonReference {
  id: string
  file: string
  title: string
  type: string
  order: number
}

export interface ExerciseReference {
  id: string
  file: string
  lesson_id: string
}

export async function loadModuleConfig(
  courseSlug: string,
  moduleId: string
): Promise<ModuleConfig> {
  const configPath = path.join(COURSES_PATH, courseSlug, moduleId, 'module.yaml')
  const content = await fs.readFile(configPath, 'utf-8')
  return yaml.load(content) as ModuleConfig
}

// Exercise loader
export async function loadExercise(
  courseSlug: string,
  moduleId: string,
  exerciseId: string
): Promise<Exercise> {
  const exercisePath = path.join(
    COURSES_PATH,
    courseSlug,
    moduleId,
    'exercises',
    `${exerciseId}.yaml`
  )
  const content = await fs.readFile(exercisePath, 'utf-8')
  return yaml.load(content) as Exercise
}

// Exercise with file path
export async function loadExerciseByPath(filePath: string): Promise<Exercise> {
  const fullPath = path.join(COURSES_PATH, filePath)
  const content = await fs.readFile(fullPath, 'utf-8')
  return yaml.load(content) as Exercise
}

// Dataset loader
export async function loadDataset(datasetPath: string): Promise<string> {
  const fullPath = path.join(SHARED_PATH, 'datasets', datasetPath)
  return fs.readFile(fullPath, 'utf-8')
}

// Load dataset by reference
export async function loadDatasetByRef(ref: DatasetReference): Promise<string> {
  return loadDataset(ref.path)
}

// SQL schema loader
export async function loadSQLSchema(schemaId: string): Promise<string> {
  const schemaPath = path.join(SHARED_PATH, 'schemas', `${schemaId}.sql`)
  return fs.readFile(schemaPath, 'utf-8')
}

// Lesson markdown loader
export async function loadLessonContent(
  courseSlug: string,
  moduleId: string,
  lessonFile: string
): Promise<string> {
  const lessonPath = path.join(COURSES_PATH, courseSlug, moduleId, lessonFile)
  return fs.readFile(lessonPath, 'utf-8')
}

// Full exercise resolver - loads exercise with all dependencies
export async function resolveExercise(
  courseSlug: string,
  moduleId: string,
  exerciseId: string
): Promise<LoadedExercise> {
  const exercise = await loadExercise(courseSlug, moduleId, exerciseId)

  const datasets = new Map<string, string>()

  // Load datasets if present
  if ('datasets' in exercise && exercise.datasets) {
    for (const datasetRef of exercise.datasets) {
      const content = await loadDatasetByRef(datasetRef)
      datasets.set(datasetRef.id, content)
    }
  }

  // Load SQL schema if present
  let schema: string | undefined
  if (exercise.type === 'sql' && 'schema_id' in exercise) {
    schema = await loadSQLSchema(exercise.schema_id)
  }

  return { exercise, datasets, schema }
}

// List all courses
export async function listCourses(): Promise<string[]> {
  const entries = await fs.readdir(COURSES_PATH, { withFileTypes: true })
  return entries
    .filter(entry => entry.isDirectory())
    .map(entry => entry.name)
}

// List modules for a course
export async function listModules(courseSlug: string): Promise<string[]> {
  const coursePath = path.join(COURSES_PATH, courseSlug)
  const entries = await fs.readdir(coursePath, { withFileTypes: true })
  return entries
    .filter(entry => entry.isDirectory() && entry.name.startsWith('module-'))
    .map(entry => entry.name)
    .sort()
}

// Check if file exists
export async function fileExists(filePath: string): Promise<boolean> {
  try {
    await fs.access(filePath)
    return true
  } catch {
    return false
  }
}

// Get all exercises for a module
export async function getModuleExercises(
  courseSlug: string,
  moduleId: string
): Promise<Exercise[]> {
  const moduleConfig = await loadModuleConfig(courseSlug, moduleId)
  const exercises: Exercise[] = []

  for (const ref of moduleConfig.exercises) {
    try {
      const exercise = await loadExerciseByPath(
        path.join(courseSlug, moduleId, ref.file)
      )
      exercises.push(exercise)
    } catch (error) {
      console.error(`Failed to load exercise ${ref.id}:`, error)
    }
  }

  return exercises
}
