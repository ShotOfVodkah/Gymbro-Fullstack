package com.gymbro.divkit.workoutsList

import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.auth.GymbroJwtAuth
import com.gymbro.divkit.client.GymbroBackendClient
import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.stringVariable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders

@RestController
@RequestMapping("/workoutsList")
class WorkoutsListController(private val backendClient: GymbroBackendClient) {

    @GetMapping
    fun getWorkouts(
        @RequestParam userId: String,
        request: HttpServletRequest
    ): ResponseEntity<Divan> {
        val jwtUserId = request.getAttribute(GymbroJwtAuth.USER_ID_ATTRIBUTE) as String
        if (userId != jwtUserId) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }
        val authorization = request.getHeader(HttpHeaders.AUTHORIZATION)!!
        val workouts = backendClient.getWorkouts(authorization = authorization).map { dto ->
            WorkoutItem(
                id = dto.id,
                name = dto.name,
                type = when (dto.type.lowercase()) {
                    "strength" -> WorkoutType.STRENGTH
                    "cardio" -> WorkoutType.CARDIO
                    "yoga" -> WorkoutType.YOGA
                    else -> WorkoutType.STRENGTH
                }
            )
        }

        return ResponseEntity(
            divan {
                data(
                    logId = "workouts_list",
                    div = with(WorkoutsListRenderer) { render(workouts, 4, 6, 2, 10) },
                    variables = listOf(
                        stringVariable(
                            name = WorkoutsListRenderer.SEARCH_TEXT_VARIABLE,
                            value = ""
                        )
                    )
                )
            },
            HttpStatus.OK
        )
    }
}

data class WorkoutItem(
    val id: String,
    val name: String,
    val type: WorkoutType
)
