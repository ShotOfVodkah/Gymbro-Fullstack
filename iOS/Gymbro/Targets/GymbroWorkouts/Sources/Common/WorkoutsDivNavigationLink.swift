import Foundation
import DivKit

import GymbroTypes

enum WorkoutsNavigationLink {
    case openWorkout(id: String)
    case openBuilder
    case openStreak(current: Int, goal: Int, daysLeft: Int, value: Int)
}

enum WorkoutInfoNavigationLink {
    case openPlayer(id: String)
    case delete(id: String)
    case edit(id: String)
}

enum WorkoutBuilderTitleNavigationLink {
    case savePremade(id: String)
    case openPremade(id: String)
    case openBuilder(type: String)
    case openAI
}

enum WorkoutBuilderForTypeNavigationLink {
    case add(id: String)
    case remove(id: String)
}

final class NoopDivUrlHandler: DivUrlHandler {
    func handle(_ url: URL, sender: AnyObject?) { }
}

// Mocks

var workoutsMock: [Workout] = [
    Workout(
        id: "1",
        name: "Easy Run",
        type: .cardio,
        exercises: [
            CardioExercise(
                id: "cardio_1_1",
                name: "Warm-up Walk",
                muscleGroup: .fullBody,
                durationMinutes: 5,
                pace: .walk
            ),
            CardioExercise(
                id: "cardio_1_2",
                name: "Easy Jog",
                muscleGroup: .legs,
                durationMinutes: 20,
                pace: .jog
            ),
            CardioExercise(
                id: "cardio_1_3",
                name: "Cool-down Walk",
                muscleGroup: .fullBody,
                durationMinutes: 5,
                pace: .walk
            )
        ]
    ),
    Workout(
        id: "2",
        name: "Chest Day",
        type: .strength,
        exercises: [
            StrengthExercise(
                id: "strength_2_1",
                name: "Barbell Bench Press",
                muscleGroup: .chest,
                sets: 4,
                reps: 10,
                weightKg: 60.0
            ),
            StrengthExercise(
                id: "strength_2_2",
                name: "Incline Dumbbell Press",
                muscleGroup: .chest,
                sets: 3,
                reps: 12,
                weightKg: 20.0
            ),
            StrengthExercise(
                id: "strength_2_3",
                name: "Cable Flyes",
                muscleGroup: .chest,
                sets: 3,
                reps: 15,
                weightKg: 15.0
            ),
            StrengthExercise(
                id: "strength_2_4",
                name: "Push-ups",
                muscleGroup: .chest,
                sets: 3,
                reps: 20,
                weightKg: 0.0
            )
        ]
    ),
    Workout(
        id: "5",
        name: "Morning Stretch",
        type: .yoga,
        exercises: [
            YogaExercise(
                id: "yoga_5_1",
                name: "Child's Pose",
                muscleGroup: .back,
                holdSeconds: 60,
                breathCount: 8
            ),
            YogaExercise(
                id: "yoga_5_2",
                name: "Cat-Cow Stretch",
                muscleGroup: .core,
                holdSeconds: 45,
                breathCount: 10
            ),
            YogaExercise(
                id: "yoga_5_3",
                name: "Seated Forward Bend",
                muscleGroup: .legs,
                holdSeconds: 45,
                breathCount: 7
            ),
            YogaExercise(
                id: "yoga_5_4",
                name: "Spinal Twist",
                muscleGroup: .core,
                holdSeconds: 30,
                breathCount: 6
            ),
            YogaExercise(
                id: "yoga_5_5",
                name: "Legs Up The Wall",
                muscleGroup: .legs,
                holdSeconds: 90,
                breathCount: 12
            )
        ]
    )
]

