package com.gymbro.divkit.workoutBuilderSheet

import com.gymbro.divkit.Language
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.i18n.DomainStrings
import com.gymbro.divkit.i18n.ExerciseCardStrings
import com.gymbro.divkit.i18n.LocalizedStrings
import com.gymbro.divkit.i18n.exerciseCountLabel

private enum class WorkoutBuilderSheetKey {
    ADD_TO_MY_WORKOUTS,
}

class WorkoutBuilderSheetTranslations(
    private val language: Language,
) {
    private val domain = DomainStrings(language)
    private val strings = LocalizedStrings(
        language,
        mapOf(
            WorkoutBuilderSheetKey.ADD_TO_MY_WORKOUTS to mapOf(
                Language.EN to "Add to my workouts",
                Language.RU to "Добавить в мои тренировки",
            ),
        ),
        "WorkoutBuilderSheet",
    )

    val exerciseCard: ExerciseCardStrings = ExerciseCardStrings(language)

    fun addToMyWorkouts(): String = strings[WorkoutBuilderSheetKey.ADD_TO_MY_WORKOUTS]

    fun workoutType(type: WorkoutType): String = domain.workoutType(type)

    fun exerciseCount(count: Int): String = exerciseCountLabel(language, count)
}
