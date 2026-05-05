import SwiftUI
import GymbroCommonUI

struct CheckEmailView: View {
    let email: String
    let devVerifyURL: String?
    let isVerificationInProgress: Bool

    let onResend: () -> Void
    let onBackToLogin: () -> Void
    let onVerifyDevLink: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.22))
                    .frame(width: 88, height: 88)

                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 8) {
                Text("Confirm your email")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Text("We sent a confirmation link to \(email). Open it to activate your GymBro account.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                Button(action: onResend) {
                    Text("Resend email")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white.opacity(0.10))
                        .clipShape(Capsule())
                }

                if devVerifyURL != nil {
                    Button(action: onVerifyDevLink) {
                        HStack(spacing: 8) {
                            if isVerificationInProgress {
                                ProgressView()
                                    .tint(.white)
                            }

                            Text(isVerificationInProgress ? "Verifying..." : "Verify using dev link")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color.appPurple.opacity(0.9), Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(isVerificationInProgress)
                }

                Button(action: onBackToLogin) {
                    Text("Back to login")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 4)
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 2)
                )
        )
    }
}
