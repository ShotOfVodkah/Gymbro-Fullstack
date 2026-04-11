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
                authCard.padding(.top, 10)
                legalText.padding(.top, 10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
        .customAlert(isPresented: $vm.isAlertPresented, data: vm.alertData)
        .sheet(isPresented: $vm.isLegalSheetPresented) {
            LegalDocScreen(type: vm.legalSheetType, isAlreadyAccepted: vm.consent.isAccepted(vm.legalSheetType)) {
                vm.acceptCurrentLegal()
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
            SegmentedPill(tab: $vm.tab)
            
            if vm.tab == .register {
                rolePicker
            }
            
            VStack(spacing: 14) {
                IconEmailField(
                    title: "Email",
                    systemImage: "envelope",
                    text: $vm.email
                )
                IconSecureField(
                    title: "Password",
                    systemImage: "lock",
                    text: $vm.password,
                    isHidden: $vm.isPasswordHidden
                )
            }
            
            Button {
                vm.submit()
            } label: {
                HStack(spacing: 10) {
                    Text(vm.tab == .login ? "Log in" : "Create an account")
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
            Text(vm.consent.allAccepted ? "You're all set legally." : "By continuing, you agree to GymBro's")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.35))
            
            HStack(spacing: 6) {
                Button {
                    vm.openLegal(.terms)
                } label: {
                    Text("Terms of Service")
                        .foregroundStyle(vm.consent.termsAccepted ? .white.opacity(0.35) : .white.opacity(0.6))
                        .underline()
                }
                
                Text("and")
                    .foregroundStyle(.white.opacity(0.35))
                
                Button {
                    vm.openLegal(.privacy)
                } label: {
                    Text("Privacy Policy")
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
            Text("Who are you?")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
            
            HStack(spacing: 14) {
                RoleCard(
                    title: "Athlete",
                    systemImage: "figure.run",
                    selected: vm.role == .athlete
                )
                .onTapGesture { vm.role = .athlete }
                
                RoleCard(
                    title: "Coach",
                    systemImage: "person.3.fill",
                    selected: vm.role == .coach
                )
                .onTapGesture { vm.role = .coach }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
