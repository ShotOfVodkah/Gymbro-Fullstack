import Foundation

public final class AuthService {

    private let client: NetworkClient

    public init(client: NetworkClient) {
        self.client = client
    }

    public func login(
        email: String,
        password: String
    ) async throws -> TokenResponse {
        let body = LoginRequest(User: email, Password: password)

        return try await client.request(
            method: .POST,
            path: "/auth/login",
            body: body,
            requiresAuth: false,
            responseType: TokenResponse.self
        )
    }
    
    public func register(
        email: String,
        password: String,
        role: String
    ) async throws -> UserResponse {
        let body = RegisterRequest(email: email, password: password, role: role)

        return try await client.request(
            method: .POST,
            path: "/auth/register",
            body: body,
            requiresAuth: false,
            responseType: UserResponse.self
        )
    }

    public func refresh(
        refreshToken: String
    ) async throws -> TokenResponse {
        let body = RefreshRequest(refresh_token: refreshToken)

        return try await client.request(
            method: .POST,
            path: "/auth/refresh",
            body: body,
            requiresAuth: false,
            responseType: TokenResponse.self
        )
    }

    public func logout() async throws {
        try await client.requestVoid(
            method: .POST,
            path: "/auth/logout",
            body: Optional<EmptyBody>.none,
            requiresAuth: true
        )
    }
}
