'use client'

import { useMemo } from 'react'
import ReactMarkdown from 'react-markdown'
import remarkGfm from 'remark-gfm'
import rehypeHighlight from 'rehype-highlight'
import { parseEmbeds, hasEmbeds } from '@/lib/content/embed-parser'
import { Exercise } from '@/components/exercises'
import type { Exercise as ExerciseType, ExerciseProgress } from '@/types/exercises'

interface MarkdownRendererProps {
  content: string
  className?: string
  // Exercise-related props
  exercises?: Map<string, ExerciseType>
  exerciseProgress?: Map<string, ExerciseProgress>
  courseSlug?: string
  moduleId?: string
  onExerciseProgressUpdate?: (exerciseId: string, progress: Partial<ExerciseProgress>) => void
  showSolutions?: boolean
}

// Render a single markdown segment
function MarkdownSegment({ content, className }: { content: string; className: string }) {
  return (
    <div className={className}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeHighlight]}
        components={{
          // Custom styling for code blocks - let hljs handle styling
          pre: ({ children, ...props }) => (
            <pre className="not-prose my-4" {...props}>
              {children}
            </pre>
          ),
          code: ({ className, children, ...props }) => {
            const match = /language-(\w+)/.exec(className || '')
            const isInline = !match && !className?.includes('hljs')
            return isInline ? (
              <code className="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-sm font-mono text-gray-800 dark:text-gray-200" {...props}>
                {children}
              </code>
            ) : (
              <code className={`${className || ''} hljs`} {...props}>
                {children}
              </code>
            )
          },
          // Better table styling
          table: ({ children, ...props }) => (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700" {...props}>
                {children}
              </table>
            </div>
          ),
          th: ({ children, ...props }) => (
            <th className="bg-gray-50 dark:bg-gray-800 px-4 py-2 text-left text-sm font-semibold" {...props}>
              {children}
            </th>
          ),
          td: ({ children, ...props }) => (
            <td className="px-4 py-2 text-sm border-b border-gray-100 dark:border-gray-800" {...props}>
              {children}
            </td>
          ),
          // Links open in new tab for external URLs
          a: ({ href, children, ...props }) => {
            const isExternal = href?.startsWith('http')
            return (
              <a
                href={href}
                target={isExternal ? '_blank' : undefined}
                rel={isExternal ? 'noopener noreferrer' : undefined}
                className="text-blue-600 dark:text-blue-400 hover:underline"
                {...props}
              >
                {children}
              </a>
            )
          },
          // Better heading anchors
          h1: ({ children, ...props }) => (
            <h1 className="text-3xl font-bold mt-8 mb-4 text-gray-900 dark:text-white" {...props}>
              {children}
            </h1>
          ),
          h2: ({ children, ...props }) => (
            <h2 className="text-2xl font-bold mt-8 mb-4 text-gray-900 dark:text-white border-b pb-2 border-gray-200 dark:border-gray-700" {...props}>
              {children}
            </h2>
          ),
          h3: ({ children, ...props }) => (
            <h3 className="text-xl font-semibold mt-6 mb-3 text-gray-900 dark:text-white" {...props}>
              {children}
            </h3>
          ),
          // Blockquote styling
          blockquote: ({ children, ...props }) => (
            <blockquote className="border-l-4 border-blue-500 pl-4 italic text-gray-600 dark:text-gray-400 my-4" {...props}>
              {children}
            </blockquote>
          ),
          // List styling
          ul: ({ children, ...props }) => (
            <ul className="list-disc list-inside space-y-2 my-4" {...props}>
              {children}
            </ul>
          ),
          ol: ({ children, ...props }) => (
            <ol className="list-decimal list-inside space-y-2 my-4" {...props}>
              {children}
            </ol>
          ),
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  )
}

