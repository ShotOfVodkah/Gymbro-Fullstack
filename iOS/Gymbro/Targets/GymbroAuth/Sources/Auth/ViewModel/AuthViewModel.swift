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
    
    @Published var shouldShowCheckEmailScreen: Bool = false
    @Published var registeredEmail: String?
    @Published var devVerifyURL: String?
    @Published var isEmailVerificationInProgress: Bool = false
    
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
                    try await register(email: trimmedEmail, password: password, role: role.rawValue)
                }
            } catch {
                handleAuthError(error, email: trimmedEmail)
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
    
    private func register(email: String, password: String, role: String) async throws {
        let user = try await AppMicroservices.auth.register(
            email: email,
            password: password,
            role: role
        )

        print("created user =", user.email)
        print("dev verify url =", user.devVerifyURL ?? "nil")

        registeredEmail = user.email
        devVerifyURL = user.devVerifyURL
        shouldShowCheckEmailScreen = true

        analytics.track(.userRegistered)
    }
    
    func resendVerificationEmail() {
        let targetEmail = registeredEmail ?? email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !targetEmail.isEmpty else {
            showAlert("Enter your email address first.")
            return
        }

        Task {
            do {
                let response = try await AppMicroservices.auth.resendVerificationEmail(email: targetEmail)
                showAlert(response.message)
            } catch {
                showAlert(error.localizedDescription)
            }
        }
    }
    
    func verifyEmailFromDevURL() {
        guard let devVerifyURL else {
            showAlert("Verification link is not available.")
            return
        }

        verifyEmail(from: devVerifyURL)
    }
    
    func verifyEmail(from urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert("Invalid verification link.")
            return
        }

        verifyEmail(from: url)
    }
    
    func verifyEmail(from url: URL) {
        guard let token = Self.extractVerificationToken(from: url) else {
            showAlert("Verification token was not found.")
            return
        }

        Task {
            await verifyEmail(token: token)
        }
    }
    
    func backToLoginAfterRegistration() {
        shouldShowCheckEmailScreen = false
        tab = .login
        password = ""
    }

    private func verifyEmail(token: String) async {
        isEmailVerificationInProgress = true
        defer { isEmailVerificationInProgress = false }

        do {
            let tokens = try await AppMicroservices.auth.verifyEmail(token: token)

            SessionManager.shared.setSession(tokens: tokens)

            shouldShowCheckEmailScreen = false
            password = ""
        } catch {
            showAlert(error.localizedDescription)
        }
    }
    
    private func handleAuthError(_ error: Error, email: String) {
        let message = error.localizedDescription

        if message.lowercased().contains("email is not verified")
            || message.lowercased().contains("403") {
            registeredEmail = email
            showUnverifiedEmailAlert()
            return
        }

        showAlert(message)
    }
    
    private func showUnverifiedEmailAlert() {
        alertData = CustomAlertData(
            message: "Please confirm your email before signing in. You can request a new verification email.",
            primaryButton: AppButton("Resend verification email", size: .l) { [weak self] in
                self?.isAlertPresented = false
                self?.resendVerificationEmail()
            }
        )
        isAlertPresented = true
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
    
    private static func extractVerificationToken(from url: URL) -> String? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let token = components?
            .queryItems?
            .first(where: { $0.name == "token" })?
            .value

        guard let token, !token.isEmpty else {
            return nil
        }

        if url.scheme == "gymbro", url.host == "verify-email" {
            return token
        }

        if url.scheme == "https", url.path == "/auth/verify-email-link" {
            return token
        }

        return nil
    }
}
