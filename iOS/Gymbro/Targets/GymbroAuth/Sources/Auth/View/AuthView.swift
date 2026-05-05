import SwiftUI
import GymbroCommonUI
import GymbroTypes


public struct AuthView: View {
    @StateObject private var vm: AuthViewModel

    public init(analytics: any AnalyticsService) {
        _vm = StateObject(wrappedValue: AuthViewModel(analytics: analytics))
    }
    
    public var body: some View {
        ZStack {
            BlurredBackground()
            VStack(spacing: 18) {
                header
                if vm.shouldShowCheckEmailScreen {
                    CheckEmailView(
                        email: vm.registeredEmail ?? vm.email,
                        devVerifyURL: vm.devVerifyURL,
                        isVerificationInProgress: vm.isEmailVerificationInProgress,
                        onResend: vm.resendVerificationEmail,
                        onBackToLogin: vm.backToLoginAfterRegistration,
                        onVerifyDevLink: vm.verifyEmailFromDevURL
                    )
                    .padding(.top, 10)
                } else {
                    authCard.padding(.top, 10)
                    legalText.padding(.top, 10)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
        .customAlert(isPresented: $vm.isAlertPresented, data: vm.alertData)
        .sheet(isPresented: $vm.isLegalSheetPresented) {
            LegalDocScreen(
                type: vm.legalSheetType,
                mode: .acceptance(isAlreadyAccepted: vm.consent.isAccepted(vm.legalSheetType),
                                  onAccept: vm.acceptCurrentLegal))
            .preferredColorScheme(.dark)
        }
        .onOpenURL { url in
            vm.verifyEmail(from: url)
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
            
            Text(String(localized: "auth.brand", bundle: .module))
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
            
            Text(String(localized: "auth.tagline", bundle: .module))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
        }
        .padding(.top, 6)
    }
    
    private var authCard: some View {
        VStack(spacing: 18) {
            SegmentedPill(tab: $vm.tab)
            
            if vm.tab == .register {
                rolePicker
            }
            
            VStack(spacing: 14) {
                IconEmailField(
                    title: String(localized: "auth.field.email", bundle: .module),
                    systemImage: "envelope",
                    text: $vm.email
                )
                IconSecureField(
                    title: String(localized: "auth.field.password", bundle: .module),
                    systemImage: "lock",
                    text: $vm.password,
                    isHidden: $vm.isPasswordHidden
                )
            }
            
            Button {
                vm.submit()
            } label: {
                HStack(spacing: 10) {
                    Text(vm.tab == .login ? String(localized: "auth.action.login", bundle: .module) : String(localized: "auth.action.create_account", bundle: .module))
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
            Text(vm.consent.allAccepted ? String(localized: "auth.legal.all_set", bundle: .module) : String(localized: "auth.legal.prefix", bundle: .module))
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.35))
            
            HStack(spacing: 6) {
                Button {
                    vm.openLegal(.terms)
                } label: {
                    Text(String(localized: "auth.legal.terms", bundle: .module))
                        .foregroundStyle(vm.consent.termsAccepted ? .white.opacity(0.35) : .white.opacity(0.6))
                        .underline()
                }
                
                Text(String(localized: "auth.legal.and", bundle: .module))
                    .foregroundStyle(.white.opacity(0.35))
                
                Button {
                    vm.openLegal(.privacy)
                } label: {
                    Text(String(localized: "auth.legal.privacy", bundle: .module))
                        .foregroundStyle(vm.consent.privacyAccepted ? .white.opacity(0.35) : .white.opacity(0.6))
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
            Text(String(localized: "auth.role.who", bundle: .module))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            
            HStack(spacing: 14) {
                RoleCard(
                    title: String(localized: "auth.role.athlete", bundle: .module),
                    systemImage: "figure.run",
                    selected: vm.role == .athlete
                )
                .onTapGesture { vm.role = .athlete }
                
                RoleCard(
                    title: String(localized: "auth.role.coach", bundle: .module),
                    systemImage: "person.3.fill",
                    selected: vm.role == .coach
                )
                .onTapGesture { vm.role = .coach }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
