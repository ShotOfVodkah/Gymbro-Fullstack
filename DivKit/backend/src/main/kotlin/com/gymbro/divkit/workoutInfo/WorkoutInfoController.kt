package com.gymbro.divkit.workoutInfo

import com.gymbro.divkit.WorkoutStyle
import com.gymbro.divkit.workouts
import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.stringVariable

import com.gymbro.divkit.WorkoutType
import divkit.dsl.Div
import divkit.dsl.container

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.RequestParam
import kotlin.collections.listOf

@RestController
@RequestMapping("/workoutInfo") // Listening at localhost:8080/workoutInfo
class WorkoutInfoController {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "1") id: String
    ): ResponseEntity<Divan> {
        val workout = workouts.find { it.id == id }

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