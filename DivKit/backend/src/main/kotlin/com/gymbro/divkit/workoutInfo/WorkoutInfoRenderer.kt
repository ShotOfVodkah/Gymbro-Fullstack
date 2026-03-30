package com.gymbro.divkit.workoutInfo

import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.typeTitle
import com.gymbro.divkit.styleFor
import com.gymbro.divkit.WorkoutStyle
import com.gymbro.divkit.Workout
import com.gymbro.divkit.Exercise
import com.gymbro.divkit.StrengthExercise
import com.gymbro.divkit.CardioExercise
import com.gymbro.divkit.YogaExercise
import com.gymbro.divkit.nameFor

import divkit.dsl.Div
import divkit.dsl.medium
import divkit.dsl.Url
import divkit.dsl.action
import divkit.dsl.animation
import divkit.dsl.asList
import divkit.dsl.bold
import divkit.dsl.border
import divkit.dsl.bottom
import divkit.dsl.center
import divkit.dsl.right
import divkit.dsl.color
import divkit.dsl.container
import divkit.dsl.core.colorArrayElement
import divkit.dsl.defer
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

object WorkoutInfoRenderer {

    fun DivScope.render(
        workout: Workout
    ): Div {
        return container(
            width = matchParentSize(),
            height = matchParentSize(),
            orientation = overlap,
            items = listOf(
                container(
                    width = matchParentSize(),
                    height = matchParentSize(),
                    orientation = vertical,
                    items = listOf(
                        buttons(workout.id),
                        header(
                            workout.name,
                            typeTitle(workout.type),
                            workout.exercises.count(),
                            styleFor(workout.type)
                        ),
                        text(
                            text = "EXERCISES",
                            fontSize = 16,
                            margins = edgeInsets(left = 25, top = 17, bottom = 17),
                            fontWeight = bold,
                            textColor = color("#4A4A4A"),
                            maxLines = 1
                        ),
                        gallery(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            orientation = vertical,
                            columnCount = 1,
                            items = workout.exercises.mapIndexed { index, exercise ->
                                exerciseCard(exercise, number = index + 1)
                            }
                        )
                    )
                ),
                playButton(workout.id)
            )
        )
    }

