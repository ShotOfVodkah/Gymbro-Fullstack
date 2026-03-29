package com.gymbro.divkit.workoutInfo

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

@RestController
@RequestMapping("/workoutInfo")
class WorkoutInfoController(private val backendClient: GymbroBackendClient) {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "1") id: String
    ): ResponseEntity<Divan> {
        val workout = backendClient.getWorkout(id)?.toDomain()

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

        return ResponseEntity(
            divan {
                data(
                    logId = "workouts_list",
                    div = with(WorkoutInfoRenderer) { render(workout) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}
