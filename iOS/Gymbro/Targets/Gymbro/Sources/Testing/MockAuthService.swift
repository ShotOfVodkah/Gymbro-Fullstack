import Foundation
import GymbroNetwork

final class MockAuthService: AuthServiceProtocol {
    
    private static let token =
    "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyX2lkIjoxfQ.mock"

    func login(email: String, password: String) async throws -> TokenResponse {
        TokenResponse(access_token: Self.token, refresh_token: "mock-refresh")
    }

    func register(email: String, password: String, role: String) async throws -> UserResponse {
        UserResponse(
            id: 1,
            email: email,
            role: role,
            emailVerified: true,
            devVerifyURL: "gymbro://verify-email"
        )
    }

    func refresh(refreshToken: String) async throws -> TokenResponse {
        TokenResponse(access_token: Self.token, refresh_token: refreshToken)
    }

    func verifyEmail(token: String) async throws -> TokenResponse {
        TokenResponse(access_token: Self.token, refresh_token: "verified-refresh")
    }

    func resendVerificationEmail(email: String) async throws -> BasicOKResponse {
        BasicOKResponse(ok: true, message: "sent")
    }

    func logout() async throws {}

    func listSessions() async throws -> AuthSessionsListResponse {
        MockDecoder.decode("""
        { "sessions": [] }
        """)
    }

    func revokeSession(sessionID: String) async throws -> BasicOKResponse {
        BasicOKResponse(ok: true, message: "revoked")
    }

    func logoutAllDevices() async throws -> BasicOKResponse {
        BasicOKResponse(ok: true, message: "all logged out")
    }
}
