package com.gymbro.divkit.workoutBuilder

import divkit.dsl.Divan
import divkit.dsl.booleanVariable
import divkit.dsl.data
import divkit.dsl.divan
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/workoutBuilder")
class WorkoutBuilderController {

    @GetMapping
    fun getWorkoutInfo(): ResponseEntity<Divan> {

        val groups = listOf(
            WorkoutBuilderRenderer.ToggleGroup(
                id = "warmup",
                title = "Разминка",
                items = listOf(
                    WorkoutBuilderRenderer.ToggleItem(
                        id = "jumping_jacks",
                        firstText = "Jumping jacks",
                        secondText = "3×30 сек, отдых 30 сек"
                    ),
                    WorkoutBuilderRenderer.ToggleItem(
                        id = "arm_circles",
                        firstText = "Arm circles",
                        secondText = "2×20 кругов в каждую сторону"
                    )
                )
            )
        )

        return ResponseEntity(
            divan {
                data (
                    logId = "workout_builder",
                    div = with(WorkoutBuilderRenderer) { render(groups) },

                    variables = groups.flatMap { g ->
                        g.items.map { item ->
                            val name = "toggle_${sanitize(g.id)}_${sanitize(item.id)}"
                            booleanVariable(
                                name = name,
                                value = false
                            )
                        }
                    }
                )
            },
            HttpStatus.OK
        )
    }

    private fun sanitize(s: String) = s.replace(Regex("[^A-Za-z0-9_]"), "_")
}

