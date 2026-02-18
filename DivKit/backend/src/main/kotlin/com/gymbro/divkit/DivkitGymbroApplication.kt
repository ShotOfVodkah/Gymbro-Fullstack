package com.gymbro.divkit

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class DivkitGymbroApplication

fun main(args: Array<String>) {
	runApplication<DivkitGymbroApplication>(*args)
}

val workouts: List<Workout> = listOf(

	Workout(
		id = "1",
		name = "Easy Run",
		type = WorkoutType.CARDIO,
		exercises = listOf(
			CardioExercise(
				id = "cardio_1_1",
				name = "Warm-up Walk",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 5,
				pace = PaceType.WALK
			),
			CardioExercise(
				id = "cardio_1_2",
				name = "Easy Jog",
				muscleGroup = MuscleGroup.LEGS,
				durationMinutes = 20,
				pace = PaceType.JOG
			),
			CardioExercise(
				id = "cardio_1_3",
				name = "Cool-down Walk",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 5,
				pace = PaceType.WALK
			)
		)
	),

	Workout(
		id = "2",
		name = "Chest Day",
		type = WorkoutType.STRENGTH,
		exercises = listOf(
			StrengthExercise(
				id = "strength_2_1",
				name = "Barbell Bench Press",
				muscleGroup = MuscleGroup.CHEST,
				sets = 4,
				reps = 10,
				weightKg = 60.0
			),
			StrengthExercise(
				id = "strength_2_2",
				name = "Incline Dumbbell Press",
				muscleGroup = MuscleGroup.CHEST,
				sets = 3,
				reps = 12,
				weightKg = 20.0
			),
			StrengthExercise(
				id = "strength_2_3",
				name = "Cable Flyes",
				muscleGroup = MuscleGroup.CHEST,
				sets = 3,
				reps = 15,
				weightKg = 15.0
			),
			StrengthExercise(
				id = "strength_2_4",
				name = "Push-ups",
				muscleGroup = MuscleGroup.CHEST,
				sets = 3,
				reps = 20,
				weightKg = 0.0
			)
		)
	),

	Workout(
		id = "5",
		name = "Morning Stretch",
		type = WorkoutType.YOGA,
		exercises = listOf(
			YogaExercise(
				id = "yoga_5_1",
				name = "Child's Pose",
				muscleGroup = MuscleGroup.BACK,
				holdSeconds = 60,
				breathCount = 8
			),
			YogaExercise(
				id = "yoga_5_2",
				name = "Cat-Cow Stretch",
				muscleGroup = MuscleGroup.CORE,
				holdSeconds = 45,
				breathCount = 10
			),
			YogaExercise(
				id = "yoga_5_3",
				name = "Seated Forward Bend",
				muscleGroup = MuscleGroup.LEGS,
				holdSeconds = 45,
				breathCount = 7
			),
			YogaExercise(
				id = "yoga_5_4",
				name = "Spinal Twist",
				muscleGroup = MuscleGroup.CORE,
				holdSeconds = 30,
				breathCount = 6
			),
			YogaExercise(
				id = "yoga_5_5",
				name = "Legs Up The Wall",
				muscleGroup = MuscleGroup.LEGS,
				holdSeconds = 90,
				breathCount = 12
			)
		)
	),
)

