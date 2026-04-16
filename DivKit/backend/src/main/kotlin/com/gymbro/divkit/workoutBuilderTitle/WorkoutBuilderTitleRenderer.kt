package com.gymbro.divkit.workoutBuilderTitle

import com.gymbro.divkit.WorkoutStyle
import com.gymbro.divkit.WorkoutType
import com.gymbro.divkit.styleFor
import com.gymbro.divkit.Workout

import divkit.dsl.Div
import divkit.dsl.Url
import divkit.dsl.action
import divkit.dsl.pager
import divkit.dsl.animation
import divkit.dsl.asList
import divkit.dsl.bold
import divkit.dsl.indicator
import divkit.dsl.border
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
import divkit.dsl.list
import divkit.dsl.matchParentSize
import divkit.dsl.medium
import divkit.dsl.overlap
import divkit.dsl.scale
import divkit.dsl.scope.DivScope
import divkit.dsl.solidBackground
import divkit.dsl.text
import divkit.dsl.vertical
import divkit.dsl.wrapContentSize
import divkit.dsl.neighbourPageSize
import divkit.dsl.regular
import divkit.dsl.roundedRectangleShape

object WorkoutBuilderTitleRenderer {

    fun DivScope.render(
        workouts: List<Workout>,
        t: WorkoutBuilderTitleTranslations,
    ): Div {
        return container(
            width = matchParentSize(),
            height = matchParentSize(),
            orientation = vertical,
            paddings = edgeInsets(top = 16, bottom = 16),
            items = listOf(
                screenHeader(t),
                gallery(
                    width = matchParentSize(),
                    height = matchParentSize(),
                    orientation = vertical,
                    columnCount = 1,
                    items = listOf(
                        aiCard(t),
                        categories(t),
                        pagerWithIndicator(
                            t = t,
                            items = workouts.map { workout ->
                                premadeCard(
                                    name = workout.name,
                                    workoutType = workout.type,
                                    color = styleFor(workout.type).backgroundColor,
                                    amount = workout.exercises.count(),
                                    id = workout.id,
                                    t = t,
                                )
                            }
                        )
                    )
                )
            )
        )
    }

    private fun DivScope.screenHeader(t: WorkoutBuilderTitleTranslations): Div {
        return container(
            orientation = vertical,
            alignmentVertical = center,
            width = matchParentSize(),
            items = listOf(
                text(
                    text = t.screenTitle(),
                    fontSize = 30,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    margins = edgeInsets( left = 45, right = 16, bottom = 12),
                    alignmentVertical = center
                ),
                text(
                    text = t.screenSubtitle(),
                    fontSize = 16,
                    margins = edgeInsets(left = 20, right = 20, bottom = 17),
                    fontWeight = bold,
                    textColor = color("#4A4A4A"),
                )
            )
        )
    }

    private fun DivScope.aiCard(t: WorkoutBuilderTitleTranslations): Div {
        val imageUrl = "http://localhost:8090/assets/lightning.png"
        return container(
            orientation = vertical,
            alignmentVertical = center,
            width = matchParentSize(),
            background = linearGradient(
                angle = 135,
                colors = listOf(
                    colorArrayElement("#732AFF"),
                    colorArrayElement("#B862F5")
                )
            ).asList(),
            margins = edgeInsets(left = 20, right = 20),
            paddings = edgeInsets(20),
            border = border(cornerRadius = 15),
            items = listOf(
                container(
                    orientation = horizontal,
                    width = wrapContentSize(),
                    alignmentVertical = center,
                    background = solidBackground(color("#40FFFFFF")).asList(),
                    paddings = edgeInsets(10),
                    border = border(cornerRadius = 15),
                    items = listOf(
                        image(
                            imageUrl = Url.create(imageUrl),
                            width = fixedSize(20),
                            height = fixedSize(20)
                        ),
                    )
                ),
                text(
                    text = t.aiCardTitle(),
                    fontSize = 20,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    margins = edgeInsets(top = 10),
                    alignmentVertical = center
                ),
                text(
                    text = t.aiCardBody(),
                    fontSize = 16,
                    margins = edgeInsets(top = 10),
                    fontWeight = medium,
                    textColor = color("#75FFFFFF"),
                ),
                aiButton(t)
            )
        )
    }

