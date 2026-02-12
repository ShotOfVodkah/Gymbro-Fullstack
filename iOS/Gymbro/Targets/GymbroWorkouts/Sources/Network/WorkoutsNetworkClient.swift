import Foundation

import GymbroNetwork

public protocol WorkoutsNetworkClient {
    func fetchWorkoutsDivJson() async throws -> Data
    func fetchWorkoutInfoDivJson(with id: String) async throws -> Data
}

final class WorkoutsNetworkClientImpl: WorkoutsNetworkClient {
    
    enum ClientError: Error {
        case badStatus(Int)
        case emptyData
    }
    
    private let baseURL: URL
    private let session: URLSession
    
    init(baseURL: URL = URL(string: "http://localhost:8080")!,
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
}
