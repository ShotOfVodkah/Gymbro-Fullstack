package com.gymbro.divkit.i18n

import com.gymbro.divkit.Language
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

private enum class TestKey {
    HELLO,
    EN_ONLY,
}

class LocalizedStringsTest {

    private val table = mapOf(
        TestKey.HELLO to mapOf(Language.EN to "Hello", Language.RU to "Привет"),
        TestKey.EN_ONLY to mapOf(Language.EN to "OnlyEn"),
    )

    @Test
    fun `returns string for current language`() {
        val sut = LocalizedStrings(Language.RU, table, "test")
        assertThat(sut[TestKey.HELLO]).isEqualTo("Привет")
    }

    @Test
    fun `falls back to EN when RU missing`() {
        val sut = LocalizedStrings(Language.RU, table, "test")
        assertThat(sut[TestKey.EN_ONLY]).isEqualTo("OnlyEn")
    }

    @Test
    fun `missing key row returns empty`() {
        val emptyTable: Map<TestKey, Map<Language, String>> = emptyMap()
        val sut = LocalizedStrings(Language.EN, emptyTable, "test")
        assertThat(sut[TestKey.HELLO]).isEmpty()
    }
}
