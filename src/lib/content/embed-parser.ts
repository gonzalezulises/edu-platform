import type {
  ParsedContent,
  ContentSegment,
  ParsedEmbed,
  EmbedType
} from '@/types/exercises'

// Regex patterns for embeds
// Format: <!-- exercise:exercise-id -->
// Format: <!-- dataset:dataset-id -->
// Format: <!-- colab:notebook-id -->
const EMBED_PATTERN = /<!--\s*(exercise|dataset|colab):([a-zA-Z0-9_-]+)\s*-->/g

/**
 * Parse markdown content and extract embeds
 * Returns segments of markdown and embed references
 */
export function parseEmbeds(markdown: string): ParsedContent {
  const segments: ContentSegment[] = []
  const embeds: ParsedEmbed[] = []

  let lastIndex = 0
  let match: RegExpExecArray | null

  // Reset regex state
  EMBED_PATTERN.lastIndex = 0

  while ((match = EMBED_PATTERN.exec(markdown)) !== null) {
    const embedType = match[1] as EmbedType
    const embedId = match[2]
    const matchStart = match.index
    const matchEnd = match.index + match[0].length

    // Add markdown content before this embed
    if (matchStart > lastIndex) {
      const content = markdown.slice(lastIndex, matchStart).trim()
      if (content) {
        segments.push({
          type: 'markdown',
          content
        })
      }
    }

    // Create embed reference
    const embed: ParsedEmbed = {
      type: embedType,
      id: embedId,
      raw: match[0]
    }

    embeds.push(embed)
    segments.push({
      type: 'embed',
      content: match[0],
      embed
    })

    lastIndex = matchEnd
  }

  // Add remaining markdown content
  if (lastIndex < markdown.length) {
    const content = markdown.slice(lastIndex).trim()
    if (content) {
      segments.push({
        type: 'markdown',
        content
      })
    }
  }

  return { segments, embeds }
}

/**
 * Check if content has embeds
 */
export function hasEmbeds(markdown: string): boolean {
  EMBED_PATTERN.lastIndex = 0
  return EMBED_PATTERN.test(markdown)
}

/**
 * Extract all embed IDs from content
 */
export function extractEmbedIds(markdown: string): string[] {
  const { embeds } = parseEmbeds(markdown)
  return embeds.map(e => e.id)
}

/**
 * Extract exercise IDs only
 */
export function extractExerciseIds(markdown: string): string[] {
  const { embeds } = parseEmbeds(markdown)
  return embeds
    .filter(e => e.type === 'exercise')
    .map(e => e.id)
}

/**
 * Convert embed comment to MDX component syntax
 * For future MDX migration
 *
 * <!-- exercise:ex-01 --> → <Exercise id="ex-01" />
 */
export function convertToMDXSyntax(embed: ParsedEmbed): string {
  switch (embed.type) {
    case 'exercise':
      return `<Exercise id="${embed.id}" />`
    case 'dataset':
      return `<Dataset id="${embed.id}" />`
    case 'colab':
      return `<ColabNotebook id="${embed.id}" />`
    default:
      return embed.raw
  }
}

/**
 * Convert all embeds in markdown to MDX syntax
 */
export function convertMarkdownToMDX(markdown: string): string {
  const { embeds } = parseEmbeds(markdown)
  let result = markdown

  for (const embed of embeds) {
    result = result.replace(embed.raw, convertToMDXSyntax(embed))
  }

  return result
}

/**
 * Validate embed format
 */
export function validateEmbed(raw: string): boolean {
  EMBED_PATTERN.lastIndex = 0
  return EMBED_PATTERN.test(raw)
}

/**
 * Create embed comment from type and id
 */
export function createEmbed(type: EmbedType, id: string): string {
  return `<!-- ${type}:${id} -->`
}

/**
 * Get embed type description
 */
export function getEmbedTypeLabel(type: EmbedType): string {
  const labels: Record<EmbedType, string> = {
    exercise: 'Ejercicio Interactivo',
    dataset: 'Dataset',
    colab: 'Notebook Colab'
  }
  return labels[type] || type
}
