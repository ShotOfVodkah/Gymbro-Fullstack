import Foundation

public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(code: Int)
    case decodingError
    case encodingError
    case noInternet
    case hostNotFound
    case cancelled
    case unknown(Error)
}

public enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .unauthorized:
            return "You are not authorized"
        case .serverError(let code):
            return "Server error: \(code)"
        case .decodingError:
            return "Failed to decode server response"
        case .encodingError:
            return "Failed to encode request body"
        case .noInternet:
            return "No internet connection"
        case .hostNotFound:
            return "Could not reach the server"
        case .cancelled:
            return "Request was cancelled"
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

public struct EmptyBody: Encodable {}

public final class NetworkClient {
    private let baseURL: URL
    private let session: URLSession
    private let tokenProvider: (() -> String?)?
    private let refreshHandler: (() async throws -> Bool)?
    
    public init(
        baseURL: String,
        session: URLSession = .shared,
        tokenProvider: (() -> String?)? = nil,
        refreshHandler: (() async throws -> Bool)? = nil
    ) {
        guard let url = URL(string: baseURL) else {
            fatalError("Invalid base URL: \(baseURL)")
        }
        self.baseURL = url
        self.session = session
        self.tokenProvider = tokenProvider
        self.refreshHandler = refreshHandler
    }
    
    public func request<Response: Decodable, Body: Encodable>(
        method: HTTPMethod,
        base: URL? = nil,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil,
        requiresAuth: Bool = true,
        responseType: Response.Type
    ) async throws -> Response {
        let request = try buildRequest(
            method: method,
            base: base,
            path: path,
            queryItems: queryItems,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, _) = try await performWithAutoRefresh(
            request: request,
            requiresAuth: requiresAuth
        )
        
        if data.isEmpty {
            throw NetworkError.decodingError
        }
        
        do {
            return try makeDecoder().decode(Response.self, from: data)
        } catch let error as DecodingError {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Raw JSON:\n\(jsonString)")
            }
            switch error {
            case .dataCorrupted(let context):
                print("❌ DataCorrupted: \(context.debugDescription)")
                print("📍 CodingPath: \(context.codingPath.map { $0.stringValue })")
            case .typeMismatch(let type, let context):
                print("❌ TypeMismatch: ожидался \(type)")
                print("📍 CodingPath: \(context.codingPath.map { $0.stringValue })")
            case .keyNotFound(let key, let context):
                print("❌ KeyNotFound: \(key.stringValue)")
                print("📍 CodingPath: \(context.codingPath.map { $0.stringValue })")
            default:
                print("❌ DecodingError: \(error)")
            }
            
            throw NetworkError.decodingError
        }
    }
    
    func requestData<Body: Encodable>(
        method: HTTPMethod,
        base: URL? = nil,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil,
        requiresAuth: Bool = true
    ) async throws -> Data {
        let request = try buildRequest(
            method: method,
            base: base,
            path: path,
            queryItems: queryItems,
            body: body,
            requiresAuth: requiresAuth
        )
        
        let (data, _) = try await performWithAutoRefresh(
            request: request,
            requiresAuth: requiresAuth
        )
        
        return data
    }
    
    public func requestVoid<Body: Encodable>(
        method: HTTPMethod,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil,
        requiresAuth: Bool = true
    ) async throws {
        let request = try buildRequest(
            method: method,
            path: path,
            queryItems: queryItems,
            body: body,
            requiresAuth: requiresAuth
        )
        
        _ = try await performWithAutoRefresh(
            request: request,
            requiresAuth: requiresAuth
        )
    }
    
    private func buildRequest<Body: Encodable>(
        method: HTTPMethod,
        base: URL? = nil,
        path: String,
        queryItems: [URLQueryItem]? = nil,
        body: Body? = nil,
        requiresAuth: Bool
    ) throws -> URLRequest {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        var url = (base ?? baseURL).appendingPathComponent(cleanPath)
        
        if let queryItems, !queryItems.isEmpty {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                throw NetworkError.invalidURL
            }
            components.queryItems = queryItems
            guard let finalURL = components.url else {
                throw NetworkError.invalidURL
            }
            url = finalURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if requiresAuth, let token = tokenProvider?(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body {
            do {
                let encoder = JSONEncoder()
                encoder.dateEncodingStrategy = .iso8601
                request.httpBody = try encoder.encode(body)
            } catch {
                throw NetworkError.encodingError
            }
        }
        
        return request
    }
    
    private func performWithAutoRefresh(
        request: URLRequest,
        requiresAuth: Bool
    ) async throws -> (Data, HTTPURLResponse) {
        
        do {
            return try await perform(request)
        } catch NetworkError.unauthorized {
            guard requiresAuth else {
                throw NetworkError.unauthorized
            }
            
            guard let refreshHandler else {
                throw NetworkError.unauthorized
            }
            
            let refreshed = try await refreshHandler()
            guard refreshed else {
                throw NetworkError.unauthorized
            }
            print("Refresh successful, rebuilding request")
            var retriedRequest = request
            if let token = tokenProvider?(), !token.isEmpty {
                retriedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            print("Retrying request")
            return try await perform(retriedRequest)
        }
    }
    
    
    private func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                throw NetworkError.noInternet
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                throw NetworkError.hostNotFound
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200..<300:
            return (data, httpResponse)
        case 401:
            throw NetworkError.unauthorized
        case 400..<600:
            throw NetworkError.serverError(code: httpResponse.statusCode)
        default:
            throw NetworkError.invalidResponse
        }
    }
    
    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(dateString)"
            )
        }
        return decoder
    }
}
