import Foundation

public struct LoginRequest: Encodable {
    public let User: String
    public let Password: String
    public let deviceName: String
    public let platform: String

    public init(User: String, Password: String, deviceName: String, platform: String) {
        self.User = User
        self.Password = Password
        self.deviceName = deviceName
        self.platform = platform
    }
    
    enum CodingKeys: String, CodingKey {
        case User
        case Password
        case deviceName = "device_name"
        case platform
    }
}

public struct RegisterRequest: Encodable {
    public let email: String
    public let password: String
    public let role: String

    public init(email: String, password: String, role: String) {
        self.email = email
        self.password = password
        self.role = role
    }
}

public struct RefreshRequest: Encodable {
    public let refresh_token: String

    public init(refresh_token: String) {
        self.refresh_token = refresh_token
    }
}

public struct VerifyEmailRequest: Encodable {
    public let token: String

    public init(token: String) {
        self.token = token
    }
}

public struct ResendVerificationRequest: Encodable {
    public let email: String

    public init(email: String) {
        self.email = email
    }
}

public struct TokenResponse: Decodable {
    public let access_token: String
    public let refresh_token: String

    public init(access_token: String, refresh_token: String) {
        self.access_token = access_token
        self.refresh_token = refresh_token
    }
}

public struct UserResponse: Decodable {
    public let id: Int
    public let email: String
    public let role: String
    public let emailVerified: Bool
    public let devVerifyURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case role
        case emailVerified = "email_verified"
        case devVerifyURL = "dev_verify_url"
    }

    public init(
        id: Int,
        email: String,
        role: String,
        emailVerified: Bool,
        devVerifyURL: String? = nil
    ) {
        self.id = id
        self.email = email
        self.role = role
        self.emailVerified = emailVerified
        self.devVerifyURL = devVerifyURL
    }
}

public struct BasicOKResponse: Decodable {
    public let ok: Bool
    public let message: String

    public init(ok: Bool, message: String) {
        self.ok = ok
        self.message = message
    }
}

public struct AuthSessionResponse: Decodable, Identifiable, Hashable {
    public var id: String { sessionID }

    public let sessionID: String
    public let deviceName: String
    public let platform: String
    public let ipAddress: String?
    public let createdAt: Date
    public let lastUsedAt: Date?
    public let expiresAt: Date
    public let isCurrent: Bool

    enum CodingKeys: String, CodingKey {
        case sessionID = "session_id"
        case deviceName = "device_name"
        case platform
        case ipAddress = "ip_address"
        case createdAt = "created_at"
        case lastUsedAt = "last_used_at"
        case expiresAt = "expires_at"
        case isCurrent = "is_current"
    }
}

public struct AuthSessionsListResponse: Decodable {
    public let sessions: [AuthSessionResponse]
}
