package com.gymbro.divkit.workoutBuilderTitle

import com.gymbro.divkit.Language
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.i18n.DomainStrings
import com.gymbro.divkit.i18n.LocalizedStrings
import com.gymbro.divkit.i18n.exerciseCountLabel

private enum class WorkoutBuilderTitleKey {
    SCREEN_TITLE,
    SCREEN_SUBTITLE,
    AI_CARD_TITLE,
    AI_CARD_BODY,
    AI_CTA,
    BUILD_BY_CATEGORY,
    SELECT_PREMADE,
}

class WorkoutBuilderTitleTranslations(
    private val language: Language,
) {
    private val domain = DomainStrings(language)
    private val strings = LocalizedStrings(
        language,
        mapOf(
            WorkoutBuilderTitleKey.SCREEN_TITLE to mapOf(
                Language.EN to "Build your workout",
                Language.RU to "Собери свою тренировку",
            ),
            WorkoutBuilderTitleKey.SCREEN_SUBTITLE to mapOf(
                Language.EN to "Make the perfect workout just for you using one of the many options!",
                Language.RU to "Собери идеальную тренировку для себя — выбери один из вариантов!",
            ),
            WorkoutBuilderTitleKey.AI_CARD_TITLE to mapOf(
                Language.EN to "AI generator for workouts",
                Language.RU to "ИИ-генератор тренировок",
            ),
            WorkoutBuilderTitleKey.AI_CARD_BODY to mapOf(
                Language.EN to "Make a personalized workout in a matter of seconds using the magic of AI!",
                Language.RU to "Персональная тренировка за считанные секунды с помощью ИИ!",
            ),
            WorkoutBuilderTitleKey.AI_CTA to mapOf(
                Language.EN to "Try it out!",
                Language.RU to "Попробовать!",
            ),
            WorkoutBuilderTitleKey.BUILD_BY_CATEGORY to mapOf(
                Language.EN to "Build by category",
                Language.RU to "По категории",
            ),
            WorkoutBuilderTitleKey.SELECT_PREMADE to mapOf(
                Language.EN to "Select premade",
                Language.RU to "Готовые планы",
            ),
        ),
        "WorkoutBuilderTitle",
    )

    fun screenTitle(): String = strings[WorkoutBuilderTitleKey.SCREEN_TITLE]

    fun screenSubtitle(): String = strings[WorkoutBuilderTitleKey.SCREEN_SUBTITLE]

    fun aiCardTitle(): String = strings[WorkoutBuilderTitleKey.AI_CARD_TITLE]

    fun aiCardBody(): String = strings[WorkoutBuilderTitleKey.AI_CARD_BODY]

    fun aiCta(): String = strings[WorkoutBuilderTitleKey.AI_CTA]

    fun buildByCategory(): String = strings[WorkoutBuilderTitleKey.BUILD_BY_CATEGORY]

    fun selectPremade(): String = strings[WorkoutBuilderTitleKey.SELECT_PREMADE]

    fun workoutTypeLabel(type: WorkoutType): String = domain.workoutType(type)

    fun workoutTypeQueryParam(type: WorkoutType): String = DomainStrings.workoutTypeQueryParam(type)

    fun premadeMetaLine(type: WorkoutType, exerciseCount: Int): String {
        val category = workoutTypeLabel(type)
        val countPart = exerciseCountLabel(language, exerciseCount)
        return "$category  -  $countPart"
    }
}
