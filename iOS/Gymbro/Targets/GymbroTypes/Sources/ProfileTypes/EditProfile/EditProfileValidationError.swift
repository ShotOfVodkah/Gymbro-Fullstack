import Foundation

public enum EditProfileValidationError: Equatable {
    case emptyName
    case usernameTooShort
    case usernameInvalid
    case statusTooLong
    case subtitleTooLong
    case bioTooLong
    
    public var message: String {
        switch self {
        case .emptyName:
            return "Name cannot be empty."
        case .usernameTooShort:
            return "Username is too short."
        case .usernameInvalid:
            return "Username can contain only letters, numbers, underscores and dots."
        case .statusTooLong:
            return "Status is too long."
        case .subtitleTooLong:
            return "Subtitle is too long."
        case .bioTooLong:
            return "Bio is too long."
        }
    }
}
