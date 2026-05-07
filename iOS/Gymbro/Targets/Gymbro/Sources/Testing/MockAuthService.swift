import Foundation
import GymbroNetwork

final class MockAuthService: AuthServiceProtocol {
    
    private static let token =
    "eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJ1c2VyX2lkIjoiMSIsImVtYWlsIjoidWktdGVzdEBneW1icm8uZGV2Iiwicm9sZSI6ImF0aGxldGUiLCJzZXNzaW9uX2lkIjoidWktdGVzdC1zZXNzaW9uIn0.mock"

    func login(email: String, password: String) async throws -> TokenResponse {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            throw MockAuthServiceError.validationFailed
        }

        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            throw MockAuthServiceError.validationFailed
        }

        guard password.count >= 6 else {
            throw MockAuthServiceError.validationFailed
        }

        return TokenResponse(
            access_token: Self.token,
            refresh_token: "mock-refresh-token"
        )
    }

    func register(email: String, password: String, role: String) async throws -> UserResponse {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty,
              trimmedEmail.contains("@"),
              trimmedEmail.contains("."),
              password.count >= 6
        else {
            throw MockAuthServiceError.validationFailed
        }

        return UserResponse(
            id: 1,
            email: trimmedEmail,
            role: role,
            emailVerified: false,
            devVerifyURL: "gymbro://verify-email?token=mock-verify-token"
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
    
    enum MockAuthServiceError: LocalizedError {
        case validationFailed

        var errorDescription: String? {
            "Mock validation failed."
        }
    }
}
