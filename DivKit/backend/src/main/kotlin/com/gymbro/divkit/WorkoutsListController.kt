package com.gymbro.divkit

import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.text
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/workoutsList") // Listening at localhost:8080/workoutsList
class WorkoutsListController {

    @GetMapping
    fun getDemoScreen(): ResponseEntity<Divan> {
        return ResponseEntity(
            divan {
                data(
                    logId = "okay",
                    div = text(
                        text = "Hola"
                    )
                )
            },
            HttpStatus.OK
        )
    }
}
