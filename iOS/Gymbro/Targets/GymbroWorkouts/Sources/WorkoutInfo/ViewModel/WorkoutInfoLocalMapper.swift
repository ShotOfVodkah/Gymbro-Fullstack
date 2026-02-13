import Foundation

import GymbroNetwork
import GymbroTypes

final class WorkoutInfoLocalMapper {
    
    init(localRepository: DivCacheRepository) {
        self.localRepository = localRepository
    }
    
    private let localRepository: DivCacheRepository
    
    // MARK: - Internal
    
    func render(id: String) -> Data? {
        
        guard let workout = workoutsMock.first(where: { $0.id == id }) else { return nil }
        
        guard let templatesData = localRepository.load(key: "workoutInfoTemplate") else {
            
            return nil
        }
            
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: templatesData)
            
            guard let dict = jsonObject as? [String: Any] else {
                return nil
            }
            
            guard let templates = dict["templates"] as? [String: Any] else {
                return nil
            }
            
            let context = buildContext(for: workout)
            
            guard let cardTemplate = templates["workout_card"] else {
                
                return nil
            }
            
            let renderedCard = renderTemplate(
                cardTemplate,
                context: context,
                templates: templates,
                workout: workout
            ) as? [String: Any]
            
            let divKitJson: [String: Any] = [
                "card": renderedCard ?? [:],
                "templates": [:],
                "variables": []
            ]
            
            return try? JSONSerialization.data(withJSONObject: divKitJson, options: [.prettyPrinted])
            
        } catch {
            print("Error: \(error)")
            return nil
        }
    }
    
    private func renderTemplate(_ node: Any, context: [String: String], templates: [String: Any], workout: Workout) -> Any {
        switch node {
        case let dict as [String: Any]:
            var newDict: [String: Any] = [:]
            for (key, value) in dict {
                newDict[key] = renderTemplate(value, context: context, templates: templates, workout: workout)
            }
            return newDict
            
        case let array as [Any]:
            var newArray: [Any] = []
            for element in array {
                if let placeholder = element as? String,
                   placeholder.hasPrefix("!!") && placeholder.hasSuffix("??") {
                    
                    let placeholderName = String(placeholder.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                    
                    if let replacement = context[placeholderName] {
                        newArray.append(replacement)
                    } else if placeholderName == "exercise_cards_array" {
                        newArray.append(contentsOf: renderExerciseCards(for: workout, templates: templates))
                    } else if let blockTemplate = templates[placeholderName] {
                        newArray.append(renderTemplate(blockTemplate, context: context, templates: templates, workout: workout))
                    } else {
                        newArray.append(placeholder)
                    }
                } else {
                    newArray.append(renderTemplate(element, context: context, templates: templates, workout: workout))
                }
            }
            return newArray
            
        case let str as String:
            if str.hasPrefix("!!") && str.hasSuffix("??") {
                let placeholderName = String(str.dropFirst(2).dropLast(2)).trimmingCharacters(in: .whitespaces)
                
                if let replacement = context[placeholderName] {
                    return replacement
                }
                
                if placeholderName == "exercise_cards_array" {
                    return renderExerciseCards(for: workout, templates: templates)
                }
                
                if let blockTemplate = templates[placeholderName] {
                    return renderTemplate(blockTemplate, context: context, templates: templates, workout: workout)
                }
                
                return str
            }
            
            let pattern = "!!([\\w.]+)\\?\\?"
            guard let regex = try? NSRegularExpression(pattern: pattern) else {
                return str
            }
            
            let nsString = str as NSString
            let matches = regex.matches(in: str, range: NSRange(location: 0, length: nsString.length))
            
            guard !matches.isEmpty else {
                return str
            }
            
            var result = str
            for match in matches.reversed() {
                let placeholderRange = match.range
                let keyRange = match.range(at: 1)
                
                let placeholderName = nsString.substring(with: keyRange)
                
                if let replacement = context[placeholderName] {
                    guard let swiftRange = Range(placeholderRange, in: result) else { continue }
                    result.replaceSubrange(swiftRange, with: replacement)
                }
            }
            
            return result
            
        default:
            return node
        }
    }
    
    private func renderExerciseCards(for workout: Workout, templates: [String: Any]) -> [Any] {
        let style = workout.type.style
        var exerciseCards: [Any] = []
        
        for (index, exercise) in workout.exercises.enumerated() {
            let number = index + 1
            let exerciseContext = buildExerciseContext(exercise: exercise, number: number, style: style)
            
            let templateKey: String
            switch exercise {
            case is StrengthExercise:
                templateKey = "exercise_card_strength"
            case is CardioExercise:
                templateKey = "exercise_card_cardio"
            case is YogaExercise:
                templateKey = "exercise_card_yoga"
            default:
                continue
            }
            
            guard let template = templates[templateKey] else {
                continue
            }
            
            let renderedCard = renderTemplate(template, context: exerciseContext, templates: templates, workout: workout)
            exerciseCards.append(renderedCard)
        }
        
        return exerciseCards
    }
    
    private func buildContext(for workout: Workout) -> [String: String] {
        let style = workout.type.style
        
        return [
            "workout.id": workout.id,
            "workout.name": workout.name,
            "workout.type_title": workout.type.title,
            "workout.exercises_count": "\(workout.exercises.count)",
            
            "style.header_gradient_start": style.headerGradientStart,
            "style.header_gradient_end": style.headerGradientEnd,
            "style.exercise_gradient_color": style.exerciseGradientColor,
            "style.icon_url": style.iconUrl
        ]
    }
    
    private func buildExerciseContext(exercise: Exercise, number: Int, style: WorkoutStyle) -> [String: String] {
        var context: [String: String] = [
            "exercise.number": "\(number)",
            "exercise.name": exercise.name,
            "exercise.muscle_group": exercise.muscleGroup.title,
            "style.exercise_gradient_color": style.exerciseGradientColor
        ]
        
        let numberMargin: Int
        switch exercise {
        case is StrengthExercise:
            numberMargin = 30
        default:
            numberMargin = 20
        }
        context["exercise.number_margin"] = "\(numberMargin)"
        
        switch exercise {
        case let strength as StrengthExercise:
            context["exercise.sets"] = "\(strength.sets)"
            context["exercise.reps"] = "\(strength.reps)"
            context["exercise.weight"] = String(format: "%.1f", strength.weightKg)
            
        case let cardio as CardioExercise:
            context["exercise.duration"] = "\(cardio.durationMinutes)"
            context["exercise.pace"] = cardio.pace.title
            
        case let yoga as YogaExercise:
            context["exercise.hold_seconds"] = "\(yoga.holdSeconds)"
            context["exercise.breath_count"] = "\(yoga.breathCount)"
            
        default:
            break
        }
        
        return context
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
