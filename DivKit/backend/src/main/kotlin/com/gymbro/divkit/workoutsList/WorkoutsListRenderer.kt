package com.gymbro.divkit.workoutsList

import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.typeTitle
import com.gymbro.divkit.styleFor
import divkit.dsl.core.expression
import divkit.dsl.Visibility
import divkit.dsl.core.reference
import divkit.dsl.core.bind
import divkit.dsl.render
import divkit.dsl.plus
import divkit.dsl.Template
import divkit.dsl.containerProps
import divkit.dsl.template
import divkit.dsl.Container
import divkit.dsl.container
import divkit.dsl.Div
import divkit.dsl.core.colorArrayElement
import divkit.dsl.animation
import divkit.dsl.regular
import divkit.dsl.ease_in_out
import divkit.dsl.scale
import divkit.dsl.linearGradient
import divkit.dsl.image
import divkit.dsl.input
import divkit.dsl.Url
import divkit.dsl.action
import divkit.dsl.asList
import divkit.dsl.bold
import divkit.dsl.border
import divkit.dsl.center
import divkit.dsl.color
import divkit.dsl.defer
import divkit.dsl.edgeInsets
import divkit.dsl.fixedSize
import divkit.dsl.gallery
import divkit.dsl.horizontal
import divkit.dsl.overlap
import divkit.dsl.matchParentSize
import divkit.dsl.scope.DivScope
import divkit.dsl.solidBackground
import divkit.dsl.stroke
import divkit.dsl.text
import divkit.dsl.vertical
import divkit.dsl.wrapContentSize
import java.net.URLEncoder
import kotlin.text.Charsets.UTF_8

object WorkoutsListRenderer {

    const val SEARCH_TEXT_VARIABLE = "search_text"

    fun DivScope.render(
        workouts: List<WorkoutItem>,
        streakData: Int,
        streakGoal: Int,
        daysLeft: Int,
        currentStreak: Int
    ): Div {
        return container(
            width = matchParentSize(),
            height = matchParentSize(),
            orientation = vertical,
            items = listOf(
                workoutHeader(streakData, streakGoal, daysLeft, currentStreak),
                workoutSecondRow(),
                gallery(
                    width = matchParentSize(),
                    height = matchParentSize(),
                    orientation = vertical,
                    columnCount = 1,
                    items = workouts.map { workoutCard(it) }
                )
            )
        )
    }

