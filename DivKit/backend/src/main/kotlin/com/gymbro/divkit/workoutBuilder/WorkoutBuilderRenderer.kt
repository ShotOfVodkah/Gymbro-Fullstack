package com.gymbro.divkit.workoutBuilder

import divkit.dsl.Background
import divkit.dsl.Container
import divkit.dsl.Div
import divkit.dsl.Template
import divkit.dsl.Url
import divkit.dsl.Visibility
import divkit.dsl.action
import divkit.dsl.animation
import divkit.dsl.asList
import divkit.dsl.bold
import divkit.dsl.border
import divkit.dsl.center
import divkit.dsl.Color
import divkit.dsl.color
import divkit.dsl.core.bind
import divkit.dsl.core.colorArrayElement
import divkit.dsl.core.expression
import divkit.dsl.core.reference
import divkit.dsl.defer
import divkit.dsl.edgeInsets
import divkit.dsl.ease_in_out
import divkit.dsl.fixedSize
import divkit.dsl.linearGradient
import divkit.dsl.matchParentSize
import divkit.dsl.overlap
import divkit.dsl.render
import divkit.dsl.scale
import divkit.dsl.scope.DivScope
import divkit.dsl.solidBackground
import divkit.dsl.stroke
import divkit.dsl.template
import divkit.dsl.text
import divkit.dsl.vertical
import divkit.dsl.plus
import divkit.dsl.container
import divkit.dsl.containerProps

object WorkoutBuilderRenderer {

    data class ToggleGroup(
        val id: String,
        val title: String,
        val items: List<ToggleItem>
    )

    data class ToggleItem(
        val id: String,
        val firstText: String,
        val secondText: String
    )

    // --- SECTION RENDER ---

    fun DivScope.render(groups: List<ToggleGroup>): Div {
        return container(
            width = matchParentSize(),
            height = matchParentSize(),
            orientation = vertical,
            paddings = edgeInsets(top = 16, bottom = 16),
            items = listOf(
                text(
                    text = "Первые плашки",
                    fontSize = 20,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    margins = edgeInsets(left = 16, right = 16, bottom = 10)
                ),
                firstPlatesSection(groups),

                text(
                    text = "Вторые плашки",
                    fontSize = 20,
                    fontWeight = bold,
                    textColor = color("#FFFFFF"),
                    margins = edgeInsets(left = 16, right = 16, top = 18, bottom = 10)
                ),
                secondPlatesSection(groups),
            )
        )
    }

    private fun DivScope.firstPlatesSection(groups: List<ToggleGroup>): Div {
        return container(
            width = matchParentSize(),
            orientation = vertical,
            items = groups.flatMap { g ->
                buildList {
                    if (g.title.isNotBlank()) {
                        add(
                            text(
                                text = g.title,
                                fontSize = 14,
                                textColor = color("#B3FFFFFF"),
                                margins = edgeInsets(left = 16, right = 16, bottom = 8)
                            )
                        )
                    }

                    addAll(
                        g.items.map { item ->
                            val v = varName(g.id, item.id)

                            firstPlate(
                                textValue = item.firstText,
                                onClickUrl = toggleVariableUrl(v)
                            )
                        }
                    )
                }
            }
        )
    }

    private fun DivScope.secondPlatesSection(groups: List<ToggleGroup>): Div {
        return container(
            width = matchParentSize(),
            orientation = vertical,
            items = groups.flatMap { g ->
                buildList {
                    if (g.title.isNotBlank()) {
                        add(
                            text(
                                text = g.title,
                                fontSize = 14,
                                textColor = color("#B3FFFFFF"),
                                margins = edgeInsets(left = 16, right = 16, bottom = 8)
                            )
                        )
                    }

                    addAll(
                        g.items.map { item ->
                            val v = varName(g.id, item.id)

                            secondPlate(
                                textValue = item.secondText,
                                visibilityExpr = "@{$v ? 'visible' : 'gone'}"
                            )
                        }
                    )
                }
            }
        )
    }

    // --- ACTIONS / VARS ---

    private fun toggleVariableUrl(varName: String): Url {
        val valueExpr = "@{!$varName}"
        return Url.create("div-action://set_variable?name=$varName&value=$valueExpr")
    }

    private fun varName(groupId: String, itemId: String): String {
        fun String.sanitize() = replace(Regex("[^A-Za-z0-9_]"), "_")
        return "toggle_${groupId.sanitize()}_${itemId.sanitize()}"
    }

    // --- PLATES ---

    private fun DivScope.firstPlate(textValue: String, onClickUrl: Url): Div {
        val bg = linearGradient(
            angle = 0,
            colors = listOf(
                colorArrayElement("#1D1D34"),
                colorArrayElement("#732AFF")
            )
        ).asList()

        return render(
            PlateTemplate.template,
            PlateTemplate.textRef bind textValue,
            PlateTemplate.bgRef bind bg,
            PlateTemplate.strokeColorRef bind color("#55FFFFFF"),
            PlateTemplate.onClickUrlRef bind onClickUrl,
            PlateTemplate.visibilityRef bind expression("'visible'")
        )
    }

    private fun DivScope.secondPlate(textValue: String, visibilityExpr: String): Div {
        val bg = linearGradient(
            angle = 0,
            colors = listOf(
                colorArrayElement("#182034"),
                colorArrayElement("#2C7CFF")
            )
        ).asList()

        return render(
            PlateTemplate.template,
            PlateTemplate.textRef bind textValue,
            PlateTemplate.bgRef bind bg,
            PlateTemplate.strokeColorRef bind color("#33FFFFFF"),
            PlateTemplate.onClickUrlRef bind Url.create("div-action://noop"),
            // ВОТ ТУТ ГЛАВНОЕ: Visibility как в WorkoutsListRenderer
            PlateTemplate.visibilityRef bind expression(visibilityExpr)
        ) + containerProps(
            margins = edgeInsets(top = 10)
        )
    }

    // --- TEMPLATE ---

    object PlateTemplate {
        val textRef = reference<String>("text")
        val bgRef = reference<List<Background>>("bg")
        val strokeColorRef = reference<Color>("stroke_color")
        val onClickUrlRef = reference<Url>("on_click_url")
        val visibilityRef = reference<Visibility>("visibility")

        val template: Template<Container> by lazy {
            template(name = "toggle_plate") {
                container(
                    width = matchParentSize(),
                    height = fixedSize(64),
                    orientation = overlap,
                    border = border(
                        cornerRadius = 18,
                        stroke = stroke(width = 1.0)
                    ),
                    margins = edgeInsets(left = 16, right = 16),
                    items = listOf(
                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            border = border(cornerRadius = 18),
                            background = solidBackground(color("#00FFFFFF")).asList()
                        ).defer(background = bgRef),

                        container(
                            width = matchParentSize(),
                            height = matchParentSize(),
                            alignmentVertical = center,
                            paddings = edgeInsets(left = 16, right = 16),
                            items = listOf(
                                text(
                                    fontSize = 15,
                                    fontWeight = bold,
                                    textColor = color("#FFFFFF"),
                                    maxLines = 2
                                ).defer(text = textRef)
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
                        action(logId = "toggle_plate_click").defer(url = onClickUrlRef)
                    )
                ).defer(
                    // и visibility правильно задаём тут
                    visibility = visibilityRef
                )
            }
        }
    }
}
