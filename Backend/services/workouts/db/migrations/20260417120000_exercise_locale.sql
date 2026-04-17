-- +goose Up

ALTER TABLE exercises ADD COLUMN name_en TEXT;

UPDATE exercises SET name_en = v.en FROM (VALUES
    ('bench-press', 'Bench press'),
    ('incline-press', 'Incline bench press'),
    ('dumbbell-fly', 'Dumbbell fly'),
    ('pull-up', 'Pull-ups'),
    ('barbell-row', 'Barbell row'),
    ('deadlift', 'Deadlift'),
    ('overhead-press', 'Overhead press'),
    ('lateral-raise', 'Lateral raise'),
    ('barbell-curl', 'Barbell curl'),
    ('hammer-curl', 'Hammer curl'),
    ('tricep-pushdown', 'Triceps pushdown'),
    ('skull-crusher', 'Skull crusher'),
    ('squat', 'Squat'),
    ('leg-press', 'Leg press'),
    ('lunge', 'Lunge'),
    ('plank', 'Plank'),
    ('crunch', 'Crunches'),
    ('running', 'Running'),
    ('cycling', 'Cycling'),
    ('rowing', 'Rowing'),
    ('jump-rope', 'Jump rope'),
    ('elliptical', 'Elliptical trainer'),
    ('swimming', 'Swimming'),
    ('warrior-1', 'Warrior I'),
    ('warrior-2', 'Warrior II'),
    ('downward-dog', 'Downward dog'),
    ('child-pose', 'Child''s pose'),
    ('tree-pose', 'Tree pose'),
    ('cobra', 'Cobra'),
    ('pigeon-pose', 'Pigeon pose')
) AS v(id, en) WHERE exercises.id = v.id;

ALTER TABLE exercises ALTER COLUMN name_en SET NOT NULL;

ALTER TABLE session_exercises ADD COLUMN name_en TEXT;

UPDATE session_exercises se
SET name_en = e.name_en
FROM exercises e
WHERE se.id = e.id;

UPDATE session_exercises SET name_en = name WHERE name_en IS NULL;

ALTER TABLE session_exercises ALTER COLUMN name_en SET NOT NULL;

-- +goose Down

ALTER TABLE session_exercises DROP COLUMN name_en;
ALTER TABLE exercises DROP COLUMN name_en;
