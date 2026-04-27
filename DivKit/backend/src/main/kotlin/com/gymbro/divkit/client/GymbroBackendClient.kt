package com.gymbro.divkit.client

import org.springframework.beans.factory.annotation.Value
import org.springframework.core.ParameterizedTypeReference
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate
import org.springframework.web.util.UriComponentsBuilder

@Service
class GymbroBackendClient(
    private val restTemplate: RestTemplate,
    @Value("\${gymbro.backend.url}") private val backendUrl: String,
    @Value("\${gymbro.bdui.to.workouts.secret:}") private val bduiToWorkoutsSecret: String,
) {

    fun getWorkouts(userId: String, premadeCatalog: Boolean = false, locale: String): List<WorkoutDto> {
        val urlBuilder = UriComponentsBuilder.fromHttpUrl("$backendUrl/workouts/")
        if (premadeCatalog) {
            urlBuilder.queryParam("userId", "premade")
        }
        val url = urlBuilder.queryParam("locale", locale).toUriString()
        val entity = HttpEntity<Void>(bduiHeaders(userId))
        return restTemplate.exchange(
            url,
            HttpMethod.GET,
            entity,
            object : ParameterizedTypeReference<List<WorkoutDto>>() {},
        ).body ?: emptyList()
    }

    fun getWorkout(id: String, userId: String, locale: String): WorkoutDto? {
        if (id.startsWith("premade-")) {
            return try {
                getWorkouts(userId, premadeCatalog = true, locale).find { it.id == id }
            } catch (_: Exception) {
                null
            }
        }
        return try {
            val url = UriComponentsBuilder.fromHttpUrl("$backendUrl/workouts/$id")
                .queryParam("locale", locale)
                .toUriString()
            val entity = HttpEntity<Void>(bduiHeaders(userId))
            restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                WorkoutDto::class.java,
            ).body
        } catch (_: Exception) {
            null
        }
    }

    fun getSession(id: String, userId: String, locale: String): WorkoutSessionDto? {
        return try {
            val url = UriComponentsBuilder.fromHttpUrl("$backendUrl/sessions/$id")
                .queryParam("locale", locale)
                .toUriString()
            val entity = HttpEntity<Void>(bduiHeaders(userId))
            restTemplate.exchange(
                url,
                HttpMethod.GET,
                entity,
                WorkoutSessionDto::class.java,
            ).body
        } catch (_: Exception) {
            null
        }
    }

    fun getExercisesByType(type: String, locale: String): List<ExerciseCatalogDto> {
        val url = UriComponentsBuilder.fromHttpUrl("$backendUrl/exercises")
            .queryParam("type", type)
            .queryParam("locale", locale)
            .toUriString()
        return restTemplate.exchange(
            url,
            HttpMethod.GET,
            null,
            object : ParameterizedTypeReference<List<ExerciseCatalogDto>>() {},
        ).body ?: emptyList()
    }

    private fun bduiHeaders(userId: String): HttpHeaders {
        val h = HttpHeaders()
        h[HEADER_BDUI_SECRET] = listOf(bduiToWorkoutsSecret.trim())
        h[HEADER_USER_ID] = listOf(userId)
        return h
    }

    private companion object {
        const val HEADER_BDUI_SECRET = "X-BDUI-Secret"
        const val HEADER_USER_ID = "X-User-Id"
    }
}
