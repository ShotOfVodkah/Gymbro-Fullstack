package com.gymbro.divkit.client

import com.gymbro.divkit.CardioExercise
import com.gymbro.divkit.MuscleGroup
import com.gymbro.divkit.PaceType
import com.gymbro.divkit.StrengthExercise
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.YogaExercise
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class BackendMappersTest {

    @Test
    fun `WorkoutDto toDomain maps type and exercises`() {
        val dto = WorkoutDto(
            id = "w1",
            name = "My",
            type = "Cardio",
            exercises = listOf(
                WorkoutExerciseDto(
                    id = "e1",
                    name = "Run",
                    type = "cardio",
                    muscleGroup = "legs",
                    durationMinutes = 30,
                    pace = "sprint",
                ),
            ),
        )
        val w = dto.toDomain()
        assertThat(w.id).isEqualTo("w1")
        assertThat(w.type).isEqualTo(WorkoutType.CARDIO)
        assertThat(w.exercises).hasSize(1)
        val ex = w.exercises[0] as CardioExercise
        assertThat(ex.durationMinutes).isEqualTo(30)
        assertThat(ex.pace).isEqualTo(PaceType.SPRINT)
        assertThat(ex.muscleGroup).isEqualTo(MuscleGroup.LEGS)
    }

    @Test
    fun `WorkoutExerciseDto strength branch`() {
        val ex = WorkoutExerciseDto(
            id = "e1",
            name = "Press",
            type = "STRENGTH",
            muscleGroup = "Chest",
            sets = 3,
            reps = 10,
            weightKg = 20.5,
        ).toExercise() as StrengthExercise
        assertThat(ex.sets).isEqualTo(3)
        assertThat(ex.reps).isEqualTo(10)
        assertThat(ex.weightKg).isEqualTo(20.5)
        assertThat(ex.muscleGroup).isEqualTo(MuscleGroup.CHEST)
    }

    @Test
    fun `WorkoutExerciseDto yoga branch`() {
        val ex = WorkoutExerciseDto(
            id = "e1",
            name = "Pose",
            type = "yoga",
            muscleGroup = "core",
            holdSeconds = 60,
            breathCount = 12,
        ).toExercise() as YogaExercise
        assertThat(ex.holdSeconds).isEqualTo(60)
        assertThat(ex.breathCount).isEqualTo(12)
    }

    @Test
    fun `WorkoutExerciseDto unknown type defaults to strength`() {
        val ex = WorkoutExerciseDto(
            id = "e1",
            name = "X",
            type = "unknown",
            muscleGroup = "unknown_muscle",
        ).toExercise() as StrengthExercise
        assertThat(ex.sets).isZero()
    }

    @Test
    fun `ExerciseCatalogDto toExercise`() {
        val ex = ExerciseCatalogDto("c1", "Cat", "YOGA", "glutes").toExercise() as YogaExercise
        assertThat(ex.muscleGroup).isEqualTo(MuscleGroup.GLUTES)
    }

    @Test
    fun `WorkoutSessionDto toWorkout`() {
        val session = WorkoutSessionDto(
            id = "s1",
            userId = "u1",
            workoutName = "Session",
            workoutType = "yoga",
            exercises = emptyList(),
        )
        val w = session.toWorkout()
        assertThat(w.id).isEqualTo("s1")
        assertThat(w.name).isEqualTo("Session")
        assertThat(w.type).isEqualTo(WorkoutType.YOGA)
    }

    @Test
    fun `cardio pace mapping walk and medium`() {
        val walk = WorkoutExerciseDto("1", "a", "cardio", "legs", durationMinutes = 1, pace = "walk").toExercise() as CardioExercise
        assertThat(walk.pace).isEqualTo(PaceType.WALK)
        val medium = WorkoutExerciseDto("2", "b", "cardio", "legs", durationMinutes = 1, pace = "medium").toExercise() as CardioExercise
        assertThat(medium.pace).isEqualTo(PaceType.JOG)
    }
}