    private fun DivScope.aiButton(t: WorkoutBuilderTitleTranslations): Div {
        return container(
            orientation = overlap,
            border = border(cornerRadius = 28),
            width = matchParentSize(),
            height = wrapContentSize(),
            margins = edgeInsets(top = 16, left = 16, right = 16),
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
                            text = t.aiCta(),
                            fontSize = 16,
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
                    logId = "open_ai",
                    url = Url.create("app://open_ai")
                )
            )
        )
    }

    private fun DivScope.categories(t: WorkoutBuilderTitleTranslations): Div {
        return container(
            orientation = vertical,
            width = matchParentSize(),
            height = wrapContentSize(),
            margins = edgeInsets(top = 16, right = 16),
            items = listOf(
                text(
                    text = t.buildByCategory(),
                    fontSize = 20,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    alignmentVertical = center,
                    margins = edgeInsets(left = 16),
                ),
                container(
                    orientation = horizontal,
                    width = matchParentSize(),
                    height = wrapContentSize(),
                    margins = edgeInsets(top = 16),
                    items = listOf(
                        typeCard(styleFor(WorkoutType.YOGA), WorkoutType.YOGA, t),
                        typeCard(styleFor(WorkoutType.STRENGTH), WorkoutType.STRENGTH, t),
                        typeCard(styleFor(WorkoutType.CARDIO), WorkoutType.CARDIO, t),
                    )
                )
            )
        )
    }

    private fun DivScope.typeCard(
        style: WorkoutStyle,
        type: WorkoutType,
        t: WorkoutBuilderTitleTranslations,
    ): Div {
        return container(
            orientation = vertical,
            alignmentVertical = center,
            alignmentHorizontal = center,
            contentAlignmentHorizontal = center,
            width = matchParentSize(),
            background = linearGradient(
                angle = 90,
                colors = listOf(
                    colorArrayElement("#1D1D34"),
                    colorArrayElement(style.backgroundColor)
                )
            ).asList(),
            margins = edgeInsets(left = 16),
            paddings = edgeInsets(20),
            border = border(cornerRadius = 15),
            items = listOf(
                image(
                    imageUrl = Url.create(style.iconUrl),
                    width = fixedSize(50),
                    height = fixedSize(50),
                    alignmentHorizontal = center
                ),
                text(
                    text = t.workoutTypeLabel(type),
                    fontSize = 16,
                    margins = edgeInsets(top = 10),
                    fontWeight = medium,
                    textColor = color("#FFFFFF"),
                    textAlignmentHorizontal = center,
                    width = matchParentSize()
                ),
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
                    logId = "open_builder_for_type",
                    url = Url.create("app://open_builder_for_type?type=${t.workoutTypeQueryParam(type)}&")
                )
            )
        )
    }

    private fun DivScope.premadeCard(
        name: String,
        workoutType: WorkoutType,
        color: String,
        amount: Int,
        id: String,
        t: WorkoutBuilderTitleTranslations,
    ): Div {
        return container(
            orientation = vertical,
            alignmentVertical = center,
            contentAlignmentVertical = center,
            alignmentHorizontal = center,
            contentAlignmentHorizontal = center,
            width = matchParentSize(),
            background = solidBackground(color("#1D1D34")).asList(),
            paddings = edgeInsets(20),
            border = border(cornerRadius = 15),
            items = listOf(
                container(
                    orientation = overlap,
                    border = border(cornerRadius = 28),
                    width = matchParentSize(),
                    height = wrapContentSize(),
                    margins = edgeInsets(top = 16, left = 16, right = 16),
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
                            margins = edgeInsets(1),
                            background = solidBackground(color(color)).asList()
                        ),
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            background = linearGradient(
                                angle = -45,
                                colors = listOf(
                                    colorArrayElement("#25FFFFFF"),
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
                            paddings = edgeInsets(10),
                            items = listOf(
                                text(
                                    text = name,
                                    fontSize = 20,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    alignmentVertical = center
                                ),
                            )
                        )
                    ),
                ),
                text(
                    text = t.premadeMetaLine(workoutType, amount),
                    fontSize = 15,
                    fontWeight = bold,
                    textColor = color("#90FFFFFF"),
                    paddings = edgeInsets(all = 10),
                    maxLines = 1,
                    textAlignmentHorizontal = center,
                    width = matchParentSize()
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
                    logId = "open_premade",
                    url = Url.create("app://open_premade?id=$id&")
                )
            )
        )
    }

    private fun DivScope.pagerWithIndicator(
        pagerId: String = "pager_with_indicator",
        t: WorkoutBuilderTitleTranslations,
        items: List<Div>,
    ): Div {
        return container(
            orientation = vertical,
            items = listOf(
                text(
                    text = t.selectPremade(),
                    fontSize = 20,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    alignmentVertical = center,
                    margins = edgeInsets(left = 16, top = 16),
                ),
                pager(
                    id = pagerId,
                    height = wrapContentSize(),
                    paddings = edgeInsets(left = 4, right = 4),
                    margins = edgeInsets(top = 16),
                    itemSpacing = fixedSize(15),
                    items = items,
                    layoutMode = neighbourPageSize(
                        neighbourPageWidth = fixedSize(16)
                    )
                ),
                indicator(
                    pagerId = pagerId,
                    activeItemSize = 1.5,
                    height =  wrapContentSize(),
                    width =  matchParentSize(),
                    margins = edgeInsets(top = 10),
                    paddings = edgeInsets(left = 10, right = 10),
                    spaceBetweenCenters = fixedSize(20),
                    activeShape = roundedRectangleShape(
                        itemHeight = fixedSize(10),
                        itemWidth = fixedSize(20),
                        backgroundColor = color("#B862F5"),
                    ),
                    inactiveShape = roundedRectangleShape(
                        itemHeight = fixedSize(10),
                        itemWidth = fixedSize(10),
                        backgroundColor = color("#D0D1D9"),
                    )
                ),
            )
        )
    }
}