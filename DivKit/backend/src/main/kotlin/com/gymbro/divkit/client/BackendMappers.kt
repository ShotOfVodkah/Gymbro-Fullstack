package com.gymbro.divkit.client

import com.gymbro.divkit.CardioExercise
import com.gymbro.divkit.Exercise
import com.gymbro.divkit.MuscleGroup
import com.gymbro.divkit.PaceType
import com.gymbro.divkit.StrengthExercise
import com.gymbro.divkit.Workout
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.YogaExercise

fun WorkoutDto.toDomain(): Workout = Workout(
    id = id,
    name = name,
    type = type.toWorkoutType(),
    exercises = exercises.map { it.toExercise() }
)

fun WorkoutExerciseDto.toExercise(): Exercise {
    val mg = muscleGroup.toMuscleGroup()
    return when (type.lowercase()) {
        "strength" -> StrengthExercise(
            id = id,
            name = name,
            muscleGroup = mg,
            sets = sets ?: 0,
            reps = reps ?: 0,
            weightKg = weightKg ?: 0.0
        )
        "cardio" -> CardioExercise(
            id = id,
            name = name,
            muscleGroup = mg,
            durationMinutes = durationMinutes ?: 0,
            pace = pace.toPaceType()
        )
        "yoga" -> YogaExercise(
            id = id,
            name = name,
            muscleGroup = mg,
            holdSeconds = holdSeconds ?: 0,
            breathCount = breathCount ?: 0
        )
        else -> StrengthExercise(id = id, name = name, muscleGroup = mg, sets = 0, reps = 0, weightKg = 0.0)
    }
}

fun ExerciseCatalogDto.toExercise(): Exercise {
    val mg = muscleGroup.toMuscleGroup()
    return when (type.lowercase()) {
        "strength" -> StrengthExercise(id = id, name = name, muscleGroup = mg, sets = 0, reps = 0, weightKg = 0.0)
        "cardio" -> CardioExercise(id = id, name = name, muscleGroup = mg, durationMinutes = 0, pace = PaceType.JOG)
        "yoga" -> YogaExercise(id = id, name = name, muscleGroup = mg, holdSeconds = 0, breathCount = 0)
        else -> StrengthExercise(id = id, name = name, muscleGroup = mg, sets = 0, reps = 0, weightKg = 0.0)
    }
}

private fun String.toWorkoutType(): WorkoutType = when (lowercase()) {
    "strength" -> WorkoutType.STRENGTH
    "cardio" -> WorkoutType.CARDIO
    "yoga" -> WorkoutType.YOGA
    else -> WorkoutType.STRENGTH
}

private fun String.toMuscleGroup(): MuscleGroup = when (lowercase()) {
    "chest" -> MuscleGroup.CHEST
    "back" -> MuscleGroup.BACK
    "shoulders" -> MuscleGroup.SHOULDERS
    "biceps" -> MuscleGroup.BICEPS
    "triceps" -> MuscleGroup.TRICEPS
    "legs" -> MuscleGroup.LEGS
    "glutes" -> MuscleGroup.GLUTES
    "core" -> MuscleGroup.CORE
    "full_body", "fullbody", "full body" -> MuscleGroup.FULL_BODY
    else -> MuscleGroup.FULL_BODY
}

private fun String?.toPaceType(): PaceType = when (this?.lowercase()) {
    "walk" -> PaceType.WALK
    "jog" -> PaceType.JOG
    "run" -> PaceType.RUN
    "sprint" -> PaceType.SPRINT
    "recovery" -> PaceType.RECOVERY
    "medium" -> PaceType.JOG
    "slow" -> PaceType.WALK
    "fast" -> PaceType.RUN
    else -> PaceType.JOG
}