val premadeWorkouts: List<Workout> = listOf(

	Workout(
		id = "pm_1",
		name = "Full Body Burn",
		type = WorkoutType.STRENGTH,
		exercises = listOf(
			StrengthExercise(
				id = "pm_1_1",
				name = "Barbell Squats",
				muscleGroup = MuscleGroup.LEGS,
				sets = 4,
				reps = 8,
				weightKg = 80.0
			)
		)
	),

	Workout(
		id = "pm_2",
		name = "Fat Burn Cardio",
		type = WorkoutType.CARDIO,
		exercises = listOf(
			CardioExercise(
				id = "pm_2_1",
				name = "Warm-up Jog",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 5,
				pace = PaceType.JOG
			),
			CardioExercise(
				id = "pm_2_2",
				name = "Intervals",
				muscleGroup = MuscleGroup.LEGS,
				durationMinutes = 15,
				pace = PaceType.SPRINT
			),
			CardioExercise(
				id = "pm_2_3",
				name = "Cool-down Walk",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 5,
				pace = PaceType.WALK
			)
		)
	),

	Workout(
		id = "pm_3",
		name = "Premade Body Strength",
		type = WorkoutType.STRENGTH,
		exercises = listOf(
			StrengthExercise(
				id = "pm_3_1",
				name = "Overhead Press",
				muscleGroup = MuscleGroup.SHOULDERS,
				sets = 4,
				reps = 10,
				weightKg = 35.0
			),
			StrengthExercise(
				id = "pm_3_2",
				name = "Lat Pulldown",
				muscleGroup = MuscleGroup.BACK,
				sets = 4,
				reps = 12,
				weightKg = 45.0
			),
			StrengthExercise(
				id = "pm_3_3",
				name = "Dumbbell Curls",
				muscleGroup = MuscleGroup.BICEPS,
				sets = 3,
				reps = 15,
				weightKg = 12.0
			)
		)
	),

	Workout(
		id = "pm_4",
		name = "Morning Mobility",
		type = WorkoutType.YOGA,
		exercises = listOf(
			YogaExercise(
				id = "pm_4_1",
				name = "Sun Salutation A",
				muscleGroup = MuscleGroup.FULL_BODY,
				holdSeconds = 60,
				breathCount = 8
			),
			YogaExercise(
				id = "pm_4_2",
				name = "Downward Dog",
				muscleGroup = MuscleGroup.LEGS,
				holdSeconds = 45,
				breathCount = 6
			),
			YogaExercise(
				id = "pm_4_3",
				name = "Seated Twist",
				muscleGroup = MuscleGroup.CORE,
				holdSeconds = 30,
				breathCount = 5
			)
		)
	),

	Workout(
		id = "pm_5",
		name = "Premade Express",
		type = WorkoutType.CARDIO,
		exercises = listOf(
			CardioExercise(
				id = "pm_5_1",
				name = "Jump Rope",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 3,
				pace = PaceType.SPRINT
			),
			CardioExercise(
				id = "pm_5_2",
				name = "Burpees",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 2,
				pace = PaceType.SPRINT
			),
			CardioExercise(
				id = "pm_5_3",
				name = "Recovery Walk",
				muscleGroup = MuscleGroup.FULL_BODY,
				durationMinutes = 3,
				pace = PaceType.RECOVERY
			)
		)
	)
)

// Strength Exercises
val strengthExercises = listOf(
	StrengthExercise(
		id = "str_001",
		name = "Barbell Bench Press",
		muscleGroup = MuscleGroup.CHEST,
		sets = 4,
		reps = 8,
		weightKg = 80.0
	),
	StrengthExercise(
		id = "str_002",
		name = "Deadlift",
		muscleGroup = MuscleGroup.BACK,
		sets = 3,
		reps = 5,
		weightKg = 120.0
	),
	StrengthExercise(
		id = "str_003",
		name = "Barbell Squat",
		muscleGroup = MuscleGroup.LEGS,
		sets = 4,
		reps = 10,
		weightKg = 100.0
	),
	StrengthExercise(
		id = "str_004",
		name = "Overhead Press",
		muscleGroup = MuscleGroup.SHOULDERS,
		sets = 3,
		reps = 12,
		weightKg = 50.0
	),
	StrengthExercise(
		id = "str_005",
		name = "Pull Up",
		muscleGroup = MuscleGroup.BACK,
		sets = 3,
		reps = 8,
		weightKg = 0.0
	),
	StrengthExercise(
		id = "str_006",
		name = "Dumbbell Bicep Curl",
		muscleGroup = MuscleGroup.GLUTES,
		sets = 3,
		reps = 15,
		weightKg = 15.0
	),
	StrengthExercise(
		id = "str_007",
		name = "Leg Press",
		muscleGroup = MuscleGroup.LEGS,
		sets = 4,
		reps = 12,
		weightKg = 180.0
	),
	StrengthExercise(
		id = "str_008",
		name = "Barbell Row",
		muscleGroup = MuscleGroup.BACK,
		sets = 4,
		reps = 10,
		weightKg = 70.0
	)
)

