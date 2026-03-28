package com.gymbro.divkit.workoutBuilderTitle

import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan

import com.gymbro.divkit.premadeWorkouts
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import kotlin.collections.listOf

@RestController
@RequestMapping("/workoutBuilderTitle") // Listening at localhost:8090/workoutBuilderTitle
class WorkoutBuilerTitleController {

    @GetMapping
    fun getWorkoutInfo(): ResponseEntity<Divan> {
        return ResponseEntity(
            divan {
                data(
                    logId = "workoutBuilderTitle",
                    div = with(WorkoutBuilderTitleRenderer) { render(workouts = premadeWorkouts) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}