var premadeWorkouts: [Workout] = [
    Workout(
        id: "pm_1",
        name: "Full Body Burn",
        type: .strength,
        exercises: [
            StrengthExercise(
                id: "pm_1_1",
                name: "Barbell Squats",
                muscleGroup: .legs,
                sets: 4,
                reps: 8,
                weightKg: 80.0
            ),
            StrengthExercise(
                id: "pm_1_2",
                name: "Pull-ups",
                muscleGroup: .back,
                sets: 4,
                reps: 10,
                weightKg: 0.0
            ),
            StrengthExercise(
                id: "pm_1_3",
                name: "Bench Press",
                muscleGroup: .chest,
                sets: 4,
                reps: 8,
                weightKg: 70.0
            )
        ]
    ),

    Workout(
        id: "pm_2",
        name: "Fat Burn Cardio",
        type: .cardio,
        exercises: [
            CardioExercise(
                id: "pm_2_1",
                name: "Warm-up Jog",
                muscleGroup: .fullBody,
                durationMinutes: 5,
                pace: .jog
            ),
            CardioExercise(
                id: "pm_2_2",
                name: "Intervals",
                muscleGroup: .legs,
                durationMinutes: 15,
                pace: .sprint
            ),
            CardioExercise(
                id: "pm_2_3",
                name: "Cool-down Walk",
                muscleGroup: .fullBody,
                durationMinutes: 5,
                pace: .walk
            )
        ]
    ),

    Workout(
        id: "pm_3",
        name: "Premade Body Strength",
        type: .strength,
        exercises: [
            StrengthExercise(
                id: "pm_3_1",
                name: "Overhead Press",
                muscleGroup: .shoulders,
                sets: 4,
                reps: 10,
                weightKg: 35.0
            ),
            StrengthExercise(
                id: "pm_3_2",
                name: "Lat Pulldown",
                muscleGroup: .back,
                sets: 4,
                reps: 12,
                weightKg: 45.0
            ),
            StrengthExercise(
                id: "pm_3_3",
                name: "Dumbbell Curls",
                muscleGroup: .biceps,
                sets: 3,
                reps: 15,
                weightKg: 12.0
            )
        ]
    ),

    Workout(
        id: "pm_4",
        name: "Morning Mobility",
        type: .yoga,
        exercises: [
            YogaExercise(
                id: "pm_4_1",
                name: "Sun Salutation A",
                muscleGroup: .fullBody,
                holdSeconds: 60,
                breathCount: 8
            ),
            YogaExercise(
                id: "pm_4_2",
                name: "Downward Dog",
                muscleGroup: .legs,
                holdSeconds: 45,
                breathCount: 6
            ),
            YogaExercise(
                id: "pm_4_3",
                name: "Seated Twist",
                muscleGroup: .core,
                holdSeconds: 30,
                breathCount: 5
            )
        ]
    ),

    Workout(
        id: "pm_5",
        name: "Premade Express",
        type: .cardio,
        exercises: [
            CardioExercise(
                id: "pm_5_1",
                name: "Jump Rope",
                muscleGroup: .fullBody,
                durationMinutes: 3,
                pace: .sprint
            ),
            CardioExercise(
                id: "pm_5_2",
                name: "Burpees",
                muscleGroup: .fullBody,
                durationMinutes: 2,
                pace: .sprint
            ),
            CardioExercise(
                id: "pm_5_3",
                name: "Recovery Walk",
                muscleGroup: .fullBody,
                durationMinutes: 3,
                pace: .recovery
            )
        ]
    )
]

