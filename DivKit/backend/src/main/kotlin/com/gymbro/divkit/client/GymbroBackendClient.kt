package com.gymbro.divkit.client

import org.springframework.beans.factory.annotation.Value
import org.springframework.core.ParameterizedTypeReference
import org.springframework.http.HttpMethod
import org.springframework.stereotype.Service
import org.springframework.web.client.RestTemplate

@Service
class GymbroBackendClient(
    private val restTemplate: RestTemplate,
    @Value("\${gymbro.backend.url}") private val backendUrl: String
) {

    fun getWorkoutsByUserId(userId: String): List<WorkoutDto> {
        val url = "$backendUrl/workouts/?userId=$userId"
        return restTemplate.exchange(
            url,
            HttpMethod.GET,
            null,
            object : ParameterizedTypeReference<List<WorkoutDto>>() {}
        ).body ?: emptyList()
    }

    fun getWorkout(id: String): WorkoutDto? {
        return try {
            restTemplate.getForObject("$backendUrl/workouts/$id", WorkoutDto::class.java)
        } catch (ex: Exception) {
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
}
