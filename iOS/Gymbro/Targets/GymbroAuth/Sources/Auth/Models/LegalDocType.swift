import Foundation

enum LegalDocType {
    case terms
    case privacy

    var title: String {
        switch self {
        case .terms: return String(localized: "legal.title.terms", bundle: .module)
        case .privacy: return String(localized: "legal.title.privacy", bundle: .module)
        }
    }
}
