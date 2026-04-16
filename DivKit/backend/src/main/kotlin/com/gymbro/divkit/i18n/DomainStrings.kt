package com.gymbro.divkit.i18n

import com.gymbro.divkit.Language
import com.gymbro.divkit.MuscleGroup
import com.gymbro.divkit.PaceType
import com.gymbro.divkit.WorkoutType

class DomainStrings(private val language: Language) {

    fun workoutType(type: WorkoutType): String =
        workoutTypeLabels[type]?.get(language)
            ?: workoutTypeLabels[type]?.get(Language.EN)
            ?: type.name

    fun muscle(group: MuscleGroup): String =
        muscleLabels[group]?.get(language)
            ?: muscleLabels[group]?.get(Language.EN)
            ?: group.name

    fun pace(pace: PaceType): String =
        paceLabels[pace]?.get(language)
            ?: paceLabels[pace]?.get(Language.EN)
            ?: pace.name

    companion object {
        fun workoutTypeQueryParam(type: WorkoutType): String = type.name.lowercase()

        private val workoutTypeLabels: Map<WorkoutType, Map<Language, String>> = mapOf(
            WorkoutType.STRENGTH to mapOf(Language.EN to "Strength", Language.RU to "Силовая"),
            WorkoutType.CARDIO to mapOf(Language.EN to "Cardio", Language.RU to "Кардио"),
            WorkoutType.YOGA to mapOf(Language.EN to "Yoga", Language.RU to "Йога"),
        )

        private val muscleLabels: Map<MuscleGroup, Map<Language, String>> = mapOf(
            MuscleGroup.CHEST to mapOf(Language.EN to "Chest", Language.RU to "Грудь"),
            MuscleGroup.BACK to mapOf(Language.EN to "Back", Language.RU to "Спина"),
            MuscleGroup.SHOULDERS to mapOf(Language.EN to "Shoulders", Language.RU to "Плечи"),
            MuscleGroup.BICEPS to mapOf(Language.EN to "Biceps", Language.RU to "Бицепс"),
            MuscleGroup.TRICEPS to mapOf(Language.EN to "Triceps", Language.RU to "Трицепс"),
            MuscleGroup.LEGS to mapOf(Language.EN to "Legs", Language.RU to "Ноги"),
            MuscleGroup.GLUTES to mapOf(Language.EN to "Glutes", Language.RU to "Ягодицы"),
            MuscleGroup.CORE to mapOf(Language.EN to "Core", Language.RU to "Кор"),
            MuscleGroup.FULL_BODY to mapOf(Language.EN to "Full body", Language.RU to "Все тело"),
        )

        private val paceLabels: Map<PaceType, Map<Language, String>> = mapOf(
            PaceType.WALK to mapOf(Language.EN to "Walk", Language.RU to "Ходьба"),
            PaceType.JOG to mapOf(Language.EN to "Jog", Language.RU to "Джоггинг"),
            PaceType.RUN to mapOf(Language.EN to "Run", Language.RU to "Бег"),
            PaceType.SPRINT to mapOf(Language.EN to "Sprint", Language.RU to "Спринт"),
            PaceType.RECOVERY to mapOf(Language.EN to "Recovery", Language.RU to "Восстановление"),
        )
    }
}
