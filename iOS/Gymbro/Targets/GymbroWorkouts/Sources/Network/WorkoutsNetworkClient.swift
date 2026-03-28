import Foundation

import GymbroNetwork
import GymbroTypes

public protocol WorkoutsNetworkClient {
    func fetchWorkoutsDivJson() async throws -> Data
    func fetchWorkoutBuilderTitleJson() async throws -> Data
    func fetchWorkoutBuilderSheetJson(with id: String) async throws -> Data
    func fetchWorkoutInfoDivJson(with id: String) async throws -> Data
    func fetchWorkoutBuilderForTypeDivJson(with type: String, workout: Workout?) async throws -> Data
    func fetchWorkoutInfoTemplates() async throws -> Data
}

final class WorkoutsNetworkClientImpl: WorkoutsNetworkClient {
    
    enum ClientError: Error {
        case badStatus(Int)
        case emptyData
        case invalidJSON
        case missingTemplates
    }
    
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL = URL(string: "http://localhost:8090")!,
         session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetchWorkoutsDivJson() async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent("workoutsList"))
        request.httpMethod = "GET"
//        request.setValue("ru", forHTTPHeaderField: "Accept-Language")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ClientError.badStatus(http.statusCode)
        }
        guard !data.isEmpty else { throw ClientError.emptyData }
        return data
    }
    
    func fetchWorkoutBuilderTitleJson() async throws -> Data {
        var request = URLRequest(url: baseURL.appendingPathComponent("workoutBuilderTitle"))
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ClientError.badStatus(http.statusCode)
        }
        guard !data.isEmpty else { throw ClientError.emptyData }
        return data
    }
    
    func fetchWorkoutBuilderForTypeDivJson(
        with type: String,
        workout: Workout?
    ) async throws -> Data {

        var queryItems = [
            URLQueryItem(name: "type", value: type)
        ]

        if let workout {
            let ids = workout.exercises.map { $0.id }
            queryItems.append(contentsOf:
                ids.map { URLQueryItem(name: "exerciseIds", value: $0) }
            )
        }

        let url = baseURL
            .appendingPathComponent("workoutBuilderForType")
            .appending(queryItems: queryItems)

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw ClientError.badStatus(http.statusCode)
        }

        guard !data.isEmpty else { throw ClientError.emptyData }

        return data
    }
    
    func fetchWorkoutBuilderSheetJson(with id: String) async throws -> Data {
        let url = baseURL.appendingPathComponent("workoutBuilderSheet").appending(queryItems: [
            URLQueryItem(name: "id", value: id)
        ])
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ClientError.badStatus(http.statusCode)
        }
        guard !data.isEmpty else { throw ClientError.emptyData }
        return data
    }
    
    func fetchWorkoutInfoDivJson(with id: String) async throws -> Data {
        let url = baseURL.appendingPathComponent("workoutInfo").appending(queryItems: [
            URLQueryItem(name: "id", value: id)
        ])
            
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await session.data(for: request)
        
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ClientError.badStatus(http.statusCode)
        }
        guard !data.isEmpty else { throw ClientError.emptyData }
        return data
    }
    
    func fetchWorkoutInfoTemplates() async throws -> Data {
        let url = baseURL.appendingPathComponent("divkit/templates/workout_info")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            throw ClientError.badStatus(http.statusCode)
        }

        return data
    }

}
