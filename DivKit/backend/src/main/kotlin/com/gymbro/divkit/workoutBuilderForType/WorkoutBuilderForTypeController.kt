package com.gymbro.divkit.workoutBuilderForType

import com.gymbro.divkit.Exercise
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.strengthExercises
import com.gymbro.divkit.cardioExercises
import com.gymbro.divkit.yogaExercises


import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.container

import com.gymbro.divkit.premadeWorkouts
import com.gymbro.divkit.styleFor
import com.gymbro.divkit.workoutBuilderTitle.WorkoutBuilderTitleRenderer
import com.gymbro.divkit.workoutBuilderTitle.WorkoutBuilderTitleRenderer.render
import com.gymbro.divkit.workoutInfo.WorkoutInfoRenderer
import com.gymbro.divkit.workoutInfo.WorkoutInfoRenderer.render
import com.gymbro.divkit.workouts
import divkit.dsl.booleanVariable
import divkit.dsl.text
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import kotlin.collections.listOf

@RestController
@RequestMapping("/workoutBuilderForType") // Listening at localhost:8080/workoutBuilderSheet
class WorkoutBuilderForTypeController {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "yoga") type: String,
        @RequestParam(required = false) exerciseIds: List<String>?
    ): ResponseEntity<Divan> {

        val exercises: List<Exercise> = when (type) {
            "Strength" -> strengthExercises
            "Cardio" -> cardioExercises
            "Yoga" -> yogaExercises
            else -> yogaExercises
        }

        val color: String = when (type) {
            "Strength" -> styleFor(WorkoutType.STRENGTH).backgroundColor
            "Cardio" -> styleFor(WorkoutType.CARDIO).backgroundColor
            "Yoga" -> styleFor(WorkoutType.YOGA).backgroundColor
            else -> styleFor(WorkoutType.YOGA).backgroundColor
        }

        val selected = exerciseIds?.toSet().orEmpty()

        return ResponseEntity(
            divan {
                data(
                    logId = "workoutBuilderCards",
                    div = with(WorkoutBuilderForTypeRenderer) { render(exercises, color, selected) },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}