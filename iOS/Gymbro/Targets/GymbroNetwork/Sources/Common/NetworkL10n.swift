import Foundation

enum NetworkL10n {
    static func serverError(code: Int) -> String {
        let fmt = String(localized: "network.error.server", bundle: .module)
        return String(format: fmt, locale: .current, code)
    }
}
