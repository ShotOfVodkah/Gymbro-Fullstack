package com.gymbro.divkit.workoutBuilderSheet

import com.gymbro.divkit.Language
import com.gymbro.divkit.auth.GymbroJwtAuth
import com.gymbro.divkit.client.GymbroBackendClient
import com.gymbro.divkit.client.toDomain
import divkit.dsl.Divan
import divkit.dsl.container
import divkit.dsl.data
import divkit.dsl.divan
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import jakarta.servlet.http.HttpServletRequest
@RestController
@RequestMapping("/workoutBuilderSheet")
class WorkoutBuilderSheetController(private val backendClient: GymbroBackendClient) {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "1") id: String,
        @RequestParam(name = "lang", required = false, defaultValue = "en") lang: String,
        request: HttpServletRequest,
    ): ResponseEntity<Divan> {
        val jwtUserId = request.getAttribute(GymbroJwtAuth.USER_ID_ATTRIBUTE) as String
        val language = Language.fromRequestParam(lang)
        val workout = backendClient.getWorkout(id, jwtUserId, language.asString)?.toDomain()

        if (workout == null) {
            return ResponseEntity(
                divan {
                    data(
                        logId = "workout_not_found",
                        div = container(),
                        variables = listOf()
                    )
                },
                HttpStatus.NOT_FOUND
            )
        }

        val translations = WorkoutBuilderSheetTranslations(language)

        return ResponseEntity(
            divan {
                data(
                    logId = "workoutBuilderSheet",
                    div = with(WorkoutBuilderSheetRenderer) { render(workout, translations) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}