// Strength Exercises
let strengthExercises: [StrengthExercise] = [
    StrengthExercise(
        id: "str_001",
        name: "Barbell Bench Press",
        muscleGroup: .chest,
        sets: 4,
        reps: 8,
        weightKg: 80.0
    ),
    StrengthExercise(
        id: "str_002",
        name: "Deadlift",
        muscleGroup: .back,
        sets: 3,
        reps: 5,
        weightKg: 120.0
    ),
    StrengthExercise(
        id: "str_003",
        name: "Barbell Squat",
        muscleGroup: .legs,
        sets: 4,
        reps: 10,
        weightKg: 100.0
    ),
    StrengthExercise(
        id: "str_004",
        name: "Overhead Press",
        muscleGroup: .shoulders,
        sets: 3,
        reps: 12,
        weightKg: 50.0
    ),
    StrengthExercise(
        id: "str_005",
        name: "Pull Up",
        muscleGroup: .back,
        sets: 3,
        reps: 8,
        weightKg: 0.0
    ),
    StrengthExercise(
        id: "str_006",
        name: "Dumbbell Bicep Curl",
        muscleGroup: .glutes,
        sets: 3,
        reps: 15,
        weightKg: 15.0
    ),
    StrengthExercise(
        id: "str_007",
        name: "Leg Press",
        muscleGroup: .legs,
        sets: 4,
        reps: 12,
        weightKg: 180.0
    ),
    StrengthExercise(
        id: "str_008",
        name: "Barbell Row",
        muscleGroup: .back,
        sets: 4,
        reps: 10,
        weightKg: 70.0
    )
]

// Cardio Exercises
let cardioExercises: [CardioExercise] = [
    CardioExercise(
        id: "car_001",
        name: "Easy Run",
        muscleGroup: .fullBody,
        durationMinutes: 30,
        pace: .jog
    ),
    CardioExercise(
        id: "car_002",
        name: "HIIT Sprint",
        muscleGroup: .back,
        durationMinutes: 20,
        pace: .jog
    ),
    CardioExercise(
        id: "car_003",
        name: "Jump Rope",
        muscleGroup: .chest,
        durationMinutes: 15,
        pace: .run
    ),
    CardioExercise(
        id: "car_004",
        name: "Rowing Machine",
        muscleGroup: .back,
        durationMinutes: 25,
        pace: .run
    ),
    CardioExercise(
        id: "car_005",
        name: "Cycling",
        muscleGroup: .legs,
        durationMinutes: 45,
        pace: .sprint
    ),
    CardioExercise(
        id: "car_006",
        name: "Stair Climber",
        muscleGroup: .legs,
        durationMinutes: 20,
        pace: .recovery
    ),
    CardioExercise(
        id: "car_007",
        name: "Swimming",
        muscleGroup: .legs,
        durationMinutes: 40,
        pace: .jog
    ),
    CardioExercise(
        id: "car_008",
        name: "Elliptical",
        muscleGroup: .fullBody,
        durationMinutes: 35,
        pace: .walk
    )
]

// Yoga Exercises
let yogaExercises: [YogaExercise] = [
    YogaExercise(
        id: "yog_001",
        name: "Downward Dog",
        muscleGroup: .fullBody,
        holdSeconds: 60,
        breathCount: 8
    ),
    YogaExercise(
        id: "yog_002",
        name: "Warrior II",
        muscleGroup: .legs,
        holdSeconds: 45,
        breathCount: 6
    ),
    YogaExercise(
        id: "yog_003",
        name: "Tree Pose",
        muscleGroup: .legs,
        holdSeconds: 30,
        breathCount: 5
    ),
    YogaExercise(
        id: "yog_004",
        name: "Cobra Pose",
        muscleGroup: .back,
        holdSeconds: 30,
        breathCount: 4
    ),
    YogaExercise(
        id: "yog_005",
        name: "Bridge Pose",
        muscleGroup: .glutes,
        holdSeconds: 45,
        breathCount: 6
    ),
    YogaExercise(
        id: "yog_006",
        name: "Pigeon Pose",
        muscleGroup: .legs,
        holdSeconds: 60,
        breathCount: 8
    ),
    YogaExercise(
        id: "yog_007",
        name: "Shoulder Stand",
        muscleGroup: .shoulders,
        holdSeconds: 30,
        breathCount: 5
    ),
    YogaExercise(
        id: "yog_008",
        name: "Child's Pose",
        muscleGroup: .fullBody,
        holdSeconds: 90,
        breathCount: 12
    )
]
