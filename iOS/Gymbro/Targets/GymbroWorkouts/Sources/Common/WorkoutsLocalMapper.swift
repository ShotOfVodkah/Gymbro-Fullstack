import Foundation

import GymbroNetwork
import GymbroTypes

public final class WorkoutsLocalMapper {
    
    public init(
        divLocalRepository: DivCacheRepository,
        workoutsLocalRepository: WorkoutsCacheRepository
    ) {
        self.divLocalRepository = divLocalRepository
        self.workoutsLocalRepository = workoutsLocalRepository
    }
    
    private let divLocalRepository: DivCacheRepository
    private let workoutsLocalRepository: WorkoutsCacheRepository
    
    
    // MARK: - Public API
    
    public func addWorkoutCard(to screenData: Data, id: String, fromPremade: Bool) -> Data? {
        do {
            let workout = workoutsLocalRepository.loadWorkout(key: fromPremade ? "premade" : "user", workoutId: id)
            
            guard let workout = workoutsLocalRepository.loadWorkout(
                key: fromPremade ? "premade" : "user",
                workoutId: id
            ),
            var screenJson = try JSONSerialization.jsonObject(with: screenData) as? [String: Any],
            let templatesData = divLocalRepository.load(key: "workoutInfoTemplate")
            else {
                return nil
            }
            
            let jsonObject = try JSONSerialization.jsonObject(with: templatesData)
            
            guard let dict = jsonObject as? [String: Any],
                  let templates = dict["templates"] as? [String: Any],
                  let workoutCard = templates["workouts_list_card"]
            else {
                return nil
            }
            guard var card = screenJson["card"] as? [String: Any],
                  var states = card["states"] as? [[String: Any]],
                  !states.isEmpty else {
                return nil
            }
            
            var firstState = states[0]
            
            guard var div = firstState["div"] as? [String: Any],
                  var items = div["items"] as? [Any],
                  items.count > 2,
                  var gallery = items[2] as? [String: Any],
                  var galleryItems = gallery["items"] as? [[String: Any]] else {
                return nil
            }
            
            let context: [String: String] = [
                "workout_name": workout.name,
                "workout_type": workout.type.localizedTitle,
                "workout_id": workout.id,
                "icon_url": workout.type.style.iconUrl,
                "workout_color": workout.type.style.headerGradientStart
            ]
                    
            let newCard = renderTemplate(
                workoutCard,
                context: context,
                templates: templates,
                workout: workout
            ) as? [String: Any]
            
            if let newCard = newCard {
                galleryItems.append(newCard)
                gallery["items"] = galleryItems
                items[2] = gallery
                div["items"] = items
                firstState["div"] = div
                states[0] = firstState
                card["states"] = states
                screenJson["card"] = card
                if fromPremade {
                    workoutsLocalRepository.upsertWorkout(key: "user", workout: workout)
                }
                return try JSONSerialization.data(withJSONObject: screenJson, options: [.prettyPrinted])
            }
                    
            return nil
        } catch {
            return nil
        }
    }
    
    public func removeWorkoutCard(from screenData: Data, id: String) -> Data? {
        do {
            guard
                var screenJson = try JSONSerialization.jsonObject(with: screenData) as? [String: Any],
                var card = screenJson["card"] as? [String: Any],
                var states = card["states"] as? [[String: Any]],
                !states.isEmpty
            else { return nil }

            var firstState = states[0]

            guard
                var div = firstState["div"] as? [String: Any],
                var items = div["items"] as? [Any],
                items.count > 2,
                var gallery = items[2] as? [String: Any],
                var galleryItems = gallery["items"] as? [[String: Any]]
            else { return nil }

            galleryItems.removeAll { item in
                guard let openUrl = item["open_url"] as? String else { return false }
                return extractId(fromOpenUrl: openUrl) == id
            }

            gallery["items"] = galleryItems
            items[2] = gallery
            div["items"] = items
            firstState["div"] = div
            states[0] = firstState
            card["states"] = states
            screenJson["card"] = card

            return try JSONSerialization.data(withJSONObject: screenJson, options: [.prettyPrinted])
        } catch {
            return nil
        }
    }

