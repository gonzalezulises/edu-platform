-- Migration: Interactive Exercises System
-- Description: Adds support for tracking progress on interactive Python, SQL, and Colab exercises

-- Exercise Progress Table
-- Tracks user progress on individual exercises
CREATE TABLE IF NOT EXISTS exercise_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  exercise_id TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'not_started' CHECK (status IN ('not_started', 'in_progress', 'completed', 'failed')),
  current_code TEXT,
  attempts INTEGER NOT NULL DEFAULT 0,
  score DECIMAL(10,2),
  max_score DECIMAL(10,2),
  test_results JSONB DEFAULT '[]'::jsonb,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  last_attempt_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, exercise_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_exercise_progress_user_id ON exercise_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_exercise_progress_exercise_id ON exercise_progress(exercise_id);
CREATE INDEX IF NOT EXISTS idx_exercise_progress_status ON exercise_progress(status);
CREATE INDEX IF NOT EXISTS idx_exercise_progress_user_status ON exercise_progress(user_id, status);

-- Enable RLS
ALTER TABLE exercise_progress ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can view their own exercise progress
CREATE POLICY "Users can view own exercise progress"
  ON exercise_progress
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own exercise progress
CREATE POLICY "Users can create own exercise progress"
  ON exercise_progress
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own exercise progress
CREATE POLICY "Users can update own exercise progress"
  ON exercise_progress
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Instructors and admins can view all exercise progress (for analytics)
CREATE POLICY "Instructors can view all exercise progress"
  ON exercise_progress
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role IN ('instructor', 'admin')
    )
  );

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_exercise_progress_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_exercise_progress_updated_at
  BEFORE UPDATE ON exercise_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_exercise_progress_updated_at();

-- Course Exercise Stats View
-- Aggregated stats for exercises by course/module
CREATE OR REPLACE VIEW exercise_stats AS
SELECT
  exercise_id,
  COUNT(*) AS total_attempts,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) FILTER (WHERE status = 'completed') AS completions,
  AVG(attempts) AS avg_attempts,
  AVG(score) AS avg_score,
  AVG(EXTRACT(EPOCH FROM (completed_at - started_at))/60) FILTER (WHERE completed_at IS NOT NULL) AS avg_completion_time_minutes
FROM exercise_progress
GROUP BY exercise_id;

-- User Exercise Summary View
-- Summary of a user's exercise performance
CREATE OR REPLACE VIEW user_exercise_summary AS
SELECT
  user_id,
  COUNT(*) AS total_exercises_attempted,
  COUNT(*) FILTER (WHERE status = 'completed') AS exercises_completed,
  SUM(score) AS total_score,
  SUM(max_score) AS total_possible_score,
  ROUND((SUM(score) / NULLIF(SUM(max_score), 0) * 100)::numeric, 2) AS score_percentage
FROM exercise_progress
GROUP BY user_id;

-- Grant access to views
GRANT SELECT ON exercise_stats TO authenticated;
GRANT SELECT ON user_exercise_summary TO authenticated;

COMMENT ON TABLE exercise_progress IS 'Tracks user progress on interactive exercises (Python, SQL, Colab)';
COMMENT ON COLUMN exercise_progress.exercise_id IS 'Unique identifier matching the exercise YAML file ID';
COMMENT ON COLUMN exercise_progress.current_code IS 'Last saved code from the user';
COMMENT ON COLUMN exercise_progress.test_results IS 'JSON array of test case results from last submission';
