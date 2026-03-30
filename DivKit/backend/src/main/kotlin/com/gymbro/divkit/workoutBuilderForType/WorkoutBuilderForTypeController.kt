package com.gymbro.divkit.workoutBuilderForType

import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.client.GymbroBackendClient
import com.gymbro.divkit.client.toExercise
import com.gymbro.divkit.styleFor
import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/workoutBuilderForType")
class WorkoutBuilderForTypeController(private val backendClient: GymbroBackendClient) {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(defaultValue = "yoga") type: String,
        @RequestParam(required = false) exerciseIds: List<String>?
    ): ResponseEntity<Divan> {

        val exercises = backendClient.getExercisesByType(type.lowercase()).map { it.toExercise() }

        val workoutType = when (type.lowercase()) {
            "strength" -> WorkoutType.STRENGTH
            "cardio" -> WorkoutType.CARDIO
            "yoga" -> WorkoutType.YOGA
            else -> WorkoutType.YOGA
        }

        val color = styleFor(workoutType).backgroundColor
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
