package com.gymbro.divkit

enum class WorkoutType {
    STRENGTH,
    CARDIO,
    YOGA
}

enum class PaceType {
    WALK,
    JOG,
    RUN,
    SPRINT,
    RECOVERY
}

enum class MuscleGroup {
    CHEST,
    BACK,
    SHOULDERS,
    BICEPS,
    TRICEPS,
    LEGS,
    GLUTES,
    CORE,
    FULL_BODY
}

sealed class Exercise(
    open val id: String,
    open val name: String,
    open val muscleGroup: MuscleGroup
)

data class StrengthExercise(
    override val id: String,
    override val name: String,
    override val muscleGroup: MuscleGroup,
    val sets: Int,
    val reps: Int,
    val weightKg: Double
) : Exercise(id, name, muscleGroup)

data class CardioExercise(
    override val id: String,
    override val name: String,
    override val muscleGroup: MuscleGroup,
    val durationMinutes: Int,
    val pace: PaceType,
) : Exercise(id, name, muscleGroup)

data class YogaExercise(
    override val id: String,
    override val name: String,
    override val muscleGroup: MuscleGroup,
    val holdSeconds: Int,
    val breathCount: Int
) : Exercise(id, name, muscleGroup)

data class Workout(
    val id: String,
    val name: String,
    val type: WorkoutType,
    val exercises: List<Exercise>
)

// HELPERS

fun typeTitle(type: WorkoutType): String = when (type) {
    WorkoutType.STRENGTH -> "Strength"
    WorkoutType.CARDIO -> "Cardio"
    WorkoutType.YOGA -> "Yoga"
}

fun styleFor(type: WorkoutType): WorkoutStyle {
    val base = "http://localhost:8090/assets"
    return when (type) {
        WorkoutType.STRENGTH -> WorkoutStyle(
            backgroundColor = "#2E27FF",
            iconUrl = "$base/strength.png"
        )
        WorkoutType.CARDIO -> WorkoutStyle(
            backgroundColor = "#BC31CF",
            iconUrl = "$base/cardio.png"
        )
        WorkoutType.YOGA -> WorkoutStyle(
            backgroundColor = "#73FF7A",
            iconUrl = "$base/yoga.png"
        )
    }
}

fun nameFor(type: MuscleGroup): String {
    return when (type) {
        MuscleGroup.CHEST -> "Chest"
        MuscleGroup.BACK -> "Back"
        MuscleGroup.SHOULDERS -> "Shoulders"
        MuscleGroup.BICEPS -> "Biceps"
        MuscleGroup.TRICEPS -> "Triceps"
        MuscleGroup.LEGS -> "Legs"
        MuscleGroup.GLUTES -> "Glutes"
        MuscleGroup.CORE -> "Core"
        MuscleGroup.FULL_BODY -> "Full body"
    }
}

fun nameFor(type: PaceType): String {
    return when (type) {
        PaceType.SPRINT -> "Sprint"
        PaceType.WALK -> "Walk"
        PaceType.JOG -> "Jog"
        PaceType.RECOVERY -> "Recovery"
        PaceType.RUN -> "Run"
    }
}

data class WorkoutStyle(
    val backgroundColor: String,
    val iconUrl: String
)