package com.gymbro.divkit.workoutBuilderSheet

import com.gymbro.divkit.Workout
import com.gymbro.divkit.WorkoutStyle
import com.gymbro.divkit.typeTitle
import com.gymbro.divkit.styleFor
import com.gymbro.divkit.workoutInfo.WorkoutInfoRenderer.exerciseCard
import divkit.dsl.Div
import divkit.dsl.Url
import divkit.dsl.top
import divkit.dsl.action
import divkit.dsl.animation
import divkit.dsl.asList
import divkit.dsl.bold
import divkit.dsl.border
import divkit.dsl.bottom
import divkit.dsl.center
import divkit.dsl.color
import divkit.dsl.container
import divkit.dsl.core.colorArrayElement
import divkit.dsl.ease_in_out
import divkit.dsl.edgeInsets
import divkit.dsl.fixedSize
import divkit.dsl.gallery
import divkit.dsl.horizontal
import divkit.dsl.image
import divkit.dsl.linearGradient
import divkit.dsl.matchParentSize
import divkit.dsl.overlap
import divkit.dsl.regular
import divkit.dsl.scale
import divkit.dsl.scope.DivScope
import divkit.dsl.solidBackground
import divkit.dsl.text
import divkit.dsl.vertical
import divkit.dsl.wrapContentSize

object WorkoutBuilderSheetRenderer {

    fun DivScope.render(
        workout: Workout,
    ): Div {
        return container(
            orientation = overlap,
            width = matchParentSize(),
            height = matchParentSize(),
            items = listOf(
                gallery(
                    width = matchParentSize(),
                    height = matchParentSize(),
                    paddings = edgeInsets(top = 140, bottom = 90),
                    orientation = vertical,
                    columnCount = 1,
                    items = workout.exercises.mapIndexed { index, exercise ->
                        exerciseCard(exercise, number = index + 1)
                    }
                ),
                header(
                    workout.name,
                    typeTitle(workout.type),
                    workout.exercises.count(),
                    styleFor(workout.type)
                ),
                addButton(workout.id)
            )
        )
    }

    private fun DivScope.header(
        name: String,
        type: String,
        amount: Int,
        style: WorkoutStyle
    ): Div {
        return container(
            orientation = horizontal,
            width = matchParentSize(),
            alignmentVertical = top,
            background = linearGradient(
                angle = 135,
                colors = listOf(
                    colorArrayElement("#732AFF"),
                    colorArrayElement("#B862F5")
                )
            ).asList(),
            paddings = edgeInsets(left = 15, right = 15, top = 10, bottom = 10),
            border = border(cornerRadius = 22),
            items = listOf(
                container(
                    orientation = vertical,
                    alignmentVertical = center,
                    paddings = edgeInsets( top = 10, bottom = 10),
                    width = matchParentSize(),
                    items = listOf(
                        text(
                            text = name,
                            fontSize = 21,
                            fontWeight = bold,
                            textColor = color("#FFFFFF"),
                            maxLines = 1
                        ),
                        amountLabel(amount, style.iconUrl, type)
                    )
                )
            )
        )
    }

    private fun DivScope.amountLabel(
        amount: Int,
        imageUrl: String,
        type: String
    ): Div {
        return container(
            orientation = horizontal,
            width = wrapContentSize(),
            margins = edgeInsets(top = 15),
            items = listOf(
                container(
                    orientation = horizontal,
                    width = wrapContentSize(),
                    alignmentVertical = center,
                    background = solidBackground(color("#701F1F1F")).asList(),
                    paddings = edgeInsets(10),
                    margins = edgeInsets(right = 10),
                    border = border(cornerRadius = 15),
                    items = listOf(
                        image(
                            imageUrl = Url.create(imageUrl),
                            width = fixedSize(20),
                            height = fixedSize(20)
                        ),
                        text(
                            text = type,
                            fontSize = 15,
                            fontWeight = regular,
                            textColor = color("#FFFFFF"),
                            paddings = edgeInsets(left = 10),
                            maxLines = 1
                        )
                    )
                ),
                container(
                    orientation = horizontal,
                    width = wrapContentSize(),
                    alignmentVertical = center,
                    background = solidBackground(color("#701F1F1F")).asList(),
                    paddings = edgeInsets(10),
                    border = border(cornerRadius = 15),
                    items = listOf(
                        image(
                            imageUrl = Url.create("http://localhost:8090/assets/dumbell.png"),
                            width = fixedSize(20),
                            height = fixedSize(20)
                        ),
                        text(
                            text = "${amount} exercises",
                            fontSize = 15,
                            fontWeight = regular,
                            textColor = color("#FFFFFF"),
                            paddings = edgeInsets(left = 10),
                            maxLines = 1
                        )
                    )
                )
            )
        )
    }

    private fun DivScope.addButton(
        id: String
    ): Div {
        return container(
            orientation = vertical,
            alignmentVertical = bottom,
            contentAlignmentVertical = bottom,
            width = matchParentSize(),
            height = matchParentSize(),
            items = listOf(
                container(
                    orientation = overlap,
                    contentAlignmentVertical = bottom,
                    border = border(cornerRadius = 28),
                    width = matchParentSize(),
                    height = wrapContentSize(),
                    margins = edgeInsets(top = 16, left = 16, right = 16, bottom = 25),
                    items = listOf(
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 28),
                            paddings = edgeInsets(1),
                            background = linearGradient(
                                angle = 180,
                                colors = listOf(
                                    colorArrayElement("#70FFFFFF"),
                                    colorArrayElement("#45FFFFFF"),
                                    colorArrayElement("#00FFFFFF")
                                )
                            ).asList()
                        ),
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 26),
                            margins = edgeInsets(2),
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
                            alignmentHorizontal = center,
                            border = border(cornerRadius = 28),
                            background = solidBackground(color = color("#00FFFFFF")).asList(),
                            paddings = edgeInsets(18),
                            items = listOf(
                                text(
                                    text = "Add to my workouts",
                                    fontSize = 18,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    alignmentVertical = center
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
                            logId = "save_workout",
                            url = Url.create("app://save_workout?id=$id&")
                        )
                    )
                )
            )
        )
    }
}