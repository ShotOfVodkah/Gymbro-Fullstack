import Foundation

public extension EditProfileForm {
    func validateProfileForm() -> [EditProfileValidationError] {
        var errors: [EditProfileValidationError] = []

        if fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
        }

        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername.count < 3 {
            errors.append(.usernameTooShort)
        }

        let usernameRegex = "^[A-Za-z0-9._]+$"
        if trimmedUsername.range(of: usernameRegex, options: .regularExpression) == nil {
            errors.append(.usernameInvalid)
        }

        if status.count > 60 {
            errors.append(.statusTooLong)
        }

        if subtitle.count > 80 {
            errors.append(.subtitleTooLong)
        }

        if bio.count > 220 {
            errors.append(.bioTooLong)
        }

        return errors
    }
}
