-- =====================================================
-- Add slug column to courses table
-- =====================================================
-- This migration was partially applied - the slug column was added
-- See 20251225000006_fix_course_slugs.sql for actual slug values

-- Add slug column (if not exists is handled via DO block)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'courses' AND column_name = 'slug'
  ) THEN
    ALTER TABLE courses ADD COLUMN slug TEXT;
  END IF;
END $$;

-- Create unique index on slug (only if not exists)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_indexes WHERE indexname = 'courses_slug_idx'
  ) THEN
    CREATE UNIQUE INDEX courses_slug_idx ON courses(slug) WHERE slug IS NOT NULL;
  END IF;
END $$;

-- Add comment
COMMENT ON COLUMN courses.slug IS 'URL-friendly identifier matching content folder name';
