package com.gymbro.divkit.client

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.http.MediaType
import org.springframework.test.web.client.MockRestServiceServer
import org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo
import org.springframework.test.web.client.response.MockRestResponseCreators.withServerError
import org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess
import org.springframework.web.client.RestTemplate

class GymbroBackendClientTest {

    private lateinit var restTemplate: RestTemplate
    private lateinit var mockServer: MockRestServiceServer
    private lateinit var client: GymbroBackendClient

    @BeforeEach
    fun setUp() {
        restTemplate = RestTemplate()
        mockServer = MockRestServiceServer.bindTo(restTemplate).build()
        client = GymbroBackendClient(restTemplate, "http://localhost:8080")
    }

    @AfterEach
    fun tearDown() {
        mockServer.verify()
    }

    @Test
    fun `getWorkout fetches single workout for non premade id`() {
        mockServer.expect(requestTo("http://localhost:8080/workouts/user-1?locale=en"))
            .andRespond(
                withSuccess(
                    """{"id":"user-1","name":"W","type":"strength","exercises":[]}""",
                    MediaType.APPLICATION_JSON,
                ),
            )
        val dto = client.getWorkout("user-1", "Bearer token", "en")
        assertThat(dto).isNotNull
        assertThat(dto!!.id).isEqualTo("user-1")
        assertThat(dto.name).isEqualTo("W")
    }

    @Test
    fun `getWorkout premade id loads from catalog list`() {
        mockServer.expect(requestTo("http://localhost:8080/workouts/?userId=premade&locale=en"))
            .andRespond(
                withSuccess(
                    """
                    [
                      {"id":"premade-1","name":"A","type":"yoga","exercises":[]},
                      {"id":"premade-2","name":"B","type":"cardio","exercises":[]}
                    ]
                    """.trimIndent(),
                    MediaType.APPLICATION_JSON,
                ),
            )
        val dto = client.getWorkout("premade-2", "Bearer x", "en")
        assertThat(dto).isNotNull
        assertThat(dto!!.id).isEqualTo("premade-2")
        assertThat(dto.name).isEqualTo("B")
    }

    @Test
    fun `getWorkout premade id returns null when not in catalog`() {
        mockServer.expect(requestTo("http://localhost:8080/workouts/?userId=premade&locale=en"))
            .andRespond(withSuccess("[]", MediaType.APPLICATION_JSON))
        assertThat(client.getWorkout("premade-2", "Bearer x", "en")).isNull()
    }

    @Test
    fun `getWorkout returns null on HTTP error for single workout`() {
        mockServer.expect(requestTo("http://localhost:8080/workouts/user-1?locale=en"))
            .andRespond(withServerError())
        assertThat(client.getWorkout("user-1", "Bearer x", "en")).isNull()
    }

    @Test
    fun `getWorkout premade returns null when catalog request fails`() {
        mockServer.expect(requestTo("http://localhost:8080/workouts/?userId=premade&locale=en"))
            .andRespond(withServerError())
        assertThat(client.getWorkout("premade-2", "Bearer x", "en")).isNull()
    }
}
