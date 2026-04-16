package com.gymbro.divkit.workoutBuilderForType

import com.gymbro.divkit.Exercise
import com.gymbro.divkit.i18n.DomainStrings
import divkit.dsl.Background
import divkit.dsl.Container
import divkit.dsl.Div
import divkit.dsl.Template
import divkit.dsl.Url
import divkit.dsl.action
import divkit.dsl.animation
import divkit.dsl.asList
import divkit.dsl.bold
import divkit.dsl.plus
import divkit.dsl.border
import divkit.dsl.center
import divkit.dsl.Color
import divkit.dsl.color
import divkit.dsl.core.colorArrayElement
import divkit.dsl.container
import divkit.dsl.containerProps
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
import divkit.dsl.state
import divkit.dsl.stateItem
import divkit.dsl.stroke
import divkit.dsl.template
import divkit.dsl.text
import divkit.dsl.vertical
import divkit.dsl.core.bind
import divkit.dsl.gallery
import divkit.dsl.horizontal
import divkit.dsl.regular
import divkit.dsl.wrapContentSize

object WorkoutBuilderForTypeRenderer {

    private const val COLLAPSED = "collapsed"
    private const val EXPANDED = "expanded"

    fun DivScope.render(
        exercises: List<Exercise>,
        color: String,
        selectedIds: Set<String>,
        domain: DomainStrings,
    ): Div {
        return container(
            width = matchParentSize(),
            height = matchParentSize(),
            orientation = vertical,
            items = listOf(
                gallery(
                    width = matchParentSize(),
                    height = matchParentSize(),
                    orientation = vertical,
                    paddings = edgeInsets(bottom = 100),
                    columnCount = 1,
                    items = exercises.map { exercise ->
                        toggleStateBlock(
                            id = exercise.id,
                            name = exercise.name,
                            group = domain.muscle(exercise.muscleGroup),
                            color = color,
                            isSelected = exercise.id in selectedIds
                        )
                    }
                )
            )
        )
    }

    private fun DivScope.toggleStateBlock(
        id: String,
        name: String,
        group: String,
        color: String,
        isSelected: Boolean
    ): Div {
        return state(
            id = id,
            defaultStateId = if (isSelected) EXPANDED else COLLAPSED,
            states = listOf(
                stateItem(
                    stateId = COLLAPSED,
                    div = container(
                        width = matchParentSize(),
                        orientation = vertical,
                        items = listOf(
                            plate(
                                background = solidBackground(color("#1D1D34")).asList(),
                                name = name,
                                group = group,
                                onClickUrl = setStateUrl(
                                    outerStateId = 0,
                                    stateBlockId = id,
                                    target = EXPANDED
                                ),
                                outerUrl = Url.create("app://add?id=$id"),
                                borderRef = color("#334155"),
                                fillRef = color("#00FFFFFF")
                            )
                        )
                    )
                ),
                stateItem(
                    stateId = EXPANDED,
                    div = container(
                        width = matchParentSize(),
                        orientation = vertical,
                        items = listOf(
                            plate(
                                background = linearGradient(
                                    angle = 0,
                                    colors = listOf(
                                        colorArrayElement("#1D1D34"),
                                        colorArrayElement(color)
                                    )
                                ).asList(),
                                name = name,
                                group = group,
                                onClickUrl = setStateUrl(
                                    outerStateId = 0,
                                    stateBlockId = id,
                                    target = COLLAPSED,
                                ),
                                outerUrl = Url.create("app://remove?id=$id"),
                                borderRef = color("#FFFFFF"),
                                fillRef = color("#FFFFFF")
                            )
                        )
                    )
                )
            ),

        )
    }

    private fun setStateUrl(outerStateId: Int, stateBlockId: String, target: String): Url {
        return Url.create("div-action://set_state?state_id=$outerStateId/$stateBlockId/$target")
    }

    private fun DivScope.plate(
        background: List<Background>,
        name: String,
        group: String,
        onClickUrl: Url,
        outerUrl: Url,
        borderRef: Color,
        fillRef: Color,
    ): Div {
        return render(
            PlateTemplate.template,
            PlateTemplate.nameRef bind name,
            PlateTemplate.groupRef bind group,
            PlateTemplate.bgRef bind background,
            PlateTemplate.onClickUrlRef bind onClickUrl,
            PlateTemplate.onClickOuterUrlRef bind outerUrl,
            PlateTemplate.borderRef bind borderRef,
            PlateTemplate.fillRef bind fillRef
        )
    }

    object PlateTemplate {
        val nameRef = divkit.dsl.core.reference<String>("text")
        val groupRef = divkit.dsl.core.reference<String>("group")
        val bgRef = divkit.dsl.core.reference<List<Background>>("bg")
        val onClickUrlRef = divkit.dsl.core.reference<Url>("on_click_url")
        val onClickOuterUrlRef = divkit.dsl.core.reference<Url>("on_click_outer_url")
        val borderRef = divkit.dsl.core.reference<Color>("border_ref")
        val fillRef = divkit.dsl.core.reference<Color>("fill_ref")

        val template: Template<Container> by lazy {
            template(name = "toggle_plate") {
                container(
                    width = matchParentSize(),
                    height = wrapContentSize(),
                    orientation = overlap,
                    border = border(
                        cornerRadius = 18,
                        stroke = stroke(width = 1.0)
                    ),
                    margins = edgeInsets(left = 16, right = 16, bottom = 5),
                    paddings = edgeInsets(16),
                    items = listOf(
                        container(
                            orientation = horizontal,
                            width = matchParentSize(),
                            height = matchParentSize(),
                            contentAlignmentVertical = center,
                            paddings = edgeInsets(left = 16, right = 16),
                            items = listOf(
                                container(
                                    width = fixedSize(30),
                                    height = fixedSize(30),
                                    orientation = overlap,
                                    border = border(
                                        cornerRadius = 15,
                                        stroke = stroke(
                                            width = 2.0
                                        ).defer(color = borderRef)
                                    ),
                                    background = solidBackground(
                                        color("#00000000")
                                    ).asList(),
                                    items = listOf(
                                        container(
                                            width = fixedSize(16),
                                            height = fixedSize(16),
                                            border = border(
                                                cornerRadius = 8
                                            ),
                                            background = solidBackground().defer(color = fillRef)
                                                .asList(),
                                            alignmentHorizontal = center,
                                            alignmentVertical = center,
                                        )

                                    )
                                ),
                                container(
                                    orientation = vertical,
                                    width = matchParentSize(),
                                    height = wrapContentSize(),
                                    contentAlignmentVertical = center,
                                    paddings = edgeInsets(left = 16, right = 16),
                                    items = listOf(
                                        text(
                                            width = matchParentSize(),
                                            height = matchParentSize(),
                                            alignmentVertical = center,
                                            fontSize = 17,
                                            fontWeight = bold,
                                            textColor = color("#FFFFFF"),
                                            maxLines = 1
                                        ).defer(text = nameRef),
                                        text(
                                            width = matchParentSize(),
                                            height = matchParentSize(),
                                            alignmentVertical = center,
                                            fontSize = 14,
                                            fontWeight = regular,
                                            textColor = color("#B3FFFFFF"),
                                            margins = edgeInsets(top = 1),
                                            maxLines = 1
                                        ).defer(text = groupRef)
                                    )
                                )
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
                        action(logId = "toggle_plate_click").defer(url = onClickUrlRef),
                        action(logId = "add").defer(url = onClickOuterUrlRef)
                    )
                ).defer(background = bgRef)
            }
        }
    }
}