    private fun DivScope.buttons(
        id: String
    ): Div {
        return container(
            orientation = horizontal,
            width = matchParentSize(),
            contentAlignmentHorizontal = right,
            items = listOf(
                container(
                    orientation = overlap,
                    border = border(cornerRadius = 20),
                    width = wrapContentSize(),
                    height = wrapContentSize(),
                    margins = edgeInsets(top = 16, left = 16, bottom = 12),
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
                                    imageUrl = Url.create("http://localhost:8090/assets/edit.png"),
                                    width = fixedSize(21),
                                    height = fixedSize(21)
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
                            logId = "edit",
                            url = Url.create("app://edit?id=$id")
                        )
                    )
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
                                imageUrl = Url.create("http://localhost:8090/assets/trash.png"),
                                width = fixedSize(21),
                                height = fixedSize(21)
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
                        logId = "delete",
                        url = Url.create("app://delete?id=$id")
                    )
                )
            )
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
            alignmentVertical = center,
            background = linearGradient(
                angle = 0,
                colors = listOf(
                    colorArrayElement(style.backgroundColor),
                    colorArrayElement("#732AFF"),
                )
            ).asList(),
            paddings = edgeInsets(left = 15, right = 15, top = 10, bottom = 10),
            margins = edgeInsets(left = 16, right = 16, top = 10, bottom = 0),
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

    private fun DivScope.playButton(
        id: String
    ): Div {
        return container(
            orientation = overlap,
            border = border(cornerRadius = 28),
            alignmentVertical = bottom,
            width = matchParentSize(),
            height = wrapContentSize(),
            margins = edgeInsets( left = 10, right = 10, bottom = 25),
            items = listOf(
                container(
                    width = matchParentSize(),
                    height = matchParentSize(),
                    border = border(cornerRadius = 28),
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
                        text = "Start Workout",
                        fontSize = 20,
                        fontWeight = medium,
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
                logId = "open_streak",
                url = Url.create("app://open_player?id=$id&")
            )
        )
        )
    }

    fun DivScope.exerciseCard(
        exercise: Exercise,
        number: Int
    ): Div {
        return when (exercise) {
            is StrengthExercise -> strengthExerciseCard(exercise, number, styleFor(WorkoutType.STRENGTH).backgroundColor)
            is CardioExercise -> cardioExerciseCard(exercise, number, styleFor(WorkoutType.CARDIO).backgroundColor)
            is YogaExercise -> yogaExerciseCard(exercise, number, styleFor(WorkoutType.YOGA).backgroundColor)
        }
    }

    private fun DivScope.cardioExerciseCard(
        exercise: CardioExercise,
        number: Int,
        color: String
    ): Div {
        return container(
            orientation = vertical,
            width = matchParentSize(),
            alignmentVertical = center,
            background = linearGradient(
                angle = 0,
                colors = listOf(
                    colorArrayElement("#1D1D34"),
                    colorArrayElement(color)
                )
            ).asList(),
            paddings = edgeInsets(left = 15, right = 15, top = 10, bottom = 10),
            margins = edgeInsets(left = 16, right = 16, bottom = 5),
            border = border(cornerRadius = 22),
            items = listOf(
                container(
                    orientation = horizontal,
                    alignmentVertical = center,
                    paddings = edgeInsets( top = 10, bottom = 10),
                    width = matchParentSize(),
                    items = listOf(
                        container(
                            orientation = horizontal,
                            alignmentVertical = center,
                            width = wrapContentSize(),
                            alignmentHorizontal = center,
                            background = solidBackground(color("#501F1F1F")).asList(),
                            paddings = edgeInsets(10),
                            margins = edgeInsets(right = 20),
                            border = border(cornerRadius = 10),
                            items = listOf(
                                text(
                                    text = "${number}",
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    fontSize = 15,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                )
                            )
                        ),

                        container(
                            orientation = horizontal,
                            alignmentVertical = center,
                            width = wrapContentSize(),
                            items = listOf(
                                text(
                                    text = exercise.name,
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    fontSize = 18,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                ),
                                container(
                                    orientation = horizontal,
                                    width = wrapContentSize(),
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    background = solidBackground(color("#501F1F1F")).asList(),
                                    paddings = edgeInsets(10),
                                    margins = edgeInsets(left = 10),
                                    border = border(cornerRadius = 15),
                                    items = listOf(
                                        text(
                                            text = nameFor(exercise.muscleGroup),
                                            alignmentVertical = center,
                                            alignmentHorizontal = center,
                                            fontSize = 15,
                                            fontWeight = regular,
                                            textColor = color("#FFFFFF"),
                                            maxLines = 1
                                        )
                                    )
                                )
                            )
                        )
                    )
                ),
                container(
                    orientation = horizontal,
                    alignmentVertical = center,
                    width = matchParentSize(),
                    contentAlignmentHorizontal = center,
                    margins = edgeInsets(left = 35),
                    paddings = edgeInsets( top = 5, bottom = 10),
                    items = listOf(
                        statCard("Duration","${exercise.durationMinutes} min"),
                        statCard("Pace","${nameFor(exercise.pace)}")
                    )
                )
            )
        )
    }

    private fun DivScope.yogaExerciseCard(
        exercise: YogaExercise,
        number: Int,
        color: String
    ): Div {
        return container(
            orientation = vertical,
            width = matchParentSize(),
            alignmentVertical = center,
            background = linearGradient(
                angle = 0,
                colors = listOf(
                    colorArrayElement("#1D1D34"),
                    colorArrayElement(color)
                )
            ).asList(),
            paddings = edgeInsets(left = 15, right = 15, top = 10, bottom = 10),
            margins = edgeInsets(left = 16, right = 16, bottom = 5),
            border = border(cornerRadius = 22),
            items = listOf(
                container(
                    orientation = horizontal,
                    alignmentVertical = center,
                    paddings = edgeInsets( top = 10, bottom = 10),
                    width = matchParentSize(),
                    items = listOf(
                        container(
                            orientation = horizontal,
                            alignmentVertical = center,
                            width = wrapContentSize(),
                            alignmentHorizontal = center,
                            background = solidBackground(color("#501F1F1F")).asList(),
                            paddings = edgeInsets(10),
                            margins = edgeInsets(right = 20),
                            border = border(cornerRadius = 10),
                            items = listOf(
                                text(
                                    text = "${number}",
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    fontSize = 15,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                )
                            )
                        ),

                        container(
                            orientation = horizontal,
                            alignmentVertical = center,
                            width = wrapContentSize(),
                            items = listOf(
                                text(
                                    text = exercise.name,
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    fontSize = 18,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                ),
                                container(
                                    orientation = horizontal,
                                    width = wrapContentSize(),
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    background = solidBackground(color("#501F1F1F")).asList(),
                                    paddings = edgeInsets(10),
                                    margins = edgeInsets(left = 10),
                                    border = border(cornerRadius = 15),
                                    items = listOf(
                                        text(
                                            text = nameFor(exercise.muscleGroup),
                                            alignmentVertical = center,
                                            alignmentHorizontal = center,
                                            fontSize = 15,
                                            fontWeight = regular,
                                            textColor = color("#FFFFFF"),
                                            maxLines = 1
                                        )
                                    )
                                )
                            )
                        )
                    )
                ),
                container(
                    orientation = horizontal,
                    alignmentVertical = center,
                    width = matchParentSize(),
                    contentAlignmentHorizontal = center,
                    margins = edgeInsets(left = 35),
                    paddings = edgeInsets( top = 5, bottom = 10),
                    items = listOf(
                        statCard("Hold for","${exercise.holdSeconds} sec"),
                        statCard("Breath Count","${exercise.breathCount}/min")
                    )
                )
            )
        )
    }

    private fun DivScope.strengthExerciseCard(
        exercise: StrengthExercise,
        number: Int,
        color: String
    ): Div {
        return container(
            orientation = vertical,
            width = matchParentSize(),
            alignmentVertical = center,
            background = linearGradient(
                angle = 0,
                colors = listOf(
                    colorArrayElement("#1D1D34"),
                    colorArrayElement(color)
                )
            ).asList(),
            paddings = edgeInsets(left = 15, right = 15, top = 10, bottom = 10),
            margins = edgeInsets(left = 16, right = 16, bottom = 5),
            border = border(cornerRadius = 22),
            items = listOf(
                container(
                    orientation = horizontal,
                    alignmentVertical = center,
                    paddings = edgeInsets( top = 10, bottom = 10),
                    width = matchParentSize(),
                    items = listOf(
                        container(
                            orientation = horizontal,
                            alignmentVertical = center,
                            width = wrapContentSize(),
                            alignmentHorizontal = center,
                            background = solidBackground(color("#501F1F1F")).asList(),
                            paddings = edgeInsets(10),
                            margins = edgeInsets(right = 30),
                            border = border(cornerRadius = 10),
                            items = listOf(
                                text(
                                    text = "${number}",
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    fontSize = 15,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                )
                            )
                        ),

                        container(
                            orientation = horizontal,
                            alignmentVertical = center,
                            width = wrapContentSize(),
                            items = listOf(
                                text(
                                    text = exercise.name,
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    fontSize = 18,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 1
                                ),
                                container(
                                    orientation = horizontal,
                                    width = wrapContentSize(),
                                    alignmentVertical = center,
                                    alignmentHorizontal = center,
                                    background = solidBackground(color("#501F1F1F")).asList(),
                                    paddings = edgeInsets(10),
                                    margins = edgeInsets(left = 10),
                                    border = border(cornerRadius = 15),
                                    items = listOf(
                                        text(
                                            text = nameFor(exercise.muscleGroup),
                                            alignmentVertical = center,
                                            alignmentHorizontal = center,
                                            fontSize = 15,
                                            fontWeight = regular,
                                            textColor = color("#FFFFFF"),
                                            maxLines = 1
                                        )
                                    )
                                )
                            )
                        )
                    )
                ),
                container(
                    orientation = horizontal,
                    alignmentVertical = center,
                    width = matchParentSize(),
                    contentAlignmentHorizontal = center,
                    margins = edgeInsets(left = 35),
                    paddings = edgeInsets( top = 5, bottom = 10),
                    items = listOf(
                        statCard("Sets","${exercise.sets}"),
                        statCard("Reps","${exercise.reps}"),
                        statCard("Weight","${exercise.weightKg} Kg"),
                    )
                )
            )
        )
    }

    private fun DivScope.statCard (
        name: String,
        text: String
    ): Div {
        return container(
            orientation = vertical,
            alignmentVertical = center,
            width = matchParentSize(),
            alignmentHorizontal = center,
            background = solidBackground(color("#501F1F1F")).asList(),
            paddings = edgeInsets(top = 5, bottom = 5, right = 20, left = 20),
            margins = edgeInsets(right = 10),
            border = border(cornerRadius = 10),
            items = listOf(
                text(
                    text = name,
                    alignmentVertical = center,
                    alignmentHorizontal = center,
                    width = wrapContentSize(),
                    fontSize = 15,
                    fontWeight = bold,
                    margins = edgeInsets(top = 5, bottom = 10),
                    textColor = color("#55FFFFFF"),
                    maxLines = 1
                ),
                text(
                    text = text,
                    alignmentVertical = center,
                    alignmentHorizontal = center,
                    width = wrapContentSize(),
                    margins = edgeInsets(bottom = 5),
                    fontSize = 15,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    maxLines = 1
                )
            )
        )
    }
}