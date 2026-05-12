package com.gymbro.divkit.workoutsList

import com.gymbro.divkit.Language
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.auth.GymbroJwtAuth
import com.gymbro.divkit.client.GymbroBackendClient
import com.gymbro.divkit.config.DivKitPublicUrls
import divkit.dsl.Divan
import divkit.dsl.data
import divkit.dsl.divan
import divkit.dsl.stringVariable
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import jakarta.servlet.http.HttpServletRequest
@RestController
@RequestMapping("/workoutsList")
class WorkoutsListController(
    private val backendClient: GymbroBackendClient,
    private val divKitPublicUrls: DivKitPublicUrls,
) {

    @GetMapping
    fun getWorkouts(
        @RequestParam userId: String,
        @RequestParam(name = "lang", required = false, defaultValue = "en") lang: String,
        @RequestParam(name = "completedThisWeek", required = false, defaultValue = "4") completedThisWeek: Int,
        @RequestParam(name = "weeklyGoal", required = false, defaultValue = "6") weeklyGoal: Int,
        @RequestParam(name = "daysLeft", required = false, defaultValue = "2") daysLeft: Int,
        @RequestParam(name = "currentStreakWeeks", required = false, defaultValue = "10") currentStreakWeeks: Int,
        @RequestParam(name = "weekEnd", required = false, defaultValue = "") weekEnd: String,
        @RequestParam(name = "wasFreezeUsedThisWeek", required = false, defaultValue = "false") wasFreezeUsedThisWeek: Boolean,
        @RequestParam(name = "isGoalCompleted", required = false, defaultValue = "false") isGoalCompleted: Boolean,
        request: HttpServletRequest,
    ): ResponseEntity<Divan> {
        val jwtUserId = request.getAttribute(GymbroJwtAuth.USER_ID_ATTRIBUTE) as String
        if (userId != jwtUserId) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build()
        }
        val language = Language.fromRequestParam(lang)
        val workouts = backendClient.getWorkouts(
            userId = jwtUserId,
            locale = language.asString,
        ).map { dto ->
            WorkoutItem(
                id = dto.id,
                name = dto.name,
                type = when (dto.type.lowercase()) {
                    "strength" -> WorkoutType.STRENGTH
                    "cardio" -> WorkoutType.CARDIO
                    "yoga" -> WorkoutType.YOGA
                    else -> WorkoutType.STRENGTH
                }
            )
        }
        return ResponseEntity(
            divan {
                data(
                    logId = "workouts_list",
                    div = with(WorkoutsListRenderer) {
                        render(
                            workouts,
                            completedThisWeek,
                            weeklyGoal,
                            daysLeft,
                            currentStreakWeeks,
                            weekEnd,
                            wasFreezeUsedThisWeek,
                            isGoalCompleted,
                            language,
                            divKitPublicUrls.assetsBaseUrl,
                        ) },
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
}

data class WorkoutItem(
    val id: String,
    val name: String,
    val type: WorkoutType
)
