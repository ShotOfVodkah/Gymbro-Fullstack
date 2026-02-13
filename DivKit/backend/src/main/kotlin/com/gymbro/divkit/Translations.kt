package com.gymbro.divkit

import kotlin.collections.mapOf

internal enum class Language(val asString: String) {
    EN("en"),
    RU("ru"),
}

internal class Translations(
    private val lang: Language,
) {
    private val translations = mapOf(
        "hello" to mapOf(
            Language.EN to "Hello, %s",
            Language.RU to "Привет, %s"
        ),
        "who" to mapOf(
            Language.EN to "Who are you?",
            Language.RU to "Кто ты?"
        )
    )

    operator fun get(key: String): String {
        return translations[key]?.get(lang) ?: run {
            println("No translation found for key `$key` in language `${lang.asString}`")
            ""
        }
    }

    companion object {
        fun fromLang(lang: String?): Translations {
            lang ?: run {
                println("Empty client language")
                return Translations(Language.EN)
            }

            val language = Language.entries.find { it.asString == lang.lowercase() } ?: run {
                println("Unknown language `$lang`")
                return Translations(Language.EN)
            }
            return Translations(language)
        }
    }
}
