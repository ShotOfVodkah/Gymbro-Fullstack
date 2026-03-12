import SwiftUI
import GymbroCommonUI

@MainActor
final class AuthViewModel: ObservableObject {

    @Published var tab: AuthTab = .login
    @Published var role: UserRole = .athlete
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isPasswordHidden: Bool = true

    @Published var legalSheetType: LegalDocType = .terms
    @Published var isLegalSheetPresented: Bool = false
    let consent = LegalConsentStore()

    @Published var isAlertPresented: Bool = false
    @Published var alertData: CustomAlertData = .init()

    func openLegal(_ type: LegalDocType) {
        legalSheetType = type
        isLegalSheetPresented = true
    }

    func acceptCurrentLegal() {
        consent.accept(legalSheetType)
    }

    func submit() {
        guard consent.allAccepted else {
            showAlert("Please read and accept Terms of Service and Privacy Policy to continue.")
            return
        }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard validateEmail(trimmedEmail) else {
            showAlert("Enter a valid email address.")
            return
        }

        if let error = validatePassword(password) {
            showAlert(error)
            return
        }

        // TODO: AuthService login/register
    }

    private func showAlert(_ message: String) {
        alertData = CustomAlertData(
            message: message,
            primaryButton: AppButton("OK", size: .m) { [weak self] in
                self?.isAlertPresented = false
            }
        )
        isAlertPresented = true
    }
}
