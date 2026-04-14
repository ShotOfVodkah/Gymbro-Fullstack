package com.gymbro.divkit.client

import com.fasterxml.jackson.annotation.JsonIgnoreProperties

data class ExerciseCatalogDto(
    val id: String,
    val name: String,
    val type: String,
    val muscleGroup: String
)

data class WorkoutExerciseDto(
    val id: String,
    val name: String,
    val type: String,
    val muscleGroup: String,
    val sets: Int? = null,
    val reps: Int? = null,
    val weightKg: Double? = null,
    val durationMinutes: Int? = null,
    val pace: String? = null,
    val holdSeconds: Int? = null,
    val breathCount: Int? = null
)

data class WorkoutDto(
    val id: String,
    val userId: String? = null,
    val name: String,
    val type: String,
    val exercises: List<WorkoutExerciseDto>
)

@JsonIgnoreProperties(ignoreUnknown = true)
data class WorkoutSessionDto(
    val id: String,
    val userId: String,
    val workoutId: String? = null,
    val workoutName: String,
    val workoutType: String,
    val exercises: List<WorkoutExerciseDto>
)