    public func renderWorkoutInfo(id: String) -> Data? {
        guard let workout = workoutsLocalRepository.loadWorkout(
            key: "user",
            workoutId: id
        ) else { return nil }
        return render(id: id, screenType: .workoutInfo, workout: workout)
    }
    
    public func renderWorkoutBuilder(id: String) -> Data? {
        guard let workout = workoutsLocalRepository.loadWorkout(
            key: "premade",
            workoutId: id
        ) else {
            return nil
        }
        return render(id: id, screenType: .workoutBuilder, workout: workout)
    }
    public func expandExercises(
        in screenData: Data,
        exerciseIds: [String]
    ) -> Data? {
        do {
            guard var screenJson = try JSONSerialization.jsonObject(with: screenData) as? [String: Any],
                  var card = screenJson["card"] as? [String: Any],
                  var states = card["states"] as? [[String: Any]],
                  !states.isEmpty
            else {
                return nil
            }

            var firstState = states[0]

            guard var div = firstState["div"] as? [String: Any],
                var items = div["items"] as? [Any],
                !items.isEmpty,
                var gallery = items[0] as? [String: Any],
                var galleryItems = gallery["items"] as? [[String: Any]]
            else {
                print("⚠️ Failed to parse gallery path")
                return nil
            }

            let expandedIds = Set(exerciseIds)
            galleryItems = galleryItems.map { item in
                guard var stateItem = item as? [String: Any],
                      stateItem["type"] as? String == "state",
                      let exerciseId = stateItem["id"] as? String,
                      expandedIds.contains(exerciseId)
                else {
                    return item
                }
                
                stateItem["default_state_id"] = "expanded"
                return stateItem
            }
            gallery["items"] = galleryItems
            items[0] = gallery
            div["items"] = items
            firstState["div"] = div
            states[0] = firstState
            card["states"] = states
            screenJson["card"] = card

            return try JSONSerialization.data(withJSONObject: screenJson, options: [.prettyPrinted])
            
        } catch {
            print("Expand exercises error: \(error)")
            return nil
        }
    }
    
    // MARK: - Internal
    
    private enum ScreenType {
        case workoutInfo
        case workoutBuilder
    }
    
    private func render(id: String, screenType: ScreenType, workout: Workout) -> Data? {
        
        guard let templatesData = divLocalRepository.load(key: "workoutInfoTemplate") else {
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
            
            let context = buildContext(for: workout, screenType: screenType)
            
            let rootTemplateKey: String
            switch screenType {
            case .workoutInfo:
                rootTemplateKey = "workout_card"
            case .workoutBuilder:
                rootTemplateKey = "workout_builder_sheet"
            }
            
            guard let cardTemplate = templates[rootTemplateKey] else {
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
    
    private func buildContext(for workout: Workout, screenType: ScreenType) -> [String: String] {
        let style = workout.type.style
        
        var context: [String: String] = [
            "workout.id": workout.id,
            "workout.name": workout.name,
            "workout.type_title": workout.type.localizedTitle,
            "workout.exercises_count": "\(workout.exercises.count)",
            
            "style.header_gradient_start": style.headerGradientStart,
            "style.header_gradient_end": style.headerGradientEnd,
            "style.exercise_gradient_color": style.exerciseGradientColor,
            "style.icon_url": style.iconUrl
        ]
        
        if case .workoutBuilder = screenType {
            context["style.builder_header_start"] = "#732AFF"
            context["style.builder_header_end"] = "#B862F5"
        }
        
        return context
    }
    
    private func buildExerciseContext(exercise: Exercise, number: Int, style: WorkoutStyle) -> [String: String] {
        var context: [String: String] = [
            "exercise.number": "\(number)",
            "exercise.name": exercise.name,
            "exercise.muscle_group": exercise.muscleGroup.localizedTitle,
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
            context["exercise.pace"] = cardio.pace.localizedTitle
            
        case let yoga as YogaExercise:
            context["exercise.hold_seconds"] = "\(yoga.holdSeconds)"
            context["exercise.breath_count"] = "\(yoga.breathCount)"
            
        default:
            break
        }
        
        return context
    }
    
    private func extractId(fromOpenUrl urlString: String) -> String? {
        guard let components = URLComponents(string: urlString) else { return nil }
        return components.queryItems?.first(where: { $0.name == "id" })?.value
    }

}
