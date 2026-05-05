import Foundation
import UIKit

public protocol AuthServiceProtocol: AnyObject {
    func login(email: String, password: String) async throws -> TokenResponse
    func register(email: String, password: String, role: String) async throws -> UserResponse
    func refresh(refreshToken: String) async throws -> TokenResponse
    func verifyEmail(token: String) async throws -> TokenResponse
    func resendVerificationEmail(email: String) async throws -> BasicOKResponse
    func logout() async throws
    func listSessions() async throws -> AuthSessionsListResponse
    func revokeSession(sessionID: String) async throws -> BasicOKResponse
    func logoutAllDevices() async throws -> BasicOKResponse
}

public final class AuthService {
    private let client: NetworkClient

    public init(client: NetworkClient) {
        self.client = client
    }

    public func login(
        email: String,
        password: String
    ) async throws -> TokenResponse {
        let deviceName = await MainActor.run { UIDevice.current.name }
        let body = LoginRequest(User: email, Password: password, deviceName: deviceName, platform: "iOS")

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
        let body = RegisterRequest(
            email: email,
            password: password,
            role: role
        )

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

    public func verifyEmail(token: String) async throws -> TokenResponse {
        let body = VerifyEmailRequest(token: token)

        return try await client.request(
            method: .POST,
            path: "/auth/verify-email",
            body: body,
            requiresAuth: false,
            responseType: TokenResponse.self
        )
    }

    public func resendVerificationEmail(email: String) async throws -> BasicOKResponse {
        let body = ResendVerificationRequest(email: email)

        return try await client.request(
            method: .POST,
            path: "/auth/resend-verification-email",
            body: body,
            requiresAuth: false,
            responseType: BasicOKResponse.self
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
    
    public func listSessions() async throws -> AuthSessionsListResponse {
        try await client.request(
            method: .GET,
            path: "/auth/sessions",
            body: Optional<String>.none,
            requiresAuth: true,
            responseType: AuthSessionsListResponse.self
        )
    }

    public func revokeSession(sessionID: String) async throws -> BasicOKResponse {
        try await client.request(
            method: .DELETE,
            path: "/auth/sessions/\(sessionID)",
            body: Optional<String>.none,
            requiresAuth: true,
            responseType: BasicOKResponse.self
        )
    }

    public func logoutAllDevices() async throws -> BasicOKResponse {
        try await client.request(
            method: .POST,
            path: "/auth/logout-all",
            body: Optional<String>.none,
            requiresAuth: true,
            responseType: BasicOKResponse.self
        )
    }
}

extension AuthService: AuthServiceProtocol {}