export function MarkdownRenderer({
  content,
  className = '',
  exercises,
  exerciseProgress,
  courseSlug,
  moduleId,
  onExerciseProgressUpdate,
  showSolutions = false
}: MarkdownRendererProps) {
  // Parse content for embeds
  const parsedContent = useMemo(() => {
    if (!hasEmbeds(content)) {
      return null
    }
    return parseEmbeds(content)
  }, [content])

  // If no embeds, render as standard markdown
  if (!parsedContent) {
    return (
      <MarkdownSegment
        content={content}
        className={`prose prose-slate dark:prose-invert max-w-none ${className}`}
      />
    )
  }

  // Render segments with embedded exercises
  return (
    <div className={className}>
      {parsedContent.segments.map((segment, index) => {
        if (segment.type === 'markdown') {
          return (
            <MarkdownSegment
              key={`md-${index}`}
              content={segment.content}
              className="prose prose-slate dark:prose-invert max-w-none"
            />
          )
        }

        if (segment.type === 'embed' && segment.embed) {
          const { type, id } = segment.embed

          if (type === 'exercise') {
            const exercise = exercises?.get(id)
            const progress = exerciseProgress?.get(id)

            return (
              <Exercise
                key={`ex-${id}`}
                exerciseId={id}
                exercise={exercise}
                progress={progress}
                courseSlug={courseSlug}
                moduleId={moduleId}
                onProgressUpdate={
                  onExerciseProgressUpdate
                    ? (p) => onExerciseProgressUpdate(id, p)
                    : undefined
                }
                showSolution={showSolutions}
              />
            )
          }

          // Handle other embed types (dataset, colab) if needed
          return (
            <div
              key={`embed-${index}`}
              className="my-4 p-4 bg-gray-100 dark:bg-gray-800 rounded-md text-sm text-gray-600 dark:text-gray-400"
            >
              Embed: {type}:{id}
            </div>
          )
        }

        return null
      })}
    </div>
  )
}

// Legacy export for backwards compatibility (no embeds)
export function SimpleMarkdownRenderer({ content, className = '' }: { content: string; className?: string }) {
  return (
    <div className={`prose prose-slate dark:prose-invert max-w-none ${className}`}>
      <ReactMarkdown
        remarkPlugins={[remarkGfm]}
        rehypePlugins={[rehypeHighlight]}
        components={{
          // Custom styling for code blocks - let hljs handle styling
          pre: ({ children, ...props }) => (
            <pre className="not-prose my-4" {...props}>
              {children}
            </pre>
          ),
          code: ({ className, children, ...props }) => {
            const match = /language-(\w+)/.exec(className || '')
            const isInline = !match && !className?.includes('hljs')
            return isInline ? (
              <code className="bg-gray-200 dark:bg-gray-700 px-1.5 py-0.5 rounded text-sm font-mono text-gray-800 dark:text-gray-200" {...props}>
                {children}
              </code>
            ) : (
              <code className={`${className || ''} hljs`} {...props}>
                {children}
              </code>
            )
          },
          // Better table styling
          table: ({ children, ...props }) => (
            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700" {...props}>
                {children}
              </table>
            </div>
          ),
          th: ({ children, ...props }) => (
            <th className="bg-gray-50 dark:bg-gray-800 px-4 py-2 text-left text-sm font-semibold" {...props}>
              {children}
            </th>
          ),
          td: ({ children, ...props }) => (
            <td className="px-4 py-2 text-sm border-b border-gray-100 dark:border-gray-800" {...props}>
              {children}
            </td>
          ),
          // Links open in new tab for external URLs
          a: ({ href, children, ...props }) => {
            const isExternal = href?.startsWith('http')
            return (
              <a
                href={href}
                target={isExternal ? '_blank' : undefined}
                rel={isExternal ? 'noopener noreferrer' : undefined}
                className="text-blue-600 dark:text-blue-400 hover:underline"
                {...props}
              >
                {children}
              </a>
            )
          },
          // Better heading anchors
          h1: ({ children, ...props }) => (
            <h1 className="text-3xl font-bold mt-8 mb-4 text-gray-900 dark:text-white" {...props}>
              {children}
            </h1>
          ),
          h2: ({ children, ...props }) => (
            <h2 className="text-2xl font-bold mt-8 mb-4 text-gray-900 dark:text-white border-b pb-2 border-gray-200 dark:border-gray-700" {...props}>
              {children}
            </h2>
          ),
          h3: ({ children, ...props }) => (
            <h3 className="text-xl font-semibold mt-6 mb-3 text-gray-900 dark:text-white" {...props}>
              {children}
            </h3>
          ),
          // Blockquote styling
          blockquote: ({ children, ...props }) => (
            <blockquote className="border-l-4 border-blue-500 pl-4 italic text-gray-600 dark:text-gray-400 my-4" {...props}>
              {children}
            </blockquote>
          ),
          // List styling
          ul: ({ children, ...props }) => (
            <ul className="list-disc list-inside space-y-2 my-4" {...props}>
              {children}
            </ul>
          ),
          ol: ({ children, ...props }) => (
            <ol className="list-decimal list-inside space-y-2 my-4" {...props}>
              {children}
            </ol>
          ),
        }}
      >
        {content}
      </ReactMarkdown>
    </div>
  )
}
