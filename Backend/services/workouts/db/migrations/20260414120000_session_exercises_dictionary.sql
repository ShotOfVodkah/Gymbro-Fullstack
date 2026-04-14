-- +goose Up

ALTER TABLE session_exercises RENAME TO workout_session_exercise_entries;

ALTER TABLE workout_session_exercise_entries DROP CONSTRAINT IF EXISTS session_exercises_exercise_id_fkey;
ALTER TABLE workout_session_exercise_entries DROP CONSTRAINT IF EXISTS workout_session_exercise_entries_exercise_id_fkey;

UPDATE workout_session_exercise_entries
SET exercise_id = 'legacy-' || id::text
WHERE exercise_id IS NULL;

CREATE TABLE session_exercises (
    id            TEXT NOT NULL PRIMARY KEY,
    name          TEXT NOT NULL,
    type          TEXT NOT NULL,
    muscle_group  TEXT NOT NULL
);

INSERT INTO session_exercises (id, name, type, muscle_group)
SELECT DISTINCT ON (exercise_id)
    exercise_id,
    exercise_name,
    exercise_type,
    muscle_group
FROM workout_session_exercise_entries
ORDER BY exercise_id, id;

ALTER TABLE workout_session_exercise_entries
    DROP COLUMN exercise_name,
    DROP COLUMN exercise_type,
    DROP COLUMN muscle_group;

ALTER TABLE workout_session_exercise_entries
    ADD CONSTRAINT workout_session_exercise_entries_exercise_id_fkey
    FOREIGN KEY (exercise_id) REFERENCES session_exercises (id) ON DELETE RESTRICT;

ALTER TABLE workout_session_exercise_entries
    ALTER COLUMN exercise_id SET NOT NULL;

CREATE INDEX idx_wsee_session_id ON workout_session_exercise_entries (session_id);
CREATE INDEX idx_wsee_exercise_id ON workout_session_exercise_entries (exercise_id);

-- +goose Down

DROP INDEX IF EXISTS idx_wsee_exercise_id;
DROP INDEX IF EXISTS idx_wsee_session_id;

ALTER TABLE workout_session_exercise_entries DROP CONSTRAINT IF EXISTS workout_session_exercise_entries_exercise_id_fkey;

ALTER TABLE workout_session_exercise_entries
    ADD COLUMN exercise_name TEXT,
    ADD COLUMN exercise_type TEXT,
    ADD COLUMN muscle_group TEXT;

UPDATE workout_session_exercise_entries e
SET exercise_name = d.name,
    exercise_type = d.type,
    muscle_group = d.muscle_group
FROM session_exercises d
WHERE e.exercise_id = d.id;

ALTER TABLE workout_session_exercise_entries
    ALTER COLUMN exercise_name SET NOT NULL,
    ALTER COLUMN exercise_type SET NOT NULL,
    ALTER COLUMN muscle_group SET NOT NULL;

DROP TABLE session_exercises;

ALTER TABLE workout_session_exercise_entries RENAME TO session_exercises;

UPDATE session_exercises e
SET exercise_id = NULL
WHERE exercise_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM exercises x WHERE x.id = e.exercise_id);

ALTER TABLE session_exercises
    ADD CONSTRAINT session_exercises_exercise_id_fkey
    FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE SET NULL;
