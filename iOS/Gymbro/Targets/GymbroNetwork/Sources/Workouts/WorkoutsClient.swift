import Foundation

import GymbroTypes

public final class WorkoutsClient {
    
    public init(client: NetworkClient) {
        self.client = client
    }
    
    public func fetchPremadeWorkouts() async throws -> [Workout] {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "userId", value: "premade")
        ]
        let dtos = try await client.request(
            method: .GET,
            path: "workouts/",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [WorkoutDTO].self
        )
        return dtos.map { $0.toWorkout() }
    }

    public func fetchUserWorkouts() async throws -> [Workout] {
        let userId = try requireUserId()
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "userId", value: userId)
        ]
        let dtos = try await client.request(
            method: .GET,
            path: "workouts/",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: [WorkoutDTO].self
        )
        return dtos.map { $0.toWorkout() }
    }

    public func fetchExercises(type: WorkoutType) async throws -> [ExerciseItemDTO] {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "type", value: type.rawValue)
        ]
        let dtos = try await client.request(
            method: .GET,
            path: "exercises",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: false,
            responseType: [CatalogExerciseDTO].self
        )
        return dtos.map { $0.toExerciseItemDTO() }
    }

    public func createWorkout(_ workout: Workout) async throws -> Workout {
        let userId = try requireUserId()
        let body = CreateWorkoutRequest(
            id: workout.id,
            userId: userId,
            name: workout.name,
            type: workout.type,
            exercises: workout.exercises.map { WorkoutExerciseRequest(from: $0) }
        )
        let dto = try await client.request(
            method: .POST,
            path: "workouts/",
            body: body,
            requiresAuth: true,
            responseType: WorkoutDTO.self
        )
        return dto.toWorkout()
    }

    public func editWorkout(_ workout: Workout) async throws -> Workout {
        let body = UpdateWorkoutRequest(
            name: workout.name,
            type: workout.type,
            exercises: workout.exercises.map { WorkoutExerciseRequest(from: $0) }
        )
        let dto = try await client.request(
            method: .PUT,
            path: "workouts/\(workout.id)",
            body: body,
            requiresAuth: true,
            responseType: WorkoutDTO.self
        )
        return dto.toWorkout()
    }

    public func fetchWorkout(by id: String) async throws -> Workout {
        let dto = try await client.request(
            method: .GET,
            path: "workouts/\(id)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: WorkoutDTO.self
        )
            
        return dto.toWorkout()
    }
    
    public func fetchWorkoutsList() async throws -> Data {
        let userId = try requireUserId()
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "userId", value: userId),
            divKitLanguageQueryItem(),
        ]
        return try await client.requestData(
            method: .GET,
            base: URL(string: "http://localhost:8090"),
            path: "workoutsList",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
    
    public func generateWorkout(prompt: String, injuries: [Injury]) async throws -> Workout {
        let userId = try requireUserId()
        let requestBody = GenerateWorkoutRequest(
            user_input: prompt,
            injuries: injuries.map { $0.codingValue },
            user_id: userId
        )
        
        let data = try await client.request(
            method: .POST,
            path: "ai/generate",
            body: requestBody,
            requiresAuth: true,
            timeoutInterval: 600,
            responseType: WorkoutDTO.self
        )
        
        return data.toWorkout()
    }
    
    public func fetchWorkoutInfoTemplates() async throws -> Data {
        return try await client.requestData(
            method: .GET,
            base: URL(string: "http://localhost:8090"),
            path: "divkit/templates/workout_info",
            body: Optional<EmptyBody>.none,
            requiresAuth: false
        )
    }

    public func fetchWorkoutBuilderTitleJson() async throws -> Data {
        return try await client.requestData(
            method: .GET,
            base: URL(string: "http://localhost:8090"),
            path: "workoutBuilderTitle",
            queryItems: [divKitLanguageQueryItem()],
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }

    public func fetchWorkoutBuilderForTypeDivJson(
        with type: String,
        workout: Workout?
    ) async throws -> Data {
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "type", value: type),
            divKitLanguageQueryItem(),
        ]
        
        if let workout {
            let ids = workout.exercises.map { $0.id }
            queryItems.append(contentsOf: ids.map { URLQueryItem(name: "exerciseIds", value: $0) })
        }
        
        return try await client.requestData(
            method: .GET,
            base: URL(string: "http://localhost:8090"),
            path: "workoutBuilderForType",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: false
        )
    }

    public func fetchWorkoutBuilderSheetJson(with id: String) async throws -> Data {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "id", value: id),
            divKitLanguageQueryItem(),
        ]
        return try await client.requestData(
            method: .GET,
            base: URL(string: "http://localhost:8090"),
            path: "workoutBuilderSheet",
            queryItems: queryItems,
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }

    public func fetchWorkoutInfoDivJson(with id: String, type: WorkoutInfoType) async throws -> Data {
        return try await client.requestData(
            method: .GET,
            base: URL(string: "http://localhost:8090"),
            path: "workoutInfo",
            queryItems: [
                URLQueryItem(name: "id", value: id),
                URLQueryItem(name: "type", value: type.rawValue),
                divKitLanguageQueryItem(),
            ],
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
    
    public func createSession(
        workoutId: String,
        completedAt: String = ISO8601DateFormatter().string(from: Date()),
        exercises: [WorkoutExerciseRequest]
    ) async throws {
        let userId = try requireUserId()
        let body = CreateSessionRequest(
            id: UUID().uuidString,
            userId: userId,
            workoutId: workoutId,
            completedAt: completedAt,
            exercises: exercises
        )
        try await client.requestVoid(
            method: .POST,
            path: "sessions",
            body: body,
            requiresAuth: true
        )
    }

    public func saveSessionAsWorkout(
        sessionId: String,
        name: String? = nil,
        workoutId: String? = nil
    ) async throws -> Workout {
        let body = SaveSessionAsWorkoutRequest(
            sessionId: sessionId,
            workoutId: workoutId,
            name: name
        )
        let dto = try await client.request(
            method: .POST,
            path: "sessions/save-as-workout",
            body: body,
            requiresAuth: true,
            responseType: WorkoutDTO.self
        )
        return dto.toWorkout()
    }

    public func deleteWorkout(id: String) async throws {
        _ = try await client.request(
            method: .DELETE,
            path: "workouts/\(id)",
            body: Optional<EmptyBody>.none,
            requiresAuth: true,
            responseType: DeleteWorkoutResponse.self
        )
    }

    public func addPremadeWorkout(premadeId: String) async throws {
        let userId = try requireUserId()
        let body = AddPremadeWorkoutRequest(userId: userId, premadeId: premadeId)
        let dto = try await client.request(
            method: .POST,
            path: "workouts/copy-premade",
            body: body,
            requiresAuth: true,
            responseType: WorkoutDTO.self
        )
    }

    private struct DeleteWorkoutResponse: Decodable {
        let ok: Bool
        let id: String
    }

    private struct AddPremadeWorkoutRequest: Encodable {
        let userId: String
        let premadeId: String
    }

    private let client: NetworkClient
    private func requireUserId() throws -> String {
        guard let userId = AppMicroservices.tokens.userId, !userId.isEmpty else {
            throw NetworkError.unauthorized
        }
        return userId
    }

    private func divKitLanguageQueryItem() -> URLQueryItem {
        let code = Locale.current.language.languageCode?.identifier ?? "en"
        return URLQueryItem(name: "lang", value: code)
    }
}

