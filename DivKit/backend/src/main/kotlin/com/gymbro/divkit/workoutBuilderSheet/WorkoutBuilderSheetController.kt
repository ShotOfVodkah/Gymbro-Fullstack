package com.gymbro.divkit.workoutBuilderSheet

import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.container

import com.gymbro.divkit.premadeWorkouts
import com.gymbro.divkit.workoutBuilderTitle.WorkoutBuilderTitleRenderer
import com.gymbro.divkit.workoutBuilderTitle.WorkoutBuilderTitleRenderer.render
import com.gymbro.divkit.workoutInfo.WorkoutInfoRenderer
import com.gymbro.divkit.workoutInfo.WorkoutInfoRenderer.render
import com.gymbro.divkit.workouts
import divkit.dsl.text
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import kotlin.collections.listOf

@RestController
@RequestMapping("/workoutBuilderSheet") // Listening at localhost:8090/workoutBuilderSheet
class WorkoutBuilderSheetController {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "1") id: String
    ): ResponseEntity<Divan> {
        val workout = premadeWorkouts.find { it.id == id }

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
                    logId = "workoutBuilderSheet",
                    div = with(WorkoutBuilderSheetRenderer) { render(workout) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}