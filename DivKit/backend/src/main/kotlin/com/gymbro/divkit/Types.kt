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


fun styleFor(type: WorkoutType, assetsBaseUrl: String): WorkoutStyle {
    val base = assetsBaseUrl.trimEnd('/')
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

data class WorkoutStyle(
    val backgroundColor: String,
    val iconUrl: String
)