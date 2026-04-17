import SwiftUI
import GymbroCommonUI
import GymbroNetwork
import GymbroTypes

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

    private let analytics: any AnalyticsService

    init(analytics: any AnalyticsService) {
        self.analytics = analytics
    }
    
    func openLegal(_ type: LegalDocType) {
        legalSheetType = type
        isLegalSheetPresented = true
    }
    
    func acceptCurrentLegal() {
        consent.accept(legalSheetType)
    }
    
    func submit() {
        guard consent.allAccepted else {
            showAlert(String(localized: "auth.alert.accept_legal", bundle: .module))
            return
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch tab {
        case .login:
            guard !email.isEmpty else {
                showAlert(String(localized: "auth.alert.enter_email", bundle: .module))
                return
            }
            
            guard !password.isEmpty else {
                showAlert(String(localized: "auth.alert.enter_password", bundle: .module))
                return
            }
            
        case .register:
            guard validateEmail(trimmedEmail) else {
                showAlert(String(localized: "auth.alert.invalid_email", bundle: .module))
                return
            }
            
            if let error = validatePassword(password) {
                showAlert(error)
                return
            }
        }
        
        Task {
            do {
                switch tab {
                case .login:
                    try await login(email: trimmedEmail, password: password)
                    
                case .register:
                    try await registerAndLogin(email: trimmedEmail, password: password, role: role.rawValue)
                }
            } catch {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    private func login(email: String, password: String) async throws {
        let tokens = try await AppMicroservices.auth.login(
            email: email,
            password: password
        )
        
        SessionManager.shared.setSession(tokens: tokens)
        analytics.track(.userLoggedIn)

        print("saved access =", AppMicroservices.tokens.accessToken ?? "nil")
        print("saved refresh =", AppMicroservices.tokens.refreshToken ?? "nil")
    }
    
    private func registerAndLogin(email: String, password: String, role: String) async throws {
        let user = try await AppMicroservices.auth.register(
            email: email,
            password: password,
            role: role
        )
        print("created user =", user.email)
        analytics.track(.userRegistered)

        try await login(email: email, password: password)
    }
    
    private func showAlert(_ message: String) {
        alertData = CustomAlertData(
            message: message,
            primaryButton: AppButton(String(localized: "auth.alert.ok", bundle: .module), size: .l) { [weak self] in
                self?.isAlertPresented = false
            }
        )
        isAlertPresented = true
    }
}
