package com.gymbro.divkit.workoutListTemplates

import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController


@RestController
@RequestMapping("/divkit/templates") // localhost:8080/divkit/templates
class DivkitTemplatesController {


    @GetMapping(
        value = ["/workout_info"],
        produces = [MediaType.APPLICATION_JSON_VALUE]
    )
    fun getWorkoutInfoTemplates(): ResponseEntity<String> {
        return ResponseEntity.ok(WORKOUT_INFO_TEMPLATES_JSON)
    }
}


private val WORKOUT_INFO_TEMPLATES_JSON: String = """
            {
              "templates": {
                "workout_card": {
                  "log_id": "workout_info_!!workout.id??",
                  "states": [
                    {
                      "state_id": 0,
                      "div": {
                        "type": "container",
                        "orientation": "vertical",
                        "width": { "type": "match_parent" },
                        "height": { "type": "match_parent" },
                        "items": [
                          "!!action_buttons??",
                          "!!workout_header??",
                          "!!exercises_section??",
                          "!!exercises_gallery??",
                          "!!start_button??"
                        ]
                      }
                    }
                  ]
                },
                "action_buttons": {
                  "type": "container",
                  "orientation": "horizontal",
                  "content_alignment_horizontal": "right",
                  "items": [
                    {
                      "type": "container",
                      "orientation": "overlap",
                      "action_animation": {
                        "duration": 120,
                        "end_value": 0.9,
                        "interpolator": "ease_in_out",
                        "name": "scale",
                        "start_value": 1.0
                      },
                      "actions": [
                        {
                          "log_id": "edit",
                          "url": "app://edit?id=!!workout.id??"
                        }
                      ],
                      "border": { "corner_radius": 20 },
                      "height": { "type": "wrap_content" },
                      "items": [
                        {
                          "type": "container",
                          "background": [
                            {
                              "type": "gradient",
                              "angle": 180,
                              "colors": ["#99FFFFFF", "#45FFFFFF", "#00FFFFFF"]
                            }
                          ],
                          "border": { "corner_radius": 20 },
                          "height": { "type": "match_parent" },
                          "paddings": { "bottom": 1, "left": 1, "right": 1, "top": 1 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "background": [
                            {
                              "type": "solid",
                              "color": "#732AFF"
                            }
                          ],
                          "border": { "corner_radius": 19 },
                          "height": { "type": "match_parent" },
                          "margins": { "bottom": 1, "left": 1, "right": 1, "top": 1 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "background": [
                            {
                              "type": "gradient",
                              "angle": -45,
                              "colors": ["#45FFFFFF", "#20FFFFFF", "#00FFFFFF"]
                            }
                          ],
                          "height": { "type": "match_parent" },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "orientation": "horizontal",
                          "alignment_vertical": "center",
                          "background": [
                            {
                              "type": "solid",
                              "color": "#00FFFFFF"
                            }
                          ],
                          "border": { "corner_radius": 20 },
                          "items": [
                            {
                              "type": "image",
                              "image_url": "http://localhost:8080/assets/edit.png",
                              "height": { "type": "fixed", "value": 21 },
                              "width": { "type": "fixed", "value": 21 }
                            }
                          ],
                          "paddings": { "bottom": 8, "left": 8, "right": 8, "top": 8 },
                          "width": { "type": "wrap_content" }
                        }
                      ],
                      "margins": { "bottom": 12, "left": 16, "top": 16 },
                      "width": { "type": "wrap_content" }
                    },
                    {
                      "type": "container",
                      "orientation": "overlap",
                      "action_animation": {
                        "duration": 120,
                        "end_value": 0.9,
                        "interpolator": "ease_in_out",
                        "name": "scale",
                        "start_value": 1.0
                      },
                      "actions": [
                        {
                          "log_id": "delete",
                          "url": "app://delete?id=!!workout.id??"
                        }
                      ],
                      "border": { "corner_radius": 20 },
                      "height": { "type": "wrap_content" },
                      "items": [
                        {
                          "type": "container",
                          "background": [
                            {
                              "type": "gradient",
                              "angle": 180,
                              "colors": ["#99FFFFFF", "#45FFFFFF", "#00FFFFFF"]
                            }
                          ],
                          "border": { "corner_radius": 20 },
                          "height": { "type": "match_parent" },
                          "paddings": { "bottom": 1, "left": 1, "right": 1, "top": 1 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "background": [
                            {
                              "type": "solid",
                              "color": "#732AFF"
                            }
                          ],
                          "border": { "corner_radius": 19 },
                          "height": { "type": "match_parent" },
                          "margins": { "bottom": 1, "left": 1, "right": 1, "top": 1 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "background": [
                            {
                              "type": "gradient",
                              "angle": -45,
                              "colors": ["#45FFFFFF", "#20FFFFFF", "#00FFFFFF"]
                            }
                          ],
                          "height": { "type": "match_parent" },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "orientation": "horizontal",
                          "alignment_vertical": "center",
                          "background": [
                            {
                              "type": "solid",
                              "color": "#00FFFFFF"
                            }
                          ],
                          "border": { "corner_radius": 20 },
                          "items": [
                            {
                              "type": "image",
                              "image_url": "http://localhost:8080/assets/trash.png",
                              "height": { "type": "fixed", "value": 21 },
                              "width": { "type": "fixed", "value": 21 }
                            }
                          ],
                          "paddings": { "bottom": 8, "left": 8, "right": 8, "top": 8 },
                          "width": { "type": "wrap_content" }
                        }
                      ],
                      "margins": { "bottom": 12, "left": 16, "top": 16 },
                      "width": { "type": "wrap_content" }
                    }
                  ],
                  "width": { "type": "match_parent" },
                  "margins": { "bottom": 10, "left": 16, "right": 16, "top": 0 }
                },
                "workout_header": {
                  "type": "container",
                  "orientation": "horizontal",
                  "alignment_vertical": "center",
                  "background": [
                    {
                      "type": "gradient",
                      "angle": 0,
                      "colors": ["!!style.header_gradient_start??", "!!style.header_gradient_end??"]
                    }
                  ],
                  "border": { "corner_radius": 22 },
                  "items": [
                    {
                      "type": "container",
                      "orientation": "vertical",
                      "alignment_vertical": "center",
                      "items": [
                        {
                          "type": "text",
                          "text": "!!workout.name??",
                          "font_size": 21,
                          "font_weight": "bold",
                          "max_lines": 1,
                          "text_color": "#FFFFFF"
                        },
                        {
                          "type": "container",
                          "orientation": "horizontal",
                          "items": [
                            "!!type_tag??",
                            "!!exercises_count_tag??"
                          ],
                          "margins": { "top": 15 },
                          "width": { "type": "wrap_content" }
                        }
                      ],
                      "paddings": { "bottom": 10, "top": 10 },
                      "width": { "type": "match_parent" }
                    }
                  ],
                  "margins": {
                    "bottom": 0,
                    "left": 16,
                    "right": 16,
                    "top": 10
                  },
                  "paddings": {
                    "bottom": 10,
                    "left": 15,
                    "right": 15,
                    "top": 10
                  },
                  "width": { "type": "match_parent" }
                },
                "type_tag": {
                  "type": "container",
                  "orientation": "horizontal",
                  "alignment_vertical": "center",
                  "background": [
                    { "type": "solid", "color": "#701F1F1F" }
                  ],
                  "border": { "corner_radius": 15 },
                  "items": [
                    {
                      "type": "image",
                      "image_url": "!!style.icon_url??",
                      "height": { "type": "fixed", "value": 20 },
                      "width": { "type": "fixed", "value": 20 }
                    },
                    {
                      "type": "text",
                      "text": "!!workout.type_title??",
                      "font_size": 15,
                      "font_weight": "regular",
                      "max_lines": 1,
                      "paddings": { "left": 10 },
                      "text_color": "#FFFFFF"
                    }
                  ],
                  "margins": { "right": 10 },
                  "paddings": { "bottom": 10, "left": 10, "right": 10, "top": 10 },
                  "width": { "type": "wrap_content" }
                },
                "exercises_count_tag": {
                  "type": "container",
                  "orientation": "horizontal",
                  "alignment_vertical": "center",
                  "background": [
                    { "type": "solid", "color": "#701F1F1F" }
                  ],
                  "border": { "corner_radius": 15 },
                  "items": [
                    {
                      "type": "image",
                      "image_url": "http://localhost:8080/assets/dumbell.png",
                      "height": { "type": "fixed", "value": 20 },
                      "width": { "type": "fixed", "value": 20 }
                    },
                    {
                      "type": "text",
                      "text": "!!workout.exercises_count?? exercises",
                      "font_size": 15,
                      "font_weight": "regular",
                      "max_lines": 1,
                      "paddings": { "left": 10 },
                      "text_color": "#FFFFFF"
                    }
                  ],
                  "paddings": { "bottom": 10, "left": 10, "right": 10, "top": 10 },
                  "width": { "type": "wrap_content" }
                },
                "exercises_section": {
                  "type": "text",
                  "text": "EXERCISES",
                  "font_size": 16,
                  "font_weight": "bold",
                  "margins": { "bottom": 17, "left": 25, "top": 17 },
                  "max_lines": 1,
                  "text_color": "#4A4A4A"
                },
                "exercises_gallery": {
                  "type": "gallery",
                  "column_count": 1,
                  "height": { "type": "match_parent" },
                  "orientation": "vertical",
                  "items": "!!exercise_cards_array??"
                },
                "exercise_card_strength": {
                  "type": "container",
                  "orientation": "vertical",
                  "alignment_vertical": "center",
                  "background": [
                    {
                      "type": "gradient",
                      "angle": 0,
                      "colors": ["#1D1D34", "!!style.exercise_gradient_color??"]
                    }
                  ],
                  "border": { "corner_radius": 22 },
                  "items": [
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_vertical": "center",
                      "items": [
                        "!!exercise_number??",
                        "!!exercise_name_and_muscle??"
                      ],
                      "paddings": { "bottom": 10, "top": 10 },
                      "width": { "type": "match_parent" }
                    },
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_vertical": "center",
                      "content_alignment_horizontal": "center",
                      "items": [
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Sets",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.sets??",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Reps",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.reps??",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Weight",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.weight?? Kg",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        }
                      ],
                      "margins": { "left": 35 },
                      "paddings": { "bottom": 10, "top": 5 },
                      "width": { "type": "match_parent" }
                    }
                  ],
                  "margins": { "bottom": 5, "left": 16, "right": 16 },
                  "paddings": { "bottom": 10, "left": 15, "right": 15, "top": 10 },
                  "width": { "type": "match_parent" }
                },
                "exercise_card_cardio": {
                  "type": "container",
                  "orientation": "vertical",
                  "alignment_vertical": "center",
                  "background": [
                    {
                      "type": "gradient",
                      "angle": 0,
                      "colors": ["#1D1D34", "!!style.exercise_gradient_color??"]
                    }
                  ],
                  "border": { "corner_radius": 22 },
                  "items": [
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_vertical": "center",
                      "items": [
                        "!!exercise_number??",
                        "!!exercise_name_and_muscle??"
                      ],
                      "paddings": { "bottom": 10, "top": 10 },
                      "width": { "type": "match_parent" }
                    },
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_vertical": "center",
                      "content_alignment_horizontal": "center",
                      "items": [
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Duration",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.duration?? min",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Pace",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.pace??",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        }
                      ],
                      "margins": { "left": 35 },
                      "paddings": { "bottom": 10, "top": 5 },
                      "width": { "type": "match_parent" }
                    }
                  ],
                  "margins": { "bottom": 5, "left": 16, "right": 16 },
                  "paddings": { "bottom": 10, "left": 15, "right": 15, "top": 10 },
                  "width": { "type": "match_parent" }
                },
                "exercise_card_yoga": {
                  "type": "container",
                  "orientation": "vertical",
                  "alignment_vertical": "center",
                  "background": [
                    {
                      "type": "gradient",
                      "angle": 0,
                      "colors": ["#1D1D34", "!!style.exercise_gradient_color??"]
                    }
                  ],
                  "border": { "corner_radius": 22 },
                  "items": [
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_vertical": "center",
                      "items": [
                        "!!exercise_number??",
                        "!!exercise_name_and_muscle??"
                      ],
                      "paddings": { "bottom": 10, "top": 10 },
                      "width": { "type": "match_parent" }
                    },
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_vertical": "center",
                      "content_alignment_horizontal": "center",
                      "items": [
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Hold for",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.hold_seconds?? sec",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "background": [{ "type": "solid", "color": "#501F1F1F" }],
                          "border": { "corner_radius": 10 },
                          "items": [
                            {
                              "type": "text",
                              "text": "Breath Count",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 10, "top": 5 },
                              "max_lines": 1,
                              "text_color": "#55FFFFFF",
                              "width": { "type": "wrap_content" }
                            },
                            {
                              "type": "text",
                              "text": "!!exercise.breath_count??/min",
                              "alignment_horizontal": "center",
                              "alignment_vertical": "center",
                              "font_size": 15,
                              "font_weight": "bold",
                              "margins": { "bottom": 5 },
                              "max_lines": 1,
                              "text_color": "#FFFFFF",
                              "width": { "type": "wrap_content" }
                            }
                          ],
                          "margins": { "right": 10 },
                          "paddings": { "bottom": 5, "left": 20, "right": 20, "top": 5 },
                          "width": { "type": "match_parent" }
                        }
                      ],
                      "margins": { "left": 35 },
                      "paddings": { "bottom": 10, "top": 5 },
                      "width": { "type": "match_parent" }
                    }
                  ],
                  "margins": { "bottom": 5, "left": 16, "right": 16 },
                  "paddings": { "bottom": 10, "left": 15, "right": 15, "top": 10 },
                  "width": { "type": "match_parent" }
                },
                "exercise_number": {
                  "type": "container",
                  "orientation": "horizontal",
                  "alignment_horizontal": "center",
                  "alignment_vertical": "center",
                  "background": [{ "type": "solid", "color": "#501F1F1F" }],
                  "border": { "corner_radius": 10 },
                  "items": [
                    {
                      "type": "text",
                      "text": "!!exercise.number??",
                      "alignment_horizontal": "center",
                      "alignment_vertical": "center",
                      "font_size": 15,
                      "font_weight": "bold",
                      "max_lines": 1,
                      "text_color": "#FFFFFF"
                    }
                  ],
                  "margins": { "right": "!!exercise.number_margin??" },
                  "paddings": { "bottom": 10, "left": 10, "right": 10, "top": 10 },
                  "width": { "type": "wrap_content" }
                },
                "exercise_name_and_muscle": {
                  "type": "container",
                  "orientation": "horizontal",
                  "alignment_vertical": "center",
                  "items": [
                    {
                      "type": "text",
                      "text": "!!exercise.name??",
                      "alignment_horizontal": "center",
                      "alignment_vertical": "center",
                      "font_size": 18,
                      "font_weight": "bold",
                      "max_lines": 1,
                      "text_color": "#FFFFFF"
                    },
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_horizontal": "center",
                      "alignment_vertical": "center",
                      "background": [{ "type": "solid", "color": "#501F1F1F" }],
                      "border": { "corner_radius": 15 },
                      "items": [
                        {
                          "type": "text",
                          "text": "!!exercise.muscle_group??",
                          "alignment_horizontal": "center",
                          "alignment_vertical": "center",
                          "font_size": 15,
                          "font_weight": "regular",
                          "max_lines": 1,
                          "text_color": "#FFFFFF"
                        }
                      ],
                      "margins": { "left": 10 },
                      "paddings": { "bottom": 10, "left": 10, "right": 10, "top": 10 },
                      "width": { "type": "wrap_content" }
                    }
                  ],
                  "width": { "type": "wrap_content" }
                },
                "start_button": {
                  "type": "container",
                  "orientation": "overlap",
                  "action_animation": {
                    "duration": 120,
                    "end_value": 0.9,
                    "interpolator": "ease_in_out",
                    "name": "scale",
                    "start_value": 1.0
                  },
                  "actions": [
                    {
                      "log_id": "open_player",
                      "url": "app://open_player?id=!!workout.id??"
                    }
                  ],
                  "border": { "corner_radius": 28 },
                  "height": { "type": "wrap_content" },
                  "items": [
                    {
                      "type": "container",
                      "background": [
                        {
                          "type": "gradient",
                          "angle": 180,
                          "colors": ["#99FFFFFF", "#45FFFFFF", "#00FFFFFF"]
                        }
                      ],
                      "border": { "corner_radius": 28 },
                      "height": { "type": "match_parent" },
                      "paddings": { "bottom": 1, "left": 1, "right": 1, "top": 1 },
                      "width": { "type": "match_parent" }
                    },
                    {
                      "type": "container",
                      "background": [
                        {
                          "type": "solid",
                          "color": "#732AFF"
                        }
                      ],
                      "border": { "corner_radius": 26 },
                      "height": { "type": "match_parent" },
                      "margins": { "bottom": 2, "left": 2, "right": 2, "top": 2 },
                      "width": { "type": "match_parent" }
                    },
                    {
                      "type": "container",
                      "background": [
                        {
                          "type": "gradient",
                          "angle": -45,
                          "colors": ["#45FFFFFF", "#20FFFFFF", "#00FFFFFF"]
                        }
                      ],
                      "height": { "type": "match_parent" },
                      "width": { "type": "match_parent" }
                    },
                    {
                      "type": "container",
                      "orientation": "horizontal",
                      "alignment_horizontal": "center",
                      "alignment_vertical": "center",
                      "background": [
                        {
                          "type": "solid",
                          "color": "#00FFFFFF"
                        }
                      ],
                      "border": { "corner_radius": 28 },
                      "items": [
                        {
                          "type": "text",
                          "text": "Start Workout",
                          "alignment_vertical": "center",
                          "font_size": 20,
                          "font_weight": "medium",
                          "text_color": "#FFFFFF"
                        }
                      ],
                      "paddings": { "bottom": 18, "left": 18, "right": 18, "top": 18 },
                      "width": { "type": "wrap_content" }
                    }
                  ],
                  "margins": { "bottom": 12, "left": 16, "right": 16, "top": 16 },
                  "width": { "type": "match_parent" }
                },
                
                "workout_builder_gallery": {
                  "type": "gallery",
                  "column_count": 1,
                  "height": { "type": "match_parent" },
                  "orientation": "vertical",
                  "items": "!!exercise_cards_array??",
                  "paddings": {
                    "top": 140,
                    "bottom": 90
                  },
                  "width": { "type": "match_parent" }
                },
                "workout_builder_header": {
                     "type": "container",
                     "orientation": "horizontal",
                     "alignment_vertical": "top",
                     "background": [
                       {
                         "type": "gradient",
                         "angle": 135,
                         "colors": ["!!style.builder_header_start??", "!!style.builder_header_end??"]
                       }
                     ],
                     "border": { "corner_radius": 22 },
                     "items": [
                       {
                         "type": "container",
                         "orientation": "vertical",
                         "alignment_vertical": "center",
                         "items": [
                           {
                             "type": "text",
                             "text": "!!workout.name??",
                             "font_size": 21,
                             "font_weight": "bold",
                             "max_lines": 1,
                             "text_color": "#FFFFFF"
                           },
                           {
                             "type": "container",
                             "orientation": "horizontal",
                             "items": [
                               "!!builder_type_tag??",
                               "!!builder_exercises_count_tag??"
                             ],
                             "margins": { "top": 15 },
                             "width": { "type": "wrap_content" }
                           }
                         ],
                         "paddings": { "bottom": 10, "top": 10 },
                         "width": { "type": "match_parent" }
                       }
                     ],
                     "paddings": {
                       "bottom": 10,
                       "left": 15,
                       "right": 15,
                       "top": 10
                     },
                     "width": { "type": "match_parent" }
                   },
                   "builder_type_tag": {
                        "type": "container",
                        "orientation": "horizontal",
                        "alignment_vertical": "center",
                        "background": [
                          { "type": "solid", "color": "#701F1F1F" }
                        ],
                        "border": { "corner_radius": 15 },
                        "items": [
                          {
                            "type": "image",
                            "image_url": "!!style.icon_url??",
                            "height": { "type": "fixed", "value": 20 },
                            "width": { "type": "fixed", "value": 20 }
                          },
                          {
                            "type": "text",
                            "text": "!!workout.type_title??",
                            "font_size": 15,
                            "font_weight": "regular",
                            "max_lines": 1,
                            "paddings": { "left": 10 },
                            "text_color": "#FFFFFF"
                          }
                        ],
                        "margins": { "right": 10 },
                        "paddings": { "bottom": 10, "left": 10, "right": 10, "top": 10 },
                        "width": { "type": "wrap_content" }
                      },
                     
                      "builder_exercises_count_tag": {
                        "type": "container",
                        "orientation": "horizontal",
                        "alignment_vertical": "center",
                        "background": [
                          { "type": "solid", "color": "#701F1F1F" }
                        ],
                        "border": { "corner_radius": 15 },
                        "items": [
                          {
                            "type": "image",
                            "image_url": "http://localhost:8080/assets/dumbell.png",
                            "height": { "type": "fixed", "value": 20 },
                            "width": { "type": "fixed", "value": 20 }
                          },
                          {
                            "type": "text",
                            "text": "!!workout.exercises_count?? exercises",
                            "font_size": 15,
                            "font_weight": "regular",
                            "max_lines": 1,
                            "paddings": { "left": 10 },
                            "text_color": "#FFFFFF"
                          }
                        ],
                        "paddings": { "bottom": 10, "left": 10, "right": 10, "top": 10 },
                        "width": { "type": "wrap_content" }
                      },
                      "workout_builder_button": {
                           "type": "container",
                           "orientation": "overlap",
                           "action_animation": {
                             "duration": 120,
                             "end_value": 0.9,
                             "interpolator": "ease_in_out",
                             "name": "scale",
                             "start_value": 1.0
                           },
                           "actions": [
                             {
                               "log_id": "save_workout",
                               "url": "app://save_workout?id=!!workout.id??"
                             }
                           ],
                           "border": { "corner_radius": 28 },
                           "height": { "type": "wrap_content" },
                           "items": [
                             {
                               "type": "container",
                               "background": [
                                 {
                                   "type": "gradient",
                                   "angle": 180,
                                   "colors": ["#70FFFFFF", "#45FFFFFF", "#00FFFFFF"]
                                 }
                               ],
                               "border": { "corner_radius": 28 },
                               "height": { "type": "match_parent" },
                               "paddings": { "bottom": 1, "left": 1, "right": 1, "top": 1 },
                               "width": { "type": "match_parent" }
                             },
                             {
                               "type": "container",
                               "background": [
                                 {
                                   "type": "solid",
                                   "color": "#732AFF"
                                 }
                               ],
                               "border": { "corner_radius": 26 },
                               "height": { "type": "match_parent" },
                               "margins": { "bottom": 2, "left": 2, "right": 2, "top": 2 },
                               "width": { "type": "match_parent" }
                             },
                             {
                               "type": "container",
                               "background": [
                                 {
                                   "type": "gradient",
                                   "angle": -45,
                                   "colors": ["#45FFFFFF", "#20FFFFFF", "#00FFFFFF"]
                                 }
                               ],
                               "height": { "type": "match_parent" },
                               "width": { "type": "match_parent" }
                             },
                             {
                               "type": "container",
                               "orientation": "horizontal",
                               "alignment_horizontal": "center",
                               "alignment_vertical": "center",
                               "background": [
                                 {
                                   "type": "solid",
                                   "color": "#00FFFFFF"
                                 }
                               ],
                               "border": { "corner_radius": 28 },
                               "items": [
                                 {
                                   "type": "text",
                                   "text": "Add to my workouts",
                                   "alignment_vertical": "center",
                                   "font_size": 18,
                                   "font_weight": "bold",
                                   "text_color": "#FFFFFF"
                                 }
                               ],
                               "paddings": { "bottom": 18, "left": 18, "right": 18, "top": 18 },
                               "width": { "type": "wrap_content" }
                             }
                           ],
                           "margins": { "bottom": 25, "left": 16, "right": 16, "top": 16 },
                           "width": { "type": "match_parent" }
                         },
                         "workout_builder_sheet": {
                              "log_id": "workoutBuilderSheet",
                              "states": [
                                {
                                  "state_id": 0,
                                  "div": {
                                    "type": "container",
                                    "orientation": "overlap",
                                    "height": { "type": "match_parent" },
                                    "width": { "type": "match_parent" },
                                    "items": [
                                      {
                                        "type": "container",
                                        "orientation": "vertical",
                                        "alignment_vertical": "center",
                                        "height": { "type": "match_parent" },
                                        "width": { "type": "match_parent" },
                                        "items": [
                                          "!!workout_builder_gallery??"
                                        ]
                                      },
                                      "!!workout_builder_header??",
                                      {
                                        "type": "container",
                                        "orientation": "vertical",
                                        "alignment_vertical": "bottom",
                                        "content_alignment_vertical": "bottom",
                                        "height": { "type": "match_parent" },
                                        "width": { "type": "match_parent" },
                                        "items": [
                                          "!!workout_builder_button??"
                                        ]
                                      }
                                    ]
                                  }
                                }
                              ]
                            },
                            "workouts_list_card" : {
                                "icon_url": "!!icon_url??",
                                "visibility": "@{contains(trim(toLowerCase('!!workout_name??')), trim(toLowerCase(search_text))) ? 'visible' : 'gone'}",
                                "background": [
                                {
                                    "type": "gradient",
                                    "angle": 0,
                                    "colors": [
                                        "#1D1D34",
                                        "!!workout_color??"
                                    ]
                                }
                                ],
                                "subtitle": "!!workout_type??",
                                "open_url": "app://open_workout?id=!!workout_id??",
                                "type": "workout_card",
                                "title": "!!workout_name??"
                                },
                            
              }
            }
        """.trimIndent()

