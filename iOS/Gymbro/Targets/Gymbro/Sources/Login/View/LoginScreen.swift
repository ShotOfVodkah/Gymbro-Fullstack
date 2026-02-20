import SwiftUI
import GymbroCommonUI


struct AuthScreen: View {
    @State private var tab: AuthTab = .login
    @State private var role: UserRole = .athlete
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordHidden: Bool = true
    
    @State private var isAlertPresented = false
    @State private var alertData = CustomAlertData()
    
    @State private var isLegalSheetPresented = false
    @State private var legalSheetType: LegalDocType = .terms
    @AppStorage("termsAccepted_v1") private var termsAccepted: Bool = false
    @AppStorage("privacyAccepted_v1") private var privacyAccepted: Bool = false
    
    var body: some View {
        ZStack {
            BlurredBackground()
            VStack(spacing: 18) {
                header
                authCard.padding(.top, 10)
                legalText.padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
        .customAlert(isPresented: $isAlertPresented, data: alertData)
        .sheet(isPresented: $isLegalSheetPresented) {
            LegalDocScreen(type: legalSheetType, isAlreadyAccepted: legalSheetType == .terms ? termsAccepted : privacyAccepted) {
                if legalSheetType == .terms {
                    termsAccepted = true
                } else {
                    privacyAccepted = true
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    private var header: some View {
        VStack(spacing: 6) {
            ZStack { // поменять на иконку приложения
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color.appPurple, Color.purple.opacity(0.6)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 68, height: 68)
                    .shadow(radius: 18)
                
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text("GymBro")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Your own path to perfection")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.top, 6)
    }
    
    private var authCard: some View {
        VStack(spacing: 18) {
            SegmentedPill(tab: $tab)
            
            if tab == .register {
                rolePicker
            }
            
            VStack(spacing: 14) {
                IconEmailField(
                    title: "Email",
                    systemImage: "envelope",
                    text: $email
                )
                IconSecureField(
                    title: "Password",
                    systemImage: "lock",
                    text: $password,
                    isHidden: $isPasswordHidden
                )
            }
            
            Button {
                guard termsAccepted && privacyAccepted else {
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
                
                // TODO: дернуть AuthService
            } label: {
                HStack(spacing: 10) {
                    Text(tab == .login ? "Log in" : "Create an account")
                        .font(.system(size: 18, weight: .semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [Color.appPurple.opacity(0.9), Color.purple],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
                .shadow(radius: 18)
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 15)
        .padding(.top, 10)
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.white.opacity(0.1), lineWidth: 2)
                )
        )
    }
    
    private var legalText: some View {
        VStack(spacing: 6) {
            Text((termsAccepted && privacyAccepted) ? "You're all set legally." : "By continuing, you agree to GymBro's")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.35))
            
            HStack(spacing: 6) {
                Button {
                    legalSheetType = .terms
                    isLegalSheetPresented = true
                } label: {
                    Text("Terms of Service")
                        .foregroundStyle(termsAccepted ? .white.opacity(0.35) : .white.opacity(0.6))
                        .underline()
                }
                
                Text("and")
                    .foregroundStyle(.white.opacity(0.35))
                
                Button {
                    legalSheetType = .privacy
                    isLegalSheetPresented = true
                } label: {
                    Text("Privacy Policy")
                        .foregroundStyle(privacyAccepted ? .white.opacity(0.35) : .white.opacity(0.6))
                        .underline()
                }
            }
            .font(.system(size: 14, weight: .semibold))
        }
        .multilineTextAlignment(.center)
        .buttonStyle(.plain)
    }
    
    private var rolePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Who are you?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            
            HStack(spacing: 14) {
                RoleCard(
                    title: "Athlete",
                    systemImage: "figure.run",
                    selected: role == .athlete
                )
                .onTapGesture { role = .athlete }
                
                RoleCard(
                    title: "Coach",
                    systemImage: "person.3.fill",
                    selected: role == .coach
                )
                .onTapGesture { role = .coach }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func showAlert(_ message: String) {
        alertData = CustomAlertData(
            message: message,
            primaryButton: AppButton("OK", size: .m) {
                isAlertPresented = false
            }
        )
        isAlertPresented = true
    }
}
