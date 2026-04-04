import Foundation

final class WorkoutPlayerViewModel: ObservableObject {

    @Published var completedResults: [WatchExerciseResult] = []
    @Published var sets: Int = 3
    @Published var reps: Int = 10
    @Published var weightKg: Double = 20.0
    @Published var durationMinutes: Int = 10
    @Published var pace: PaceType = .jog
    @Published var holdSeconds: Int = 30
    @Published var breathCount: Int = 5

    let workout: WatchWorkoutPayload
    var currentExercise: ExerciseItem { workout.exercises[currentIndex] }
    var totalCount: Int { workout.exercises.count }
    var isLast: Bool { currentIndex == totalCount - 1 }

    init(workout: WatchWorkoutPayload, onSubmit: @escaping (WatchSessionPayload) -> Void) {
        self.workout = workout
        self.onSubmit = onSubmit
        loadCurrentExercise()
    }

    func advanceOrFinish() {
        let result = buildCurrentResult()
        completedResults.append(result)

        if isLast {
            submitSession()
        } else {
            moveToNext()
        }
    }

    func buildCurrentResult() -> WatchExerciseResult {
        switch currentExercise {
        case .strength:
            return WatchExerciseResult(
                exerciseId: currentExercise.id,
                sets: sets,
                reps: reps,
                weightKg: weightKg
            )
        case .cardio:
            return WatchExerciseResult(
                exerciseId: currentExercise.id,
                durationMinutes: durationMinutes,
                pace: pace.rawValue
            )
        case .yoga:
            return WatchExerciseResult(
                exerciseId: currentExercise.id,
                holdSeconds: holdSeconds,
                breathCount: breathCount
            )
        case .fallback:
            return WatchExerciseResult(exerciseId: currentExercise.id)
        }
    }
    
    private let onSubmit: (WatchSessionPayload) -> Void

    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var showFinishConfirmation: Bool = false

    private func submitSession() {
        let payload = WatchSessionPayload(
            workoutId: workout.id,
            completedAt: ISO8601DateFormatter().string(from: Date()),
            exercises: completedResults
        )
        onSubmit(payload)
        showFinishConfirmation = true
    }

    private func moveToNext() {
        currentIndex += 1
        loadCurrentExercise()
    }

    private func loadCurrentExercise() {
        switch currentExercise {
        case .strength(let e):
            sets = e.sets
            reps = e.reps
            weightKg = e.weightKg
        case .cardio(let e):
            durationMinutes = e.durationMinutes
            pace = e.pace ?? .jog
        case .yoga(let e):
            holdSeconds = e.holdSeconds
            breathCount = e.breathCount
        case .fallback:
            break
        }
    }
}
