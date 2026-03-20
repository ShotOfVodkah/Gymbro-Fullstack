enum LegalDocType {
    case terms
    case privacy

    var title: String {
        switch self {
        case .terms: return "Terms of Service"
        case .privacy: return "Privacy Policy"
        }
    }
}
