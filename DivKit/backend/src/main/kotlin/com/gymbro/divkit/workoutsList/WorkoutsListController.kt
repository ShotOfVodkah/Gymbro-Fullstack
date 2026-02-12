package com.gymbro.divkit.workoutsList

import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.stringVariable

import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.workouts

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import kotlin.collections.listOf

@RestController
@RequestMapping("/workoutsList") // Listening at localhost:8080/workoutsList
class WorkoutsListController {

    @GetMapping
    fun getWorkouts(): ResponseEntity<Divan> {
        val workouts = fetchWorkouts()

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

    private fun fetchWorkouts(): List<WorkoutItem> {
        return workouts.map { workout ->
            WorkoutItem(
                id = workout.id,
                name = workout.name,
                type = workout.type
            )
        }
    }
}

data class WorkoutItem(
    val id: String,
    val name: String,
    val type: WorkoutType
)
