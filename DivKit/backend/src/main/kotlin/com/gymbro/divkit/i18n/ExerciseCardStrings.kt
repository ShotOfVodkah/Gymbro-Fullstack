package com.gymbro.divkit.i18n

import com.gymbro.divkit.CardioExercise
import com.gymbro.divkit.Language
import com.gymbro.divkit.MuscleGroup
import com.gymbro.divkit.PaceType
import com.gymbro.divkit.StrengthExercise
import com.gymbro.divkit.YogaExercise

private enum class ExerciseCardKey {
    DURATION,
    MIN,
    PACE,
    HOLD_FOR,
    SEC,
    BREATH_COUNT,
    BREATH_PER_MIN_SUFFIX,
    SETS,
    REPS,
    WEIGHT,
    KG,
}

class ExerciseCardStrings(language: Language) {

    private val domain = DomainStrings(language)
    private val strings = LocalizedStrings(
        language,
        mapOf(
            ExerciseCardKey.DURATION to mapOf(Language.EN to "Duration", Language.RU to "Длительность"),
            ExerciseCardKey.MIN to mapOf(Language.EN to "min", Language.RU to "мин"),
            ExerciseCardKey.PACE to mapOf(Language.EN to "Pace", Language.RU to "Темп"),
            ExerciseCardKey.HOLD_FOR to mapOf(Language.EN to "Hold for", Language.RU to "Удержание"),
            ExerciseCardKey.SEC to mapOf(Language.EN to "sec", Language.RU to "с"),
            ExerciseCardKey.BREATH_COUNT to mapOf(Language.EN to "Breath Count", Language.RU to "Дыхание"),
            ExerciseCardKey.BREATH_PER_MIN_SUFFIX to mapOf(Language.EN to "/min", Language.RU to "/мин"),
            ExerciseCardKey.SETS to mapOf(Language.EN to "Sets", Language.RU to "Подходы"),
            ExerciseCardKey.REPS to mapOf(Language.EN to "Reps", Language.RU to "Повторы"),
            ExerciseCardKey.WEIGHT to mapOf(Language.EN to "Weight", Language.RU to "Вес"),
            ExerciseCardKey.KG to mapOf(Language.EN to "Kg", Language.RU to "кг"),
        ),
        "ExerciseCard",
    )

    fun muscleGroup(group: MuscleGroup): String = domain.muscle(group)

    fun pace(pace: PaceType): String = domain.pace(pace)

    fun strengthStatRows(exercise: StrengthExercise): List<Pair<String, String>> =
        listOf(
            strings[ExerciseCardKey.SETS] to "${exercise.sets}",
            strings[ExerciseCardKey.REPS] to "${exercise.reps}",
            strings[ExerciseCardKey.WEIGHT] to "${exercise.weightKg} ${strings[ExerciseCardKey.KG]}",
        )

    fun cardioStatRows(exercise: CardioExercise): List<Pair<String, String>> =
        listOf(
            strings[ExerciseCardKey.DURATION] to "${exercise.durationMinutes} ${strings[ExerciseCardKey.MIN]}",
            strings[ExerciseCardKey.PACE] to pace(exercise.pace),
        )

    fun yogaStatRows(exercise: YogaExercise): List<Pair<String, String>> =
        listOf(
            strings[ExerciseCardKey.HOLD_FOR] to "${exercise.holdSeconds} ${strings[ExerciseCardKey.SEC]}",
            strings[ExerciseCardKey.BREATH_COUNT] to "${exercise.breathCount}${strings[ExerciseCardKey.BREATH_PER_MIN_SUFFIX]}",
        )
}
