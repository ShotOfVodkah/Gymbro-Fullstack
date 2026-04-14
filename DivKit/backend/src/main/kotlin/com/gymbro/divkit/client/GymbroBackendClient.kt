package com.gymbro.divkit.client

import org.springframework.beans.factory.annotation.Value
import org.springframework.core.ParameterizedTypeReference
import org.springframework.http.HttpEntity
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpMethod
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class GymbroBackendClient(
    private val restTemplate: RestTemplate,
    @Value("\${gymbro.backend.url}") private val backendUrl: String
) {

    fun getWorkouts(authorization: String, premadeCatalog: Boolean = false): List<WorkoutDto> {
        val url = if (premadeCatalog) "$backendUrl/workouts/?userId=premade" else "$backendUrl/workouts/"
        val entity = HttpEntity<Void>(headers(authorization))
        return restTemplate.exchange(
            url,
            HttpMethod.GET,
            entity,
            object : ParameterizedTypeReference<List<WorkoutDto>>() {}
        ).body ?: emptyList()
    }

    fun getWorkout(id: String, authorization: String): WorkoutDto? {
        return try {
            val entity = HttpEntity<Void>(headers(authorization))
            restTemplate.exchange(
                "$backendUrl/workouts/$id",
                HttpMethod.GET,
                entity,
                WorkoutDto::class.java
            ).body
        } catch (_: Exception) {
            null
        }
    }

    fun getSession(id: String, authorization: String): WorkoutSessionDto? {
        return try {
            val entity = HttpEntity<Void>(headers(authorization))
            restTemplate.exchange(
                "$backendUrl/sessions/$id",
                HttpMethod.GET,
                entity,
                WorkoutSessionDto::class.java
            ).body
        } catch (_: Exception) {
            null
        }
    }

    fun getExercisesByType(type: String): List<ExerciseCatalogDto> {
        val url = "$backendUrl/exercises?type=$type"
        return restTemplate.exchange(
            url,
            HttpMethod.GET,
            null,
            object : ParameterizedTypeReference<List<ExerciseCatalogDto>>() {}
        ).body ?: emptyList()
    }

    private fun headers(authorization: String): HttpHeaders {
        val h = HttpHeaders()
        h[HttpHeaders.AUTHORIZATION] = listOf(authorization)
        return h
    }
}
