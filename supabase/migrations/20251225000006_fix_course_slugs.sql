-- =====================================================
-- Fix course slugs (repair migration)
-- =====================================================

-- First, let's see what courses exist and set unique slugs
-- This handles the case where multiple courses might match patterns

-- Set sklearn-intro slug (should already be set from previous partial migration)
UPDATE courses SET slug = 'sklearn-intro'
WHERE id = '7483519d-cc1d-4cba-bf52-6dde74ce8933' AND (slug IS NULL OR slug != 'sklearn-intro');

-- Set python-data-science slug for the Python intro course
-- Use the specific course title to avoid duplicates
UPDATE courses SET slug = 'python-data-science'
WHERE title = 'Introduccion a Python para Ciencia de Datos' AND slug IS NULL;

-- Verify the slugs are set correctly
DO $$
DECLARE
  sklearn_slug TEXT;
  python_slug TEXT;
BEGIN
  SELECT slug INTO sklearn_slug FROM courses WHERE id = '7483519d-cc1d-4cba-bf52-6dde74ce8933';
  SELECT slug INTO python_slug FROM courses WHERE title = 'Introduccion a Python para Ciencia de Datos';

  RAISE NOTICE 'Sklearn course slug: %', COALESCE(sklearn_slug, 'NOT SET');
  RAISE NOTICE 'Python course slug: %', COALESCE(python_slug, 'NOT SET');
END $$;
