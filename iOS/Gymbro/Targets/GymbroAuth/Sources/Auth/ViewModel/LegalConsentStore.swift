import SwiftUI

final class LegalConsentStore: ObservableObject {
    @AppStorage("termsAccepted_v1") var termsAccepted: Bool = false
    @AppStorage("privacyAccepted_v1") var privacyAccepted: Bool = false

    var allAccepted: Bool { termsAccepted && privacyAccepted }

    func isAccepted(_ type: LegalDocType) -> Bool {
        switch type {
        case .terms: return termsAccepted
        case .privacy: return privacyAccepted
        }
    }

    func accept(_ type: LegalDocType) {
        switch type {
        case .terms: termsAccepted = true
        case .privacy: privacyAccepted = true
        }
    }
}
