package com.gymbro.divkit

enum class Language(val asString: String) {
    EN("en"),
    RU("ru"),
    ;

    companion object {
        fun fromRequestParam(raw: String?): Language {
            val primary = raw?.trim()?.lowercase()?.substringBefore('-').orEmpty()
            return when (primary) {
                "ru" -> RU
                else -> EN
            }
        }
    }
}
