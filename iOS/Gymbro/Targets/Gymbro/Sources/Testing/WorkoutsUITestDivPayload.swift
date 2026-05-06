import Foundation

enum WorkoutsUITestDivPayload {

    static func workoutsList() -> Data {
        Data(
            """
            {
              "templates": {},
              "card": {
                "log_id": "uitest_workouts_list",
                "states": [
                  {
                    "state_id": 0,
                    "div": {
                      "type": "container",
                      "orientation": "vertical",
                      "width": { "type": "match_parent" },
                      "height": { "type": "wrap_content" },
                      "items": [
                        {
                          "type": "text",
                          "text": "UITest Workouts",
                          "font_size": 26,
                          "font_weight": "bold",
                          "text_color": "#FFFFFFFF",
                          "margins": { "left": 16, "top": 20, "right": 16, "bottom": 12 }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "width": { "type": "match_parent" },
                          "margins": { "left": 16, "right": 16, "bottom": 12 },
                          "paddings": { "left": 16, "top": 16, "right": 16, "bottom": 16 },
                          "border": { "corner_radius": 18 },
                          "background": [{ "type": "solid", "color": "#FF732AFF" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "UITest workout • tap for workout info",
                              "font_size": 17,
                              "font_weight": "medium",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            {
                              "log_id": "uitest_open_workout",
                              "url": "app://open_workout?id=\(WorkoutsUITestConstants.primaryWorkoutId)"
                            }
                          ]
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "width": { "type": "match_parent" },
                          "margins": { "left": 16, "right": 16, "bottom": 10 },
                          "paddings": { "left": 14, "top": 14, "right": 14, "bottom": 14 },
                          "border": { "corner_radius": 16 },
                          "background": [{ "type": "solid", "color": "#33272743" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "UITest • Open workout builder",
                              "font_size": 16,
                              "font_weight": "medium",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            { "log_id": "uitest_open_builder", "url": "app://open_builder" }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            }
            """.utf8
        )
    }

    static func workoutInfo(workoutId: String) -> Data {
        Data(
            """
            {
              "templates": {},
              "card": {
                "log_id": "uitest_workout_info",
                "states": [
                  {
                    "state_id": 0,
                    "div": {
                      "type": "container",
                      "orientation": "vertical",
                      "width": { "type": "match_parent" },
                      "height": { "type": "wrap_content" },
                      "items": [
                        {
                          "type": "text",
                          "text": "UITest workout detail",
                          "font_size": 22,
                          "font_weight": "bold",
                          "text_color": "#FFFFFFFF",
                          "margins": { "left": 16, "top": 56, "right": 16, "bottom": 16 }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "width": { "type": "match_parent" },
                          "margins": { "left": 16, "right": 16, "bottom": 24 },
                          "paddings": { "top": 18, "bottom": 18, "left": 16, "right": 16 },
                          "border": { "corner_radius": 22 },
                          "background": [{ "type": "solid", "color": "#FF732AFF" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "▶ Start workout (UITest)",
                              "font_size": 18,
                              "font_weight": "bold",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            {
                              "log_id": "uitest_open_player",
                              "url": "app://open_player?id=\(workoutId)&"
                            }
                          ]
                        },
                        {
                          "type": "text",
                          "text": "Swipe • Scroll placeholder",
                          "font_size": 14,
                          "text_color": "#88FFFFFF",
                          "margins": { "left": 16, "right": 16 }
                        }
                      ]
                    }
                  }
                ]
              }
            }
            """.utf8
        )
    }

