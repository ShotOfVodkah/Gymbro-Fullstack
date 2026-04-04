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
            return
        }
        let payloads = workouts.map { WatchWorkoutPayload(from: $0) }
        guard let data = try? JSONEncoder().encode(payloads) else { return }
        try? WCSession.default.updateApplicationContext(["workouts": data])
    }
    
    private let workoutsRepository: WorkoutsCacheRepository
}

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

        Task { @MainActor in
            try? await AppMicroservices.workouts.createSession(
                workoutId: payload.workoutId,
                completedAt: payload.completedAt,
                exercises: exercises
            )
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}
