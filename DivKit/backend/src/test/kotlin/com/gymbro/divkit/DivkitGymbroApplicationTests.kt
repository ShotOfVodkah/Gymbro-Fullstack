package com.gymbro.divkit

import com.gymbro.divkit.client.BduiM2mJwtService
import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.mock.mockito.MockBean

@SpringBootTest(classes = [DivkitGymbroApplication::class])
class DivkitGymbroApplicationTests {

    @MockBean
    lateinit var bduiM2mJwtService: BduiM2mJwtService

    @Test
    fun contextLoads() {
    }
}
