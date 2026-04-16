package com.gymbro.divkit

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class LanguageTest {

    @Test
    fun `fromRequestParam maps ru variants`() {
        assertThat(Language.fromRequestParam("ru")).isEqualTo(Language.RU)
        assertThat(Language.fromRequestParam("RU")).isEqualTo(Language.RU)
        assertThat(Language.fromRequestParam(" ru-RU ")).isEqualTo(Language.RU)
    }

    @Test
    fun `fromRequestParam defaults to EN`() {
        assertThat(Language.fromRequestParam(null)).isEqualTo(Language.EN)
        assertThat(Language.fromRequestParam("")).isEqualTo(Language.EN)
        assertThat(Language.fromRequestParam("en")).isEqualTo(Language.EN)
        assertThat(Language.fromRequestParam("uk")).isEqualTo(Language.EN)
    }
}
