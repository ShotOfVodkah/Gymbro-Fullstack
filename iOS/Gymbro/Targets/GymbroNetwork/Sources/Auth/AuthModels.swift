import Foundation

public struct LoginRequest: Encodable {
    public let User: String
    public let Password: String

    public init(User: String, Password: String) {
        self.User = User
        self.Password = Password
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

    public init(id: Int, email: String, role: String) {
        self.id = id
        self.email = email
        self.role = role
    }
}
