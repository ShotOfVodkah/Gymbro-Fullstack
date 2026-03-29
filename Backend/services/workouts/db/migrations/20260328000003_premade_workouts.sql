-- +goose Up

INSERT INTO workouts (id, user_id, name, type) VALUES
    ('premade-1', 'premade', 'Грудь и трицепс', 'strength'),
    ('premade-2', 'premade', 'Спина и бицепс',  'strength'),
    ('premade-3', 'premade', 'Ноги',             'strength'),
    ('premade-4', 'premade', 'Плечи и пресс',   'strength'),
    ('premade-5', 'premade', 'Кардио',           'cardio'),
    ('premade-6', 'premade', 'Йога для расслабления', 'yoga');

INSERT INTO workout_exercises (workout_id, exercise_id, position, sets, reps, weight_kg) VALUES
    ('premade-1', 'bench-press',     0, 4, 10, 60),
    ('premade-1', 'incline-press',   1, 3, 12, 50),
    ('premade-1', 'dumbbell-fly',    2, 3, 15, 16),
    ('premade-1', 'tricep-pushdown', 3, 3, 12, 25),
    ('premade-1', 'skull-crusher',   4, 3, 10, 20);

INSERT INTO workout_exercises (workout_id, exercise_id, position, sets, reps, weight_kg) VALUES
    ('premade-2', 'pull-up',      0, 4, 8,  10),
    ('premade-2', 'barbell-row',  1, 4, 10, 60),
    ('premade-2', 'deadlift',     2, 3, 6,  100),
    ('premade-2', 'barbell-curl', 3, 3, 12, 20),
    ('premade-2', 'hammer-curl',  4, 3, 12, 16);

INSERT INTO workout_exercises (workout_id, exercise_id, position, sets, reps, weight_kg) VALUES
    ('premade-3', 'squat',     0, 4, 10, 80),
    ('premade-3', 'leg-press', 1, 3, 15, 120),
    ('premade-3', 'lunge',     2, 3, 12, 20);

INSERT INTO workout_exercises (workout_id, exercise_id, position, sets, reps, weight_kg) VALUES
    ('premade-4', 'overhead-press', 0, 4, 10, 40),
    ('premade-4', 'lateral-raise',  1, 3, 15, 8),
    ('premade-4', 'plank',          2, 3, 1, 0),
    ('premade-4', 'crunch',         3, 3, 20, 0);

INSERT INTO workout_exercises (workout_id, exercise_id, position, duration_minutes, pace) VALUES
    ('premade-5', 'running',   0, 20, 'run'),
    ('premade-5', 'jump-rope', 1, 10, 'jog'),
    ('premade-5', 'cycling',   2, 15, 'jog');

INSERT INTO workout_exercises (workout_id, exercise_id, position, hold_seconds, breath_count) VALUES
    ('premade-6', 'warrior-1',    0, 30, 5),
    ('premade-6', 'downward-dog', 1, 45, 8),
    ('premade-6', 'child-pose',   2, 60, 10),
    ('premade-6', 'cobra',        3, 30, 5),
    ('premade-6', 'tree-pose',    4, 30, 5);

-- +goose Down

DELETE FROM workouts WHERE user_id = 'premade';