    static func workoutBuilderTitle() -> Data {
        Data(
            """
            {
              "templates": {},
              "card": {
                "log_id": "uitest_workout_builder_title",
                "states": [
                  {
                    "state_id": 0,
                    "div": {
                      "type": "container",
                      "orientation": "vertical",
                      "width": { "type": "match_parent" },
                      "items": [
                        {
                          "type": "text",
                          "text": "UITest Builder",
                          "font_size": 26,
                          "font_weight": "bold",
                          "text_color": "#FFFFFFFF",
                          "margins": { "left": 16, "top": 40, "bottom": 16 }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "margins": { "left": 16, "right": 16, "bottom": 12 },
                          "paddings": { "top": 16, "bottom": 16, "left": 16, "right": 16 },
                          "border": { "corner_radius": 16 },
                          "background": [{ "type": "solid", "color": "#553732FF" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "UITest • Open AI workout generator",
                              "font_size": 16,
                              "font_weight": "medium",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            { "log_id": "uitest_open_ai", "url": "app://open_ai" }
                          ]
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "margins": { "left": 16, "right": 16 },
                          "paddings": { "top": 16, "bottom": 16, "left": 16, "right": 16 },
                          "border": { "corner_radius": 16 },
                          "background": [{ "type": "solid", "color": "#33272743" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "UITest • New strength workout",
                              "font_size": 16,
                              "font_weight": "medium",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            {
                              "log_id": "uitest_open_builder_type",
                              "url": "app://open_builder_for_type?type=strength&"
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            }
            """.utf8
        )
    }

    static func workoutBuilderForType() -> Data {
        Data(
            """
            {
              "templates": {},
              "card": {
                "log_id": "uitest_builder_for_type",
                "states": [
                  {
                    "state_id": 0,
                    "div": {
                      "type": "container",
                      "orientation": "vertical",
                      "width": { "type": "match_parent" },
                      "items": [
                        {
                          "type": "text",
                          "text": "UITest • Tap row to add exercise",
                          "font_size": 15,
                          "font_weight": "medium",
                          "text_color": "#AAAAAAFF",
                          "margins": { "left": 16, "top": 8, "bottom": 10 }
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "margins": { "left": 16, "right": 16, "bottom": 10 },
                          "paddings": { "top": 14, "bottom": 14, "left": 14, "right": 14 },
                          "border": { "corner_radius": 14 },
                          "background": [{ "type": "solid", "color": "#FF2E27FF" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "UITest Squat — add",
                              "font_size": 16,
                              "font_weight": "medium",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            {
                              "log_id": "uitest_add_exercise",
                              "url": "app://add?id=\(WorkoutsUITestConstants.catalogExerciseExtraId)"
                            }
                          ]
                        },
                        {
                          "type": "container",
                          "orientation": "vertical",
                          "margins": { "left": 16, "right": 16 },
                          "paddings": { "top": 14, "bottom": 14, "left": 14, "right": 14 },
                          "border": { "corner_radius": 14 },
                          "background": [{ "type": "solid", "color": "#FF732AFF" }],
                          "items": [
                            {
                              "type": "text",
                              "text": "UITest Pull-Up — add",
                              "font_size": 16,
                              "font_weight": "medium",
                              "text_color": "#FFFFFFFF"
                            }
                          ],
                          "actions": [
                            {
                              "log_id": "uitest_add_exercise_2",
                              "url": "app://add?id=\(WorkoutsUITestConstants.catalogExerciseAltId)"
                            }
                          ]
                        }
                      ]
                    }
                  }
                ]
              }
            }
            """.utf8
        )
    }

    static func workoutInfoTemplates() -> Data {
        Data(#"{"templates":{}}"#.utf8)
    }

    static func workoutBuilderSheetStub() -> Data {
        Data(
            """
            {
              "templates": {},
              "card": {
                "log_id": "uitest_builder_sheet_stub",
                "states": [
                  {
                    "state_id": 0,
                    "div": {
                      "type": "text",
                      "text": "UITest premade sheet stub",
                      "font_size": 16,
                      "text_color": "#FFFFFFFF",
                      "margins": { "top": 24, "left": 16 }
                    }
                  }
                ]
              }
            }
            """.utf8
        )
    }
}

enum WorkoutsUITestConstants {
    static let primaryWorkoutId = "uitest_workout_primary"
    static let catalogExerciseExtraId = "uitest_catalog_squat"
    static let catalogExerciseAltId = "uitest_catalog_pullup"
    static let generatedWorkoutId = "uitest_workout_generated"
}
