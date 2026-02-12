import Foundation
import GymbroTypes

struct WorkoutInfoLocalMapper {

    func render(id: String) -> Data? {
        guard let workout = workoutsMock.first(where: { $0.id == id }) else { return nil }

        let card = buildWorkoutCard(workout)

        let divKitJson: [String: Any] = [
            "card": card,
            "templates": [:],
            "variables": []
        ]

        return try? JSONSerialization.data(withJSONObject: divKitJson, options: [.prettyPrinted])
    }
    
    // Private types

    private func buildWorkoutCard(_ workout: Workout) -> [String: Any] {
        let style = workout.type.style

        return [
            "log_id": "workout_info_\(workout.id)",
            "states": [
                buildMainState(workout: workout, style: style)
            ]
        ]
    }

    private func buildMainState(workout: Workout, style: WorkoutStyle) -> [String: Any] {
        [
            "state_id": 0,
            "div": [
                "type": "container",
                "orientation": "vertical",
                "width": ["type": "match_parent"],
                "height": ["type": "match_parent"],
                "items": [
                    buildHeaderBlock(workout: workout, style: style),

                    buildExercisesSectionDiv(),

                    buildExercisesGalleryDiv(workout: workout, style: style),

                    buildStartButtonDiv(workoutId: workout.id)
                ]
            ]
        ]
    }

    private func buildHeaderBlock(workout: Workout, style: WorkoutStyle) -> [String: Any] {
        [
            "type": "container",
            "orientation": "vertical",
            "height": ["type": "wrap_content"],
            "width": ["type": "match_parent"],
            "items": [
                buildActionButtons(workoutId: workout.id),
                buildWorkoutHeader(workout: workout, style: style)
            ]
        ]
    }

    private func buildActionButtons(workoutId: String) -> [String: Any] {
        [
            "type": "container",
            "orientation": "horizontal",
            "content_alignment_horizontal": "right",
            "items": [
                buildActionButton(
                    logId: "edit",
                    url: "app://edit?id=\(workoutId)",
                    iconUrl: "http://localhost:8080/assets/edit.png",
                    margins: ["bottom": 12, "left": 16, "top": 16]
                ),
                buildActionButton(
                    logId: "delete",
                    url: "app://delete?id=\(workoutId)",
                    iconUrl: "http://localhost:8080/assets/trash.png",
                    margins: ["bottom": 12, "left": 16, "top": 16]
                )
            ],
            "width": ["type": "match_parent"]
        ]
    }

    private func buildActionButton(
        logId: String,
        url: String,
        iconUrl: String,
        margins: [String: Any]
    ) -> [String: Any] {
        [
            "type": "container",
            "orientation": "overlap",
            "action_animation": [
                "duration": 120,
                "end_value": 0.9,
                "interpolator": "ease_in_out",
                "name": "scale",
                "start_value": 1.0
            ],
            "actions": [
                [
                    "log_id": logId,
                    "url": url
                ]
            ],
            "border": ["corner_radius": 20],
            "height": ["type": "wrap_content"],
            "items": [
                [
                    "type": "container",
                    "background": [
                        [
                            "type": "gradient",
                            "angle": 180,
                            "colors": ["#99FFFFFF", "#45FFFFFF", "#00FFFFFF"]
                        ]
                    ],
                    "border": ["corner_radius": 20],
                    "height": ["type": "match_parent"],
                    "paddings": ["bottom": 1, "left": 1, "right": 1, "top": 1],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "background": [
                        [
                            "type": "solid",
                            "color": "#732AFF"
                        ]
                    ],
                    "border": ["corner_radius": 19],
                    "height": ["type": "match_parent"],
                    "margins": ["bottom": 1, "left": 1, "right": 1, "top": 1],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "background": [
                        [
                            "type": "gradient",
                            "angle": -45,
                            "colors": ["#45FFFFFF", "#20FFFFFF", "#00FFFFFF"]
                        ]
                    ],
                    "height": ["type": "match_parent"],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "background": [
                        [
                            "type": "solid",
                            "color": "#00FFFFFF"
                        ]
                    ],
                    "border": ["corner_radius": 20],
                    "items": [
                        [
                            "type": "image",
                            "image_url": iconUrl,
                            "height": ["type": "fixed", "value": 21],
                            "width": ["type": "fixed", "value": 21]
                        ]
                    ],
                    "paddings": ["bottom": 8, "left": 8, "right": 8, "top": 8],
                    "width": ["type": "wrap_content"]
                ]
            ],
            "margins": margins,
            "width": ["type": "wrap_content"]
        ]
    }

