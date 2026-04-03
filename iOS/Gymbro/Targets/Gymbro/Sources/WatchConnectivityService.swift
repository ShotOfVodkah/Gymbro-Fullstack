import Foundation
import WatchConnectivity

import GymbroNetwork
import GymbroTypes

final class WatchConnectivityService: NSObject {

    init(
        workoutsRepository: WorkoutsCacheRepository
    ) {
        self.workoutsRepository = workoutsRepository
    }

    func activate() {
        guard WCSession.isSupported() else {
            return
        }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func syncWorkouts(_ workouts: [Workout]) {
        guard WCSession.default.activationState == .activated,
              WCSession.default.isPaired else {
            print(WCSession.default.activationState)
            print(WCSession.default.isPaired)
            return
        }
        let payloads = workouts.map { WatchWorkoutPayload(from: $0) }
        guard let data = try? JSONEncoder().encode(payloads) else { return }
        try? WCSession.default.updateApplicationContext(["workouts": data])
    }
    
    private let workoutsRepository: WorkoutsCacheRepository
}

// MARK: - WCSessionDelegate

extension WatchConnectivityService: WCSessionDelegate {

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        guard activationState == .activated else {
            return
        }
        Task {
            let workouts: [Workout]
            do {
                workouts = try await AppMicroservices.workouts.fetchUserWorkouts()
            } catch {
                workouts = workoutsRepository.loadWorkouts(key: "user")
            }
            if workouts.isEmpty { return }
            syncWorkouts(workouts)
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        guard let data = userInfo["session"] as? Data,
              let payload = try? JSONDecoder().decode(WatchSessionPayload.self, from: data) else { return }

        let exercises = payload.exercises.map {
            WorkoutExerciseRequest(
                exerciseId: $0.exerciseId,
                sets: $0.sets,
                reps: $0.reps,
                weightKg: $0.weightKg,
                durationMinutes: $0.durationMinutes,
                pace: $0.pace.flatMap { PaceType(rawValue: $0) },
                holdSeconds: $0.holdSeconds,
                breathCount: $0.breathCount
            )
        }

        Task {
            try? await AppMicroservices.workouts.createSession(
                workoutId: payload.workoutId,
                exercises: exercises
            )
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}

// MARK: - Payload types (mirror of watch-side WatchPayloads)

private struct WatchWorkoutPayload: Codable {
    let id: String
    let name: String
    let type: WorkoutType
    let exercises: [ExerciseItem]

    init(from workout: Workout) {
        id = workout.id
        name = workout.name
        type = workout.type
        exercises = workout.exercises.map { ExerciseItem(from: $0) }
    }
}

private struct WatchSessionPayload: Codable {
    let workoutId: String
    let completedAt: String
    let exercises: [WatchExerciseResult]
}

private struct WatchExerciseResult: Codable {
    let exerciseId: String
    let sets: Int?
    let reps: Int?
    let weightKg: Double?
    let durationMinutes: Int?
    let pace: String?
    let holdSeconds: Int?
    let breathCount: Int?
}
