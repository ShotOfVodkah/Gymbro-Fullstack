package com.gymbro.divkit.workoutBuilderTitle

import com.gymbro.divkit.Language
import com.gymbro.divkit.client.GymbroBackendClient
import com.gymbro.divkit.client.toDomain
import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders

@RestController
@RequestMapping("/workoutBuilderTitle")
class WorkoutBuilerTitleController(private val backendClient: GymbroBackendClient) {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(name = "lang", required = false, defaultValue = "en") lang: String,
        request: HttpServletRequest,
    ): ResponseEntity<Divan> {
        val authorization = request.getHeader(HttpHeaders.AUTHORIZATION)!!
        val workouts = backendClient.getWorkouts(authorization = authorization, premadeCatalog = true)
            .map { it.toDomain() }
        val language = Language.fromRequestParam(lang)
        val translations = WorkoutBuilderTitleTranslations(language)

        return ResponseEntity(
            divan {
                data(
                    logId = "workoutBuilderTitle",
                    div = with(WorkoutBuilderTitleRenderer) { render(workouts = workouts, t = translations) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}
