package com.gymbro.divkit.workoutInfo

import com.gymbro.divkit.Language
import com.gymbro.divkit.auth.GymbroJwtAuth
import com.gymbro.divkit.client.GymbroBackendClient
import com.gymbro.divkit.client.toDomain
import com.gymbro.divkit.client.toWorkout
import divkit.dsl.Divan
import divkit.dsl.container
import divkit.dsl.data
import divkit.dsl.divan
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/workoutInfo")
class WorkoutInfoController(private val backendClient: GymbroBackendClient) {

    companion object {
        const val WORKOUT_INFO_SOURCE_VARIABLE = "workout_info_source"
    }

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "1") id: String,
        @RequestParam(defaultValue = "workout") type: String,
        @RequestParam(name = "lang", required = false, defaultValue = "en") lang: String,
        request: HttpServletRequest
    ): ResponseEntity<Divan> {
        val language = Language.fromRequestParam(lang)
        val translations = WorkoutInfoTranslations(language)
        val jwtUserId = request.getAttribute(GymbroJwtAuth.USER_ID_ATTRIBUTE) as String
        val locale = language.asString

        val notFound = ResponseEntity(
            divan {
                data(
                    logId = "workout_not_found",
                    div = container(),
                    variables = listOf()
                )
            },
            HttpStatus.NOT_FOUND
        )

        val (workout, sourceKind) = when (type.lowercase()) {
            "session" -> {
                val dto = backendClient.getSession(id, jwtUserId, locale) ?: return notFound
                val w = dto.toWorkout()
                val src = if (dto.userId == jwtUserId) "session_mine" else "session_other"
                w to src
            }
            else -> {
                val w = backendClient.getWorkout(id, jwtUserId, locale)?.toDomain() ?: return notFound
                w to "workout"
            }
        }

        return ResponseEntity(
            divan {
                data(
                    logId = "workouts_list",
                    div = with(WorkoutInfoRenderer) { render(workout, sourceKind, translations) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}
