package com.gymbro.divkit.i18n

import com.gymbro.divkit.Language
import com.gymbro.divkit.MuscleGroup
import com.gymbro.divkit.PaceType
import com.gymbro.divkit.WorkoutType
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class DomainStringsTest {

    @Test
    fun `workoutTypeQueryParam is lowercase enum name`() {
        assertThat(DomainStrings.workoutTypeQueryParam(WorkoutType.STRENGTH)).isEqualTo("strength")
        assertThat(DomainStrings.workoutTypeQueryParam(WorkoutType.CARDIO)).isEqualTo("cardio")
        assertThat(DomainStrings.workoutTypeQueryParam(WorkoutType.YOGA)).isEqualTo("yoga")
    }

    @Test
    fun `workoutType localized`() {
        assertThat(DomainStrings(Language.EN).workoutType(WorkoutType.YOGA)).isEqualTo("Yoga")
        assertThat(DomainStrings(Language.RU).workoutType(WorkoutType.YOGA)).isEqualTo("Йога")
    }

    @Test
    fun `muscle localized`() {
        assertThat(DomainStrings(Language.EN).muscle(MuscleGroup.CHEST)).isEqualTo("Chest")
        assertThat(DomainStrings(Language.RU).muscle(MuscleGroup.CHEST)).isEqualTo("Грудь")
    }

    @Test
    fun `pace localized`() {
        assertThat(DomainStrings(Language.EN).pace(PaceType.SPRINT)).isEqualTo("Sprint")
        assertThat(DomainStrings(Language.RU).pace(PaceType.SPRINT)).isEqualTo("Спринт")
    }
}
