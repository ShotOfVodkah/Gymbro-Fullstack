import SwiftUI
import GymbroCommonUI

func validateEmail(_ email: String) -> Bool {
    let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
    
    return NSPredicate(format: "SELF MATCHES %@", emailRegex)
        .evaluate(with: email)
}

func validatePassword(_ password: String) -> String? {
    if password.count < 8 {
        return "Password must be at least 8 characters."
    }
    if password.range(of: "[A-Z]", options: .regularExpression) == nil {
        return "Password must contain at least one uppercase letter."
    }
    if password.range(of: "[0-9]", options: .regularExpression) == nil {
        return "Password must contain at least one number."
    }
    return nil
}
