import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct ProfileOnboardingView: View {

    init(viewModel: ProfileOnboardingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            onboardingMeshBackground

            Group {
                switch viewModel.screenState {
                case .loading:
                    loadingView

                case .loaded:
                    loadedScrollContent

                case .error:
                    errorView
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 18) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.25)
            Text(String(localized: "profile.loading", bundle: .module))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white.opacity(0.95), Color.appPurple.opacity(0.9)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(String(localized: "profile.onboarding.load_error", bundle: .module))
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)

            AppButton(String(localized: "profile.onboarding.retry", bundle: .module), size: .xl) {
                viewModel.reload()
            }
        }
        .padding(.horizontal, 36)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var loadedScrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                welcomeHeader

                onboardingAccentCard {
                    EditProfileAvatarSection(
                        avatarSystemName: viewModel.form.avatarSystemName
                    )
                }

                onboardingAccentCard {
                    ProfileSectionContainer(title: String(localized: "profile.onboarding.section_basic", bundle: .module)) {
                        VStack(spacing: 14) {
                            EditProfileTextField(
                                title: String(localized: "profile.onboarding.field_full_name", bundle: .module),
                                text: Binding(
                                    get: { viewModel.form.fullName },
                                    set: viewModel.updateName
                                ),
                                autocapitalization: .words,
                                disableAutocorrection: true,
                                accessibilityIdentifier: "profile.onboarding.field.fullName"
                            )

                            EditProfileTextField(
                                title: String(localized: "profile.onboarding.field_username", bundle: .module),
                                text: Binding(
                                    get: { viewModel.form.username },
                                    set: viewModel.updateUsername
                                ), accessibilityIdentifier: "profile.onboarding.field.userName"
                            )

                            EditProfileTextField(
                                title: String(localized: "profile.onboarding.field_status", bundle: .module),
                                text: Binding(
                                    get: { viewModel.form.status },
                                    set: viewModel.updateStatus
                                ),
                                autocapitalization: .sentences,
                                disableAutocorrection: true,
                                accessibilityIdentifier: "profile.onboarding.field.status"
                            )

                            EditProfileTextField(
                                title: String(localized: "profile.onboarding.field_subtitle", bundle: .module),
                                text: Binding(
                                    get: { viewModel.form.subtitle },
                                    set: viewModel.updateSubtitle
                                ),
                                autocapitalization: .sentences,
                                disableAutocorrection: true,
                                accessibilityIdentifier: "profile.onboarding.field.subtitle"
                            )
                        }
                    }
                }

                onboardingAccentCard {
                    ProfileSectionContainer(title: String(localized: "profile.onboarding.section_about", bundle: .module)) {
                        EditProfileBioEditor(
                            text: Binding(
                                get: { viewModel.form.bio },
                                set: viewModel.updateBio
                            ),
                            limit: 220
                        )
                    }
                }

                if !viewModel.validationErrors.isEmpty {
                    EditProfileValidationView(
                        messages: viewModel.validationErrors.map(\.message)
                    )
                }

                Color.clear.frame(height: 28)
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            completionChrome
        }
    }

    private var welcomeHeader: some View {
        VStack(spacing: 18) {
            Text(String(localized: "profile.onboarding.welcome_kicker", bundle: .module))
                .font(.subheadline.weight(.semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.yogaColor.opacity(0.95),
                            Color.appPurple,
                            Color.cardioColor.opacity(0.95)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(String(localized: "profile.onboarding.welcome_title", bundle: .module))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.88)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: Color.appPurple.opacity(0.35), radius: 16, y: 6)

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [.strengthColor, .cardioColor, .yogaColor],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 5)
                .frame(maxWidth: 200)
                .shadow(color: .strengthColor.opacity(0.45), radius: 10, y: 0)
                .shadow(color: .cardioColor.opacity(0.35), radius: 12, y: 2)

            Text(String(localized: "profile.onboarding.subtitle", bundle: .module))
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 4)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func onboardingAccentCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.22),
                                Color.appPurple.opacity(0.35),
                                Color.cardioColor.opacity(0.25),
                                Color.white.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.35), radius: 18, y: 10)
    }

    private var completionChrome: some View {
        VStack(spacing: 0) {

            VStack(spacing: 0) {
                completionButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 6)
            .padding(.bottom, 10)
        }
    }

    private var completionButton: some View {
        Button {
            viewModel.didTapContinue()
        } label: {
            HStack(spacing: 12) {
                Text(
                    viewModel.isSaving
                        ? String(localized: "profile.onboarding.saving", bundle: .module)
                        : String(localized: "profile.onboarding.continue", bundle: .module)
                )
                .font(.system(size: 18, weight: .semibold, design: .rounded))

                if !viewModel.isSaving {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [
                        Color.appPurple,
                        Color.cardioColor.opacity(0.92),
                        Color.strengthColor.opacity(0.88),
                        Color.appPurple.opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.65),
                                .white.opacity(0.12),
                                .white.opacity(0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.22), .clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .blendMode(.screen)
            )
            .shadow(color: Color.appPurple.opacity(0.5), radius: 20, y: 12)
            .shadow(color: Color.cardioColor.opacity(0.35), radius: 28, y: 16)
        }
        .buttonStyle(PressScaleButtonStyle())
        .disabled(!viewModel.canContinue)
        .opacity(viewModel.canContinue ? 1 : 0.42)
        .animation(.easeInOut(duration: 0.2), value: viewModel.canContinue)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSaving)
    }

    private var onboardingMeshBackground: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Color(red: 6 / 255, green: 8 / 255, blue: 20 / 255), location: 0),
                    .init(color: Color.appDarkGray, location: 0.38),
                    .init(color: Color(red: 4 / 255, green: 6 / 255, blue: 14 / 255), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.appPurple.opacity(0.42),
                    Color.appPurple.opacity(0.12),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    Color.cardioColor.opacity(0.28),
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 360
            )

            RadialGradient(
                colors: [
                    Color.strengthColor.opacity(0.22),
                    Color.clear
                ],
                center: UnitPoint(x: 0.15, y: 0.55),
                startRadius: 10,
                endRadius: 280
            )

            RadialGradient(
                colors: [
                    Color.yogaColor.opacity(0.12),
                    Color.clear
                ],
                center: UnitPoint(x: 0.85, y: 0.72),
                startRadius: 10,
                endRadius: 220
            )
        }
        .ignoresSafeArea()
    }

    @ObservedObject private var viewModel: ProfileOnboardingViewModel
}

private struct WorkoutTypeOnboardingChip: View {
    let systemImage: String
    let label: String
    let primary: Color
    let secondary: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [primary.opacity(0.55), primary.opacity(0.18)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.45), secondary.opacity(0.5), .white.opacity(0.12)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: primary.opacity(0.4), radius: 10, y: 4)

                Image(systemName: systemImage)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            }

            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}
