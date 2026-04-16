package com.gymbro.divkit.i18n

import com.gymbro.divkit.Language
import org.slf4j.LoggerFactory

class LocalizedStrings<K : Enum<K>>(
    private val language: Language,
    private val entries: Map<K, Map<Language, String>>,
    private val screenName: String,
) {
    private val log = LoggerFactory.getLogger(LocalizedStrings::class.java)

    operator fun get(key: K): String {
        val row = entries[key]
        if (row == null) {
            log.warn("Missing translation row for key {} in screen {}", key.name, screenName)
            return ""
        }
        val localized = row[language]
        if (localized != null) {
            return localized
        }
        val fallback = row[Language.EN]
        if (fallback != null) {
            if (language != Language.EN) {
                log.warn(
                    "Missing translation for key {} in screen {} for lang {}, fell back to EN",
                    key.name,
                    screenName,
                    language,
                )
            }
            return fallback
        }
        log.warn("Missing EN fallback for key {} in screen {}", key.name, screenName)
        return ""
    }
}