    private func buildWorkoutHeader(workout: Workout, style: WorkoutStyle) -> [String: Any] {
        [
            "type": "container",
            "orientation": "horizontal",
            "alignment_vertical": "center",
            "background": [
                [
                    "type": "gradient",
                    "angle": 0,
                    "colors": [style.headerGradientStart, style.headerGradientEnd]
                ]
            ],
            "border": ["corner_radius": 22],
            "items": [
                [
                    "type": "container",
                    "orientation": "vertical",
                    "alignment_vertical": "center",
                    "items": [
                        [
                            "type": "text",
                            "text": workout.name,
                            "font_size": 21,
                            "font_weight": "bold",
                            "max_lines": 1,
                            "text_color": "#FFFFFF"
                        ],
                        [
                            "type": "container",
                            "orientation": "horizontal",
                            "items": [
                                buildTypeTag(iconUrl: style.iconUrl, text: workout.type.title),
                                buildExercisesCountTag(count: workout.exercises.count)
                            ],
                            "margins": ["top": 15],
                            "width": ["type": "wrap_content"]
                        ]
                    ],
                    "paddings": ["bottom": 10, "top": 10],
                    "width": ["type": "match_parent"]
                ]
            ],
            "margins": [
                "bottom": 0,
                "left": 16,
                "right": 16,
                "top": 10
            ],
            "paddings": [
                "bottom": 10,
                "left": 15,
                "right": 15,
                "top": 10
            ],
            "width": ["type": "match_parent"]
        ]
    }

    private func buildTypeTag(iconUrl: String, text: String) -> [String: Any] {
        [
            "type": "container",
            "orientation": "horizontal",
            "alignment_vertical": "center",
            "background": [
                ["type": "solid", "color": "#701F1F1F"]
            ],
            "border": ["corner_radius": 15],
            "items": [
                [
                    "type": "image",
                    "image_url": iconUrl,
                    "height": ["type": "fixed", "value": 20],
                    "width": ["type": "fixed", "value": 20]
                ],
                [
                    "type": "text",
                    "text": text,
                    "font_size": 15,
                    "font_weight": "regular",
                    "max_lines": 1,
                    "paddings": ["left": 10],
                    "text_color": "#FFFFFF"
                ]
            ],
            "margins": ["right": 10],
            "paddings": ["bottom": 10, "left": 10, "right": 10, "top": 10],
            "width": ["type": "wrap_content"]
        ]
    }

    private func buildExercisesCountTag(count: Int) -> [String: Any] {
        [
            "type": "container",
            "orientation": "horizontal",
            "alignment_vertical": "center",
            "background": [
                ["type": "solid", "color": "#701F1F1F"]
            ],
            "border": ["corner_radius": 15],
            "items": [
                [
                    "type": "image",
                    "image_url": "http://localhost:8080/assets/dumbell.png",
                    "height": ["type": "fixed", "value": 20],
                    "width": ["type": "fixed", "value": 20]
                ],
                [
                    "type": "text",
                    "text": "\(count) exercises",
                    "font_size": 15,
                    "font_weight": "regular",
                    "max_lines": 1,
                    "paddings": ["left": 10],
                    "text_color": "#FFFFFF"
                ]
            ],
            "paddings": ["bottom": 10, "left": 10, "right": 10, "top": 10],
            "width": ["type": "wrap_content"]
        ]
    }

    private func buildExercisesSectionDiv() -> [String: Any] {
        [
            "type": "text",
            "text": "EXERCISES",
            "font_size": 16,
            "font_weight": "bold",
            "margins": ["bottom": 17, "left": 25, "top": 17],
            "max_lines": 1,
            "text_color": "#4A4A4A"
        ]
    }

    private func buildExercisesGalleryDiv(workout: Workout, style: WorkoutStyle) -> [String: Any] {
        [
            "type": "gallery",
            "column_count": 1,
            "height": ["type": "match_parent"],
            "orientation": "vertical",
            "items": workout.exercises.enumerated().map { index, exercise in
                buildExerciseCard(
                    exercise: exercise,
                    number: index + 1,
                    gradientColor: style.exerciseGradientColor
                )
            }
        ]
    }

