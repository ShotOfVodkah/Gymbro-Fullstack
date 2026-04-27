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
    private val bduiM2mJwtService: BduiM2mJwtService,
) {

    fun getWorkouts(userId: String, premadeCatalog: Boolean = false, locale: String): List<WorkoutDto> {
        val urlBuilder = UriComponentsBuilder.fromHttpUrl("$backendUrl/workouts/")
        if (premadeCatalog) {
            urlBuilder.queryParam("userId", "premade")
        }
        val url = urlBuilder.queryParam("locale", locale).toUriString()
        val entity = HttpEntity<Void>(m2mAuthHeaders(userId))
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
            val entity = HttpEntity<Void>(m2mAuthHeaders(userId))
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
            val entity = HttpEntity<Void>(m2mAuthHeaders(userId))
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

    private fun m2mAuthHeaders(userId: String): HttpHeaders {
        val h = HttpHeaders()
        h[HttpHeaders.AUTHORIZATION] = listOf("Bearer ${bduiM2mJwtService.createTokenForUserId(userId)}")
        return h
    }
}