// Cardio Exercises
val cardioExercises = listOf(
	CardioExercise(
		id = "car_001",
		name = "Easy Run",
		muscleGroup = MuscleGroup.FULL_BODY,
		durationMinutes = 30,
		pace = PaceType.JOG
	),
	CardioExercise(
		id = "car_002",
		name = "HIIT Sprint",
		muscleGroup = MuscleGroup.BACK,
		durationMinutes = 20,
		pace = PaceType.JOG
	),
	CardioExercise(
		id = "car_003",
		name = "Jump Rope",
		muscleGroup = MuscleGroup.CHEST,
		durationMinutes = 15,
		pace = PaceType.RUN
	),
	CardioExercise(
		id = "car_004",
		name = "Rowing Machine",
		muscleGroup = MuscleGroup.BACK,
		durationMinutes = 25,
		pace = PaceType.RUN
	),
	CardioExercise(
		id = "car_005",
		name = "Cycling",
		muscleGroup = MuscleGroup.LEGS,
		durationMinutes = 45,
		pace = PaceType.SPRINT
	),
	CardioExercise(
		id = "car_006",
		name = "Stair Climber",
		muscleGroup = MuscleGroup.LEGS,
		durationMinutes = 20,
		pace = PaceType.RECOVERY
	),
	CardioExercise(
		id = "car_007",
		name = "Swimming",
		muscleGroup = MuscleGroup.LEGS,
		durationMinutes = 40,
		pace = PaceType.JOG
	),
	CardioExercise(
		id = "car_008",
		name = "Elliptical",
		muscleGroup = MuscleGroup.FULL_BODY,
		durationMinutes = 35,
		pace = PaceType.WALK
	)
)

// Yoga Exercises
val yogaExercises = listOf(
	YogaExercise(
		id = "yog_001",
		name = "Downward Dog",
		muscleGroup = MuscleGroup.FULL_BODY,
		holdSeconds = 60,
		breathCount = 8
	),
	YogaExercise(
		id = "yog_002",
		name = "Warrior II",
		muscleGroup = MuscleGroup.LEGS,
		holdSeconds = 45,
		breathCount = 6
	),
	YogaExercise(
		id = "yog_003",
		name = "Tree Pose",
		muscleGroup = MuscleGroup.LEGS,
		holdSeconds = 30,
		breathCount = 5
	),
	YogaExercise(
		id = "yog_004",
		name = "Cobra Pose",
		muscleGroup = MuscleGroup.BACK,
		holdSeconds = 30,
		breathCount = 4
	),
	YogaExercise(
		id = "yog_005",
		name = "Bridge Pose",
		muscleGroup = MuscleGroup.GLUTES,
		holdSeconds = 45,
		breathCount = 6
	),
	YogaExercise(
		id = "yog_006",
		name = "Pigeon Pose",
		muscleGroup = MuscleGroup.LEGS,
		holdSeconds = 60,
		breathCount = 8
	),
	YogaExercise(
		id = "yog_007",
		name = "Shoulder Stand",
		muscleGroup = MuscleGroup.SHOULDERS,
		holdSeconds = 30,
		breathCount = 5
	),
	YogaExercise(
		id = "yog_008",
		name = "Child's Pose",
		muscleGroup = MuscleGroup.FULL_BODY,
		holdSeconds = 90,
		breathCount = 12
	)
)

