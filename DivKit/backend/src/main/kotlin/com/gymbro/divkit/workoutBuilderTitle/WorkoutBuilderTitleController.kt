package com.gymbro.divkit.workoutBuilderTitle

import com.gymbro.divkit.Language
import com.gymbro.divkit.auth.GymbroJwtAuth
import com.gymbro.divkit.client.GymbroBackendClient
import com.gymbro.divkit.client.toDomain
import com.gymbro.divkit.config.DivKitPublicUrls
import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import jakarta.servlet.http.HttpServletRequest
@RestController
@RequestMapping("/workoutBuilderTitle")
class WorkoutBuilerTitleController(
    private val backendClient: GymbroBackendClient,
    private val divKitPublicUrls: DivKitPublicUrls,
) {

    @GetMapping
    fun getWorkoutInfo(
        @RequestParam(name = "lang", required = false, defaultValue = "en") lang: String,
        request: HttpServletRequest,
    ): ResponseEntity<Divan> {
        val jwtUserId = request.getAttribute(GymbroJwtAuth.USER_ID_ATTRIBUTE) as String
        val language = Language.fromRequestParam(lang)
        val workouts = backendClient.getWorkouts(
            userId = jwtUserId,
            premadeCatalog = true,
            locale = language.asString,
        )
            .map { it.toDomain() }
        val translations = WorkoutBuilderTitleTranslations(language)

        return ResponseEntity(
            divan {
                data(
                    logId = "workoutBuilderTitle",
                    div = with(WorkoutBuilderTitleRenderer) {
                        render(
                            workouts = workouts,
                            t = translations,
                            assetsBaseUrl = divKitPublicUrls.assetsBaseUrl,
                        )
                    },
                    variables = listOf()
                )
            },
            HttpStatus.OK
        )
    }
}
