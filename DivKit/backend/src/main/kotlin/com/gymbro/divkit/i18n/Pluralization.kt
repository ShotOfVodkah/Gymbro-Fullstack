package com.gymbro.divkit.i18n

import com.gymbro.divkit.Language

fun exerciseCountLabel(language: Language, count: Int): String {
    return when (language) {
        Language.EN ->
            if (count == 1) {
                "$count exercise"
            } else {
                "$count exercises"
            }
        Language.RU -> {
            val word = when {
                count % 10 == 1 && count % 100 != 11 -> "упражнение"
                count % 10 in 2..4 && count % 100 !in 12..14 -> "упражнения"
                else -> "упражнений"
            }
            "$count $word"
        }
    }
}
