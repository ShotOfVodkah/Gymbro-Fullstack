-- +goose Up

INSERT INTO achievement_definitions (
    code,
    name,
    description,
    icon_name,
    category,
    rarity,
    target_value
) VALUES
('rookie', 'Rookie', 'First recorded workout', 'eyeglasses', 'workoutMilestones', 'common', 1),
('workouts_50', '50 Workouts', 'Completed 50 workouts', 'tortoise.fill', 'workoutMilestones', 'rare', 50),
('workouts_100', '100 Workouts', 'Completed 100 workouts', 'hare.fill', 'workoutMilestones', 'rare', 100),
('workouts_200', '200 Workouts', 'Completed 200 workouts', 'bolt.fill', 'workoutMilestones', 'epic', 200),
('workouts_300', '300 Workouts', 'Completed 300 workouts', 'ant.fill', 'workoutMilestones', 'epic', 300),
('workouts_400', '400 Workouts', 'Completed 400 workouts', 'bolt.car.fill', 'workoutMilestones', 'legendary', 400),
('workouts_500', '500 Workouts', 'Completed 500 workouts', 'crown.fill', 'workoutMilestones', 'legendary', 500),

('tough_day', 'Tough Day', 'Workout on a Monday', 'bed.double.fill', 'timeChallenges', 'common', 1),
('lazy_weekend', 'Lazy Weekend', 'Workout on Saturday or Sunday', 'beach.umbrella.fill', 'timeChallenges', 'common', 1),
('early_riser', 'Early Riser', 'Workout before 7 AM', 'sun.haze.fill', 'timeChallenges', 'rare', 1),
('night_owl', 'Night Owl', 'Workout after 11 PM', 'moon.stars.fill', 'timeChallenges', 'rare', 1),
('cinderella', 'Cinderella', 'Workout started exactly at 00:00', 'shoe.fill', 'timeChallenges', 'legendary', 1),

('busy_week', 'Busy week', '7 consecutive workouts', '7.calendar', 'consistency', 'epic', 7),
('consistent_start', 'Consistent Start', 'Completed weekly goal for the first time', 'calendar.badge.checkmark', 'consistency', 'common', 1),
('fire_keeper', 'Fire Keeper', 'Maintained a 4-week streak', 'flame.fill', 'consistency', 'rare', 4),
('unstoppable', 'Unstoppable', 'Maintained a 12-week streak', 'bolt.shield.fill', 'consistency', 'epic', 12),
('back_to_prime', 'Back to prime', 'Completed workout after missing a week', 'arrow.counterclockwise', 'consistency', 'rare', 1),
('locked_in', 'Locked in', 'Completed 20 workouts in a month', 'lock.fill', 'consistency', 'epic', 20),

('gymbro', 'GymBro', 'Shared at least one workout with a friend', 'figure.roll.runningpace', 'social', 'common', 1),
('pornstar', 'PornStar', 'Your post received 5+ comments', 'star.bubble.fill', 'social', 'rare', 5),
('social_butterfly', 'Social Butterfly', 'Shared 10 workouts', 'ladybug.fill', 'social', 'rare', 10),
('first_like', 'First Like', 'Received first like on a post', 'bolt.heart.fill', 'social', 'common', 1),
('main_character_energy', 'Main Character Energy', 'Received 50 total likes', 'camera.fill', 'social', 'epic', 50),
('busybody', 'Busybody', 'Opened another user’s profile', 'nose.fill', 'social', 'common', 1),
('backseat_driver', 'Backseat driver', 'Commented on a friend’s workout', 'text.bubble.fill', 'social', 'common', 1),

('less_words', 'Less words', 'Workout without comments or notes', 'microphone.slash.fill', 'special', 'common', 1),
('whole_body', 'Whor… whole body', 'Targeted 3 different muscle groups in one workout', 'figure.strengthtraining.functional', 'special', 'rare', 3),
('i_know_better', 'I know better', 'Created your own workout', 'pencil.and.outline', 'special', 'common', 1)

ON CONFLICT (code) DO UPDATE SET
    name = EXCLUDED.name,
    description = EXCLUDED.description,
    icon_name = EXCLUDED.icon_name,
    category = EXCLUDED.category,
    rarity = EXCLUDED.rarity,
    target_value = EXCLUDED.target_value,
    is_active = TRUE;

-- +goose Down

DELETE FROM achievement_definitions WHERE code IN (
    'rookie',
    'workouts_50',
    'workouts_100',
    'workouts_200',
    'workouts_300',
    'workouts_400',
    'workouts_500',
    'tough_day',
    'lazy_weekend',
    'early_riser',
    'night_owl',
    'busy_week',
    'cinderella',
    'less_words',
    'whole_body',
    'gymbro',
    'i_know_better',
    'pornstar',
    'consistent_start',
    'fire_keeper',
    'unstoppable',
    'social_butterfly',
    'first_like',
    'main_character_energy',
    'busybody',
    'back_to_prime',
    'backseat_driver',
    'locked_in'
);