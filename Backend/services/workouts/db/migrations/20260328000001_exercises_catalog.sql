-- +goose Up

CREATE TABLE exercises (
    id          TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    type        TEXT NOT NULL,
    muscle_group TEXT NOT NULL
);

CREATE TABLE workout_exercises (
    id               SERIAL PRIMARY KEY,
    workout_id       TEXT NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
    exercise_id      TEXT NOT NULL REFERENCES exercises(id),
    position         INT  NOT NULL DEFAULT 0,
    sets             INT,
    reps             INT,
    weight_kg        FLOAT,
    duration_minutes INT,
    pace             TEXT,
    hold_seconds     INT,
    breath_count     INT
);

ALTER TABLE workouts DROP COLUMN exercises;

INSERT INTO exercises (id, name, type, muscle_group) VALUES
    ('bench-press',       'Жим лёжа',              'strength', 'chest'),
    ('incline-press',     'Жим на наклонной',      'strength', 'chest'),
    ('dumbbell-fly',      'Разводка с гантелями',  'strength', 'chest'),
    ('pull-up',           'Подтягивания',           'strength', 'back'),
    ('barbell-row',       'Тяга штанги в наклоне', 'strength', 'back'),
    ('deadlift',          'Становая тяга',          'strength', 'back'),
    ('overhead-press',    'Жим над головой',        'strength', 'shoulders'),
    ('lateral-raise',     'Махи в стороны',         'strength', 'shoulders'),
    ('barbell-curl',      'Сгибание со штангой',    'strength', 'biceps'),
    ('hammer-curl',       'Молотки',                'strength', 'biceps'),
    ('tricep-pushdown',   'Разгибание на блоке',    'strength', 'triceps'),
    ('skull-crusher',     'Французский жим',        'strength', 'triceps'),
    ('squat',             'Приседания',             'strength', 'legs'),
    ('leg-press',         'Жим ногами',             'strength', 'legs'),
    ('lunge',             'Выпады',                 'strength', 'legs'),
    ('plank',             'Планка',                 'strength', 'core'),
    ('crunch',            'Скручивания',            'strength', 'core');

INSERT INTO exercises (id, name, type, muscle_group) VALUES
    ('running',           'Бег',                   'cardio', 'legs'),
    ('cycling',           'Велосипед',              'cardio', 'legs'),
    ('rowing',            'Гребля',                 'cardio', 'back'),
    ('jump-rope',         'Скакалка',               'cardio', 'legs'),
    ('elliptical',        'Эллиптический тренажёр', 'cardio', 'legs'),
    ('swimming',          'Плавание',               'cardio', 'full_body');

INSERT INTO exercises (id, name, type, muscle_group) VALUES
    ('warrior-1',         'Поза воина I',           'yoga', 'legs'),
    ('warrior-2',         'Поза воина II',          'yoga', 'legs'),
    ('downward-dog',      'Собака мордой вниз',     'yoga', 'back'),
    ('child-pose',        'Поза ребёнка',           'yoga', 'back'),
    ('tree-pose',         'Поза дерева',            'yoga', 'legs'),
    ('cobra',             'Кобра',                  'yoga', 'back'),
    ('pigeon-pose',       'Поза голубя',            'yoga', 'legs');

-- +goose Down
DROP TABLE workout_exercises;
DROP TABLE exercises;
ALTER TABLE workouts ADD COLUMN exercises JSONB NOT NULL DEFAULT '[]';
