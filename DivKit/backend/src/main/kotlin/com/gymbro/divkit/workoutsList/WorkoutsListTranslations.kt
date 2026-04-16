package com.gymbro.divkit.workoutsList

import com.gymbro.divkit.Language
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.i18n.DomainStrings
import com.gymbro.divkit.i18n.LocalizedStrings

private enum class WorkoutsListKey {
    HEADER,
}

internal class WorkoutsListTranslations(
    language: Language,
) {
    private val domain = DomainStrings(language)
    private val strings = LocalizedStrings(
        language,
        mapOf(
            WorkoutsListKey.HEADER to mapOf(
                Language.EN to "My workouts",
                Language.RU to "Мои тренировки",
            ),
        ),
        "WorkoutsList",
    )

    fun header(): String = strings[WorkoutsListKey.HEADER]

    fun workoutType(type: WorkoutType): String = domain.workoutType(type)
}
