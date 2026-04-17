import Foundation

enum AuthTab: String, CaseIterable {
    case login
    case register

    var localizedTitle: String {
        switch self {
        case .login:
            return String(localized: "auth.tab.login", bundle: .module)
        case .register:
            return String(localized: "auth.tab.register", bundle: .module)
        }
    }
}