    private func buildExerciseCard(exercise: Exercise, number: Int, gradientColor: String) -> [String: Any] {
        switch exercise {
        case let strength as StrengthExercise:
            return buildStrengthExerciseCard(exercise: strength, number: number, gradientColor: gradientColor)
        case let cardio as CardioExercise:
            return buildCardioExerciseCard(exercise: cardio, number: number, gradientColor: gradientColor)
        case let yoga as YogaExercise:
            return buildYogaExerciseCard(exercise: yoga, number: number, gradientColor: gradientColor)
        default:
            assertionFailure("Unhandled exercise type: \(type(of: exercise))")
            return [:]
        }
    }

    private func buildStrengthExerciseCard(
        exercise: StrengthExercise,
        number: Int,
        gradientColor: String
    ) -> [String: Any] {
        [
            "type": "container",
            "orientation": "vertical",
            "alignment_vertical": "center",
            "background": [["type": "gradient", "angle": 0, "colors": ["#1D1D34", gradientColor]]],
            "border": ["corner_radius": 22],
            "items": [
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "items": [
                        buildExerciseNumber(number: number, marginRight: 30),
                        buildExerciseNameAndMuscle(name: exercise.name, muscleGroup: exercise.muscleGroup.title)
                    ],
                    "paddings": ["bottom": 10, "top": 10],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "content_alignment_horizontal": "center",
                    "items": [
                        buildMetricCard(title: "Sets", value: "\(exercise.sets)"),
                        buildMetricCard(title: "Reps", value: "\(exercise.reps)"),
                        buildMetricCard(title: "Weight", value: "\(String(format: "%.1f", exercise.weightKg)) Kg")
                    ],
                    "margins": ["left": 35],
                    "paddings": ["bottom": 10, "top": 5],
                    "width": ["type": "match_parent"]
                ]
            ],
            "margins": ["bottom": 5, "left": 16, "right": 16],
            "paddings": ["bottom": 10, "left": 15, "right": 15, "top": 10],
            "width": ["type": "match_parent"]
        ]
    }

    private func buildCardioExerciseCard(
        exercise: CardioExercise,
        number: Int,
        gradientColor: String
    ) -> [String: Any] {
        [
            "type": "container",
            "orientation": "vertical",
            "alignment_vertical": "center",
            "background": [["type": "gradient", "angle": 0, "colors": ["#1D1D34", gradientColor]]],
            "border": ["corner_radius": 22],
            "items": [
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "items": [
                        buildExerciseNumber(number: number, marginRight: 20),
                        buildExerciseNameAndMuscle(name: exercise.name, muscleGroup: exercise.muscleGroup.title)
                    ],
                    "paddings": ["bottom": 10, "top": 10],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "content_alignment_horizontal": "center",
                    "items": [
                        buildMetricCard(title: "Duration", value: "\(exercise.durationMinutes) min"),
                        buildMetricCard(title: "Pace", value: exercise.pace.title)
                    ],
                    "margins": ["left": 35],
                    "paddings": ["bottom": 10, "top": 5],
                    "width": ["type": "match_parent"]
                ]
            ],
            "margins": ["bottom": 5, "left": 16, "right": 16],
            "paddings": ["bottom": 10, "left": 15, "right": 15, "top": 10],
            "width": ["type": "match_parent"]
        ]
    }

    private func buildYogaExerciseCard(
        exercise: YogaExercise,
        number: Int,
        gradientColor: String
    ) -> [String: Any] {
        [
            "type": "container",
            "orientation": "vertical",
            "alignment_vertical": "center",
            "background": [["type": "gradient", "angle": 0, "colors": ["#1D1D34", gradientColor]]],
            "border": ["corner_radius": 22],
            "items": [
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "items": [
                        buildExerciseNumber(number: number, marginRight: 20),
                        buildExerciseNameAndMuscle(name: exercise.name, muscleGroup: exercise.muscleGroup.title)
                    ],
                    "paddings": ["bottom": 10, "top": 10],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_vertical": "center",
                    "content_alignment_horizontal": "center",
                    "items": [
                        buildMetricCard(title: "Hold for", value: "\(exercise.holdSeconds) sec"),
                        buildMetricCard(title: "Breath Count", value: "\(exercise.breathCount)/min")
                    ],
                    "margins": ["left": 35],
                    "paddings": ["bottom": 10, "top": 5],
                    "width": ["type": "match_parent"]
                ]
            ],
            "margins": ["bottom": 5, "left": 16, "right": 16],
            "paddings": ["bottom": 10, "left": 15, "right": 15, "top": 10],
            "width": ["type": "match_parent"]
        ]
    }

    private func buildExerciseNumber(number: Int, marginRight: Int) -> [String: Any] {
        [
            "type": "container",
            "orientation": "horizontal",
            "alignment_horizontal": "center",
            "alignment_vertical": "center",
            "background": [["type": "solid", "color": "#501F1F1F"]],
            "border": ["corner_radius": 10],
            "items": [
                [
                    "type": "text",
                    "text": "\(number)",
                    "alignment_horizontal": "center",
                    "alignment_vertical": "center",
                    "font_size": 15,
                    "font_weight": "bold",
                    "max_lines": 1,
                    "text_color": "#FFFFFF"
                ]
            ],
            "margins": ["right": marginRight],
            "paddings": ["bottom": 10, "left": 10, "right": 10, "top": 10],
            "width": ["type": "wrap_content"]
        ]
    }

    private func buildExerciseNameAndMuscle(name: String, muscleGroup: String) -> [String: Any] {
        [
            "type": "container",
            "orientation": "horizontal",
            "alignment_vertical": "center",
            "items": [
                [
                    "type": "text",
                    "text": name,
                    "alignment_horizontal": "center",
                    "alignment_vertical": "center",
                    "font_size": 18,
                    "font_weight": "bold",
                    "max_lines": 1,
                    "text_color": "#FFFFFF"
                ],
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_horizontal": "center",
                    "alignment_vertical": "center",
                    "background": [["type": "solid", "color": "#501F1F1F"]],
                    "border": ["corner_radius": 15],
                    "items": [
                        [
                            "type": "text",
                            "text": muscleGroup,
                            "alignment_horizontal": "center",
                            "alignment_vertical": "center",
                            "font_size": 15,
                            "font_weight": "regular",
                            "max_lines": 1,
                            "text_color": "#FFFFFF"
                        ]
                    ],
                    "margins": ["left": 10],
                    "paddings": ["bottom": 10, "left": 10, "right": 10, "top": 10],
                    "width": ["type": "wrap_content"]
                ]
            ],
            "width": ["type": "wrap_content"]
        ]
    }

    private func buildMetricCard(title: String, value: String) -> [String: Any] {
        [
            "type": "container",
            "orientation": "vertical",
            "alignment_horizontal": "center",
            "alignment_vertical": "center",
            "background": [["type": "solid", "color": "#501F1F1F"]],
            "border": ["corner_radius": 10],
            "items": [
                [
                    "type": "text",
                    "text": title,
                    "alignment_horizontal": "center",
                    "alignment_vertical": "center",
                    "font_size": 15,
                    "font_weight": "bold",
                    "margins": ["bottom": 10, "top": 5],
                    "max_lines": 1,
                    "text_color": "#55FFFFFF",
                    "width": ["type": "wrap_content"]
                ],
                [
                    "type": "text",
                    "text": value,
                    "alignment_horizontal": "center",
                    "alignment_vertical": "center",
                    "font_size": 15,
                    "font_weight": "bold",
                    "margins": ["bottom": 5],
                    "max_lines": 1,
                    "text_color": "#FFFFFF",
                    "width": ["type": "wrap_content"]
                ]
            ],
            "margins": ["right": 10],
            "paddings": ["bottom": 5, "left": 20, "right": 20, "top": 5],
            "width": ["type": "match_parent"]
        ]
    }

    // MARK: - Start button (Div)

    private func buildStartButtonDiv(workoutId: String) -> [String: Any] {
        [
            "type": "container",
            "orientation": "overlap",
            "action_animation": [
                "duration": 120,
                "end_value": 0.9,
                "interpolator": "ease_in_out",
                "name": "scale",
                "start_value": 1.0
            ],
            "actions": [
                ["log_id": "open_player", "url": "app://open_player?id=\(workoutId)"]
            ],
            "border": ["corner_radius": 28],
            "height": ["type": "wrap_content"],
            "items": [
                [
                    "type": "container",
                    "background": [
                        ["type": "gradient", "angle": 180, "colors": ["#99FFFFFF", "#45FFFFFF", "#00FFFFFF"]]
                    ],
                    "border": ["corner_radius": 28],
                    "height": ["type": "match_parent"],
                    "paddings": ["bottom": 1, "left": 1, "right": 1, "top": 1],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "background": [
                        ["type": "solid", "color": "#732AFF"]
                    ],
                    "border": ["corner_radius": 26],
                    "height": ["type": "match_parent"],
                    "margins": ["bottom": 2, "left": 2, "right": 2, "top": 2],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "background": [
                        ["type": "gradient", "angle": -45, "colors": ["#45FFFFFF", "#20FFFFFF", "#00FFFFFF"]]
                    ],
                    "height": ["type": "match_parent"],
                    "width": ["type": "match_parent"]
                ],
                [
                    "type": "container",
                    "orientation": "horizontal",
                    "alignment_horizontal": "center",
                    "alignment_vertical": "center",
                    "background": [
                        ["type": "solid", "color": "#00FFFFFF"]
                    ],
                    "border": ["corner_radius": 28],
                    "items": [
                        [
                            "type": "text",
                            "text": "Start Workout",
                            "alignment_vertical": "center",
                            "font_size": 20,
                            "font_weight": "medium",
                            "text_color": "#FFFFFF"
                        ]
                    ],
                    "paddings": ["bottom": 18, "left": 18, "right": 18, "top": 18],
                    "width": ["type": "wrap_content"]
                ]
            ],
            "margins": ["bottom": 12, "left": 16, "right": 16, "top": 16],
            "width": ["type": "match_parent"]
        ]
    }
    
    private let workoutsMock: [Workout] = [
        
        Workout(
            id: "1",
            name: "Easy Run",
            type: .cardio,
            exercises: [
                CardioExercise(
                    id: "cardio_1_1",
                    name: "Warm-up Walk",
                    muscleGroup: .fullBody,
                    durationMinutes: 5,
                    pace: .walk
                ),
                CardioExercise(
                    id: "cardio_1_2",
                    name: "Easy Jog",
                    muscleGroup: .legs,
                    durationMinutes: 20,
                    pace: .jog
                ),
                CardioExercise(
                    id: "cardio_1_3",
                    name: "Cool-down Walk",
                    muscleGroup: .fullBody,
                    durationMinutes: 5,
                    pace: .walk
                )
            ]
        ),
        
        Workout(
            id: "2",
            name: "Chest Day",
            type: .strength,
            exercises: [
                StrengthExercise(
                    id: "strength_2_1",
                    name: "Barbell Bench Press",
                    muscleGroup: .chest,
                    sets: 4,
                    reps: 10,
                    weightKg: 60.0
                ),
                StrengthExercise(
                    id: "strength_2_2",
                    name: "Incline Dumbbell Press",
                    muscleGroup: .chest,
                    sets: 3,
                    reps: 12,
                    weightKg: 20.0
                ),
                StrengthExercise(
                    id: "strength_2_3",
                    name: "Cable Flyes",
                    muscleGroup: .chest,
                    sets: 3,
                    reps: 15,
                    weightKg: 15.0
                ),
                StrengthExercise(
                    id: "strength_2_4",
                    name: "Push-ups",
                    muscleGroup: .chest,
                    sets: 3,
                    reps: 20,
                    weightKg: 0.0
                )
            ]
        ),
        
        Workout(
            id: "3",
            name: "Legs",
            type: .strength,
            exercises: [
                StrengthExercise(
                    id: "strength_3_1",
                    name: "Barbell Squats",
                    muscleGroup: .legs,
                    sets: 4,
                    reps: 10,
                    weightKg: 70.0
                ),
                StrengthExercise(
                    id: "strength_3_2",
                    name: "Romanian Deadlifts",
                    muscleGroup: .glutes,
                    sets: 3,
                    reps: 12,
                    weightKg: 50.0
                ),
                StrengthExercise(
                    id: "strength_3_3",
                    name: "Walking Lunges",
                    muscleGroup: .legs,
                    sets: 3,
                    reps: 16,
                    weightKg: 12.0
                ),
                StrengthExercise(
                    id: "strength_3_4",
                    name: "Leg Press",
                    muscleGroup: .legs,
                    sets: 3,
                    reps: 15,
                    weightKg: 100.0
                ),
                StrengthExercise(
                    id: "strength_3_5",
                    name: "Calf Raises",
                    muscleGroup: .legs,
                    sets: 4,
                    reps: 20,
                    weightKg: 30.0
                )
            ]
        ),
        
        Workout(
            id: "4",
            name: "HIIT",
            type: .cardio,
            exercises: [
                CardioExercise(
                    id: "cardio_4_1",
                    name: "Warm-up",
                    muscleGroup: .fullBody,
                    durationMinutes: 3,
                    pace: .jog
                ),
                CardioExercise(
                    id: "cardio_4_2",
                    name: "Sprint Intervals",
                    muscleGroup: .legs,
                    durationMinutes: 1,
                    pace: .sprint
                ),
                CardioExercise(
                    id: "cardio_4_3",
                    name: "Recovery",
                    muscleGroup: .fullBody,
                    durationMinutes: 1,
                    pace: .recovery
                ),
                CardioExercise(
                    id: "cardio_4_4",
                    name: "Sprint Intervals",
                    muscleGroup: .legs,
                    durationMinutes: 1,
                    pace: .sprint
                ),
                CardioExercise(
                    id: "cardio_4_5",
                    name: "Recovery",
                    muscleGroup: .fullBody,
                    durationMinutes: 1,
                    pace: .recovery
                ),
                CardioExercise(
                    id: "cardio_4_6",
                    name: "Sprint Intervals",
                    muscleGroup: .legs,
                    durationMinutes: 1,
                    pace: .sprint
                ),
                CardioExercise(
                    id: "cardio_4_7",
                    name: "Recovery",
                    muscleGroup: .fullBody,
                    durationMinutes: 1,
                    pace: .recovery
                ),
                CardioExercise(
                    id: "cardio_4_8",
                    name: "Sprint Intervals",
                    muscleGroup: .legs,
                    durationMinutes: 1,
                    pace: .sprint
                ),
                CardioExercise(
                    id: "cardio_4_9",
                    name: "Cool-down",
                    muscleGroup: .fullBody,
                    durationMinutes: 5,
                    pace: .walk
                )
            ]
        ),
        
        Workout(
            id: "5",
            name: "Morning Stretch",
            type: .yoga,
            exercises: [
                YogaExercise(
                    id: "yoga_5_1",
                    name: "Child's Pose",
                    muscleGroup: .back,
                    holdSeconds: 60,
                    breathCount: 8
                ),
                YogaExercise(
                    id: "yoga_5_2",
                    name: "Cat-Cow Stretch",
                    muscleGroup: .core,
                    holdSeconds: 45,
                    breathCount: 10
                ),
                YogaExercise(
                    id: "yoga_5_3",
                    name: "Seated Forward Bend",
                    muscleGroup: .legs,
                    holdSeconds: 45,
                    breathCount: 7
                ),
                YogaExercise(
                    id: "yoga_5_4",
                    name: "Spinal Twist",
                    muscleGroup: .core,
                    holdSeconds: 30,
                    breathCount: 6
                ),
                YogaExercise(
                    id: "yoga_5_5",
                    name: "Legs Up The Wall",
                    muscleGroup: .legs,
                    holdSeconds: 90,
                    breathCount: 12
                )
            ]
        ),
        
        Workout(
            id: "6",
            name: "Yoga Flow",
            type: .yoga,
            exercises: [
                YogaExercise(
                    id: "yoga_6_1",
                    name: "Mountain Pose → Forward Fold",
                    muscleGroup: .fullBody,
                    holdSeconds: 30,
                    breathCount: 5
                )
            ]
        ),
        
        Workout(
            id: "7",
            name: "HIIT",
            type: .cardio,
            exercises: [
                CardioExercise(
                    id: "cardio_7_1",
                    name: "Dynamic Warm-up",
                    muscleGroup: .fullBody,
                    durationMinutes: 5,
                    pace: .jog
                )
            ]
        ),
        
        Workout(
            id: "8",
            name: "Chest Day",
            type: .strength,
            exercises: [
                StrengthExercise(
                    id: "strength_8_1",
                    name: "Dumbbell Bench Press",
                    muscleGroup: .chest,
                    sets: 4,
                    reps: 12,
                    weightKg: 25.0
                )
            ]
        )
    ]
}




