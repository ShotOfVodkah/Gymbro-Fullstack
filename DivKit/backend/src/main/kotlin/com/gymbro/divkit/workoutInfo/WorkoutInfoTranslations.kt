package com.gymbro.divkit.workoutInfo

import com.gymbro.divkit.Language
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.i18n.DomainStrings
import com.gymbro.divkit.i18n.ExerciseCardStrings
import com.gymbro.divkit.i18n.LocalizedStrings
import com.gymbro.divkit.i18n.exerciseCountLabel

private enum class WorkoutInfoKey {
    EXERCISES_SECTION,
    START_WORKOUT,
    ADD_TO_MY_WORKOUTS,
}

class WorkoutInfoTranslations(
    private val language: Language,
) {
    private val domain = DomainStrings(language)
    private val strings = LocalizedStrings(
        language,
        mapOf(
            WorkoutInfoKey.EXERCISES_SECTION to mapOf(Language.EN to "EXERCISES", Language.RU to "УПРАЖНЕНИЯ"),
            WorkoutInfoKey.START_WORKOUT to mapOf(Language.EN to "Start Workout", Language.RU to "Начать тренировку"),
            WorkoutInfoKey.ADD_TO_MY_WORKOUTS to mapOf(Language.EN to "Add to my workouts", Language.RU to "Добавить в мои тренировки"),
        ),
        "WorkoutInfo",
    )

    val exerciseCard: ExerciseCardStrings = ExerciseCardStrings(language)

    fun exercisesSection(): String = strings[WorkoutInfoKey.EXERCISES_SECTION]

    fun startWorkout(): String = strings[WorkoutInfoKey.START_WORKOUT]

    fun addToMyWorkouts(): String = strings[WorkoutInfoKey.ADD_TO_MY_WORKOUTS]

    fun workoutType(type: WorkoutType): String = domain.workoutType(type)

    fun exerciseCount(count: Int): String = exerciseCountLabel(language, count)
}