    private fun DivScope.workoutHeader(
        streakData: Int,
        streakGoal: Int,
        daysLeft: Int,
        current: Int
    ): Div {
        val imageUrl = "http://localhost:8090/assets/fire.png"
        return container(
            orientation = horizontal,
            alignmentVertical = center,
            width = matchParentSize(),
            margins = edgeInsets(bottom = 12),
            items = listOf(
                text(
                    text = "My workouts",
                    fontSize = 30,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    margins = edgeInsets(top = 16, left = 16, right = 16, bottom = 12),
                    alignmentVertical = center
                ),
                container(
                    orientation = overlap,
                    border = border(cornerRadius = 20),
                    width = wrapContentSize(),
                    height = wrapContentSize(),
                    margins = edgeInsets(top = 16, left = 16, right = 16, bottom = 12),
                    items = listOf(
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 20),
                            paddings = edgeInsets(1),
                            background = linearGradient(
                                angle = 180,
                                colors = listOf(
                                    colorArrayElement("#99FFFFFF"),
                                    colorArrayElement("#45FFFFFF"),
                                    colorArrayElement("#00FFFFFF")
                                )
                            ).asList()
                        ),
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 19),
                            margins = edgeInsets(1),
                            background = solidBackground(color("#732AFF")).asList()
                        ),
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            background = linearGradient(
                                angle = -45,
                                colors = listOf(
                                    colorArrayElement("#45FFFFFF"),
                                    colorArrayElement("#20FFFFFF"),
                                    colorArrayElement("#00FFFFFF")
                                )
                            ).asList()
                        ),
                        container(
                            orientation = horizontal,
                            width = wrapContentSize(),
                            alignmentVertical = center,
                            border = border(cornerRadius = 20),
                            background = solidBackground(color = color("#00FFFFFF")).asList(),
                            paddings = edgeInsets(8),
                            items = listOf(
                                image(
                                    imageUrl = Url.create(imageUrl),
                                    width = fixedSize(25),
                                    height = fixedSize(25)
                                ),
                                text(
                                    text = current.toString(),
                                    fontSize = 20,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    alignmentVertical = center,
                                    paddings = edgeInsets(left = 5)
                                )
                            )
                        )
                    ),
                    actionAnimation = animation(
                        name = scale,
                        startValue = 1.0,
                        endValue = 0.9,
                        duration = 120,
                        interpolator = ease_in_out
                    ),
                    actions = listOf(
                        action(
                            logId = "open_streak",
                            url = Url.create("app://open_streak?current=$streakData&goal=$streakGoal&daysLeft=$daysLeft&total=$current")
                        )
                    )
                )
            )
        )

    }

    private fun DivScope.workoutSecondRow(): Div {
        val imageUrl = "http://localhost:8090/assets/plus.png"
        return container(
            width = matchParentSize(),
            height = wrapContentSize(),
            orientation = horizontal,
            alignmentVertical = center,
            margins = edgeInsets(left = 16, right = 16, bottom = 15),
            items = listOf(
                container(
                    orientation = overlap,
                    border = border(cornerRadius = 20),
                    width = wrapContentSize(),
                    height = wrapContentSize(),
                    items = listOf(
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 20),
                            paddings = edgeInsets(1),
                            background = linearGradient(
                                angle = 180,
                                colors = listOf(
                                    colorArrayElement("#99FFFFFF"),
                                    colorArrayElement("#45FFFFFF"),
                                    colorArrayElement("#00FFFFFF")
                                )
                            ).asList()
                        ),
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 19),
                            margins = edgeInsets(1),
                            background = solidBackground(color("#732AFF")).asList()
                        ),
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            background = linearGradient(
                                angle = -45,
                                colors = listOf(
                                    colorArrayElement("#38FFFFFF"),
                                    colorArrayElement("#19FFFFFF"),
                                    colorArrayElement("#00FFFFFF")
                                )
                            ).asList()
                        ),
                        container(
                            width = wrapContentSize(),
                            height = wrapContentSize(),
                            orientation = horizontal,
                            alignmentVertical = center,
                            border = border(cornerRadius = 19),
                            paddings = edgeInsets(8),
                            items = listOf(
                                image(
                                    imageUrl = Url.create(imageUrl),
                                    width = fixedSize(21),
                                    height = fixedSize(21)
                                )
                            )
                        )
                    ),
                    actionAnimation = animation(
                        name = scale,
                        startValue = 1.0,
                        endValue = 0.8,
                        duration = 120,
                        interpolator = ease_in_out
                    ),
                    actions = listOf(
                        action(
                            logId = "open_builder",
                            url = Url.create("app://open_builder")
                        )
                    )
                ),
                workoutSearchBar()
            )
        )
    }

    private fun DivScope.workoutSearchBar(): Div {
        val imageUrl = "http://localhost:8090/assets/search.png"
        return container(
            width = matchParentSize(),
            height = wrapContentSize(),
            margins = edgeInsets(left = 10),
            orientation = horizontal,
            alignmentVertical = center,
            items = listOf(
                container(
                    width = matchParentSize(),
                    height = wrapContentSize(),
                    orientation = horizontal,
                    alignmentVertical = center,
                    background = solidBackground(color = color("#FFFFFF")).asList(),
                    paddings = edgeInsets(7),
                    border = border(cornerRadius = 20),
                    items = listOf(
                        image(
                            imageUrl = Url.create(imageUrl),
                            width = fixedSize(22),
                            height = fixedSize(22)
                        ),
                        workoutSearchInput()
                    )
                )
            )
        )
    }

    private fun DivScope.workoutSearchInput(): Div =
        input(
            textVariable = SEARCH_TEXT_VARIABLE,
            width = matchParentSize(),
            height = matchParentSize(),
            fontSize = 16,
            textColor = color("#000000"),
            hintColor = color("#000000"),
            margins = edgeInsets(left = 10)
        )

    private fun DivScope.workoutCard(item: WorkoutItem): Div {
        val style = styleFor(item.type)


        val encoded = URLEncoder.encode(item.id, UTF_8).replace("+", "%20")
        val openUrl = Url.create("app://open_workout?id=$encoded")


        val nameEscaped = item.name.replace("'", "''")


        val bg = linearGradient(
            angle = 0,
            colors = listOf(
                colorArrayElement("#1D1D34"),
                colorArrayElement(style.backgroundColor)
            )
        ).asList()

        return render(
            WorkoutCardTemplate.template,
            WorkoutCardTemplate.titleRef bind item.name,
            WorkoutCardTemplate.subtitleRef bind typeTitle(item.type),
            WorkoutCardTemplate.iconUrlRef bind Url.create(style.iconUrl),
            WorkoutCardTemplate.openUrlRef bind openUrl,
            WorkoutCardTemplate.visibilityRef bind expression(
                "@{contains(trim(toLowerCase('$nameEscaped')), trim(toLowerCase($SEARCH_TEXT_VARIABLE))) ? 'visible' : 'gone'}"
            )
        ) + containerProps(
            background = bg,
        )

    }

    object WorkoutCardTemplate {
        val titleRef = reference<String>("title")
        val subtitleRef = reference<String>("subtitle")
        val iconUrlRef = reference<Url>("icon_url")
        val openUrlRef = reference<Url>("open_url")
        val visibilityRef = reference<Visibility>("visibility")

        val template: Template<Container> by lazy {
            template(name = "workout_card") {
                container(
                    orientation = horizontal,
                    width = matchParentSize(),
                    alignmentVertical = center,
                    paddings = edgeInsets(left = 15, right = 15, top = 15, bottom = 15),
                    margins = edgeInsets(left = 16, right = 16, top = 10),
                    border = border(cornerRadius = 22),
                    items = listOf(
                        container(
                            orientation = vertical,
                            alignmentVertical = center,
                            width = matchParentSize(),
                            items = listOf(
                                text(
                                    fontSize = 21,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                )
                                    .defer(text = titleRef),
                                text(
                                    fontSize = 12,
                                    fontWeight = regular,
                                    textColor = color("#B3FFFFFF"),
                                    margins = edgeInsets(top = 1),
                                    maxLines = 1
                                ).defer(text = subtitleRef),
                            )
                        ),
                        container(
                            width = fixedSize(72),
                            height = fixedSize(72),
                            paddings = edgeInsets(4),

                            border = border(
                                cornerRadius = 12,
                                stroke = stroke(
                                    color = color("#FFFFFF"),
                                    width = 2.0
                                )
                            ),

                            items = listOf(
                                image(
                                    width = matchParentSize(),
                                    height = matchParentSize()
                                ).defer(imageUrl = iconUrlRef)
                            )
                        )
                    ),

                    actionAnimation = animation(
                        name = scale,
                        startValue = 1.0,
                        endValue = 0.94,
                        duration = 120,
                        interpolator = ease_in_out
                    ),
                    actions = listOf(
                        action(logId = "open_workout").defer(url = openUrlRef)
                    )
                )
                    .defer(
                        visibility = visibilityRef
                    )
            }
        }
    }
}
