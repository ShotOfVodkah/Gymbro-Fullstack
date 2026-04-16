package com.gymbro.divkit.i18n

import com.gymbro.divkit.Language
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.CsvSource

class PluralizationTest {

    @ParameterizedTest
    @CsvSource(
        "0,0 exercises",
        "1,1 exercise",
        "2,2 exercises",
        "5,5 exercises",
        "11,11 exercises",
        "21,21 exercises",
        "22,22 exercises",
        "25,25 exercises",
    )
    fun `exerciseCountLabel english`(count: Int, expected: String) {
        assertThat(exerciseCountLabel(Language.EN, count)).isEqualTo(expected)
    }

    @Test
    fun `exerciseCountLabel russian sample`() {
        assertThat(exerciseCountLabel(Language.RU, 0)).isEqualTo("0 упражнений")
        assertThat(exerciseCountLabel(Language.RU, 1)).isEqualTo("1 упражнение")
        assertThat(exerciseCountLabel(Language.RU, 2)).isEqualTo("2 упражнения")
        assertThat(exerciseCountLabel(Language.RU, 5)).isEqualTo("5 упражнений")
        assertThat(exerciseCountLabel(Language.RU, 11)).isEqualTo("11 упражнений")
        assertThat(exerciseCountLabel(Language.RU, 21)).isEqualTo("21 упражнение")
        assertThat(exerciseCountLabel(Language.RU, 22)).isEqualTo("22 упражнения")
        assertThat(exerciseCountLabel(Language.RU, 25)).isEqualTo("25 упражнений")
    }
}
