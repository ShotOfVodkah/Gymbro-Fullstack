import Foundation
import GymbroTypes

@MainActor
final class ProfileOnboardingViewModel: ObservableObject {

    enum ScreenState: Equatable {
        case loading
        case loaded
        case error
    }

    @Published var screenState: ScreenState = .loading
    @Published var form = EditProfileForm(
        fullName: "",
        username: "",
        status: "",
        subtitle: "",
        bio: "",
        avatarSystemName: "person.crop.circle.fill"
    )
    @Published var validationErrors: [EditProfileValidationError] = []
    @Published var isSaving: Bool = false

    private let service: any EditProfileService
    private let analytics: any AnalyticsService
    private let onCompleted: () -> Void

    var canContinue: Bool {
        !isSaving && form.validateProfileForm().isEmpty
    }

    init(
        service: any EditProfileService,
        analytics: any AnalyticsService,
        onCompleted: @escaping () -> Void
    ) {
        self.service = service
        self.analytics = analytics
        self.onCompleted = onCompleted
        analytics.track(.screenViewed(screen: .profileOnboarding))
        Task { await loadProfile() }
    }

    func reload() {
        Task {
            analytics.track(.errorRetryTapped(screen: AnalyticsScreen.profileOnboarding.rawValue))
            await loadProfile()
        }
    }

    func updateName(_ value: String) {
        form.fullName = value
        validationErrors = []
    }

    func updateUsername(_ value: String) {
        form.username = value
        validationErrors = []
    }

    func updateStatus(_ value: String) {
        form.status = value
        validationErrors = []
    }

    func updateSubtitle(_ value: String) {
        form.subtitle = value
        validationErrors = []
    }

    func updateBio(_ value: String) {
        form.bio = value
        validationErrors = []
    }

    func updateAvatarSystemName(_ value: String) {
        form.avatarSystemName = value
    }

    func didTapContinue() {
        let errors = form.validateProfileForm()
        validationErrors = errors
        guard errors.isEmpty else { return }

        isSaving = true
        Task {
            do {
                _ = try await service.saveProfile(form)
                analytics.track(.profileOnboardingCompleted)
                isSaving = false
                onCompleted()
            } catch {
                isSaving = false
                screenState = .error
                analytics.track(
                    .errorOccurred(
                        screen: AnalyticsScreen.profileOnboarding.rawValue,
                        message: error.localizedDescription
                    )
                )
            }
        }
    }

    private func loadProfile() async {
        screenState = .loading
        do {
            let profile = try await service.fetchProfile()
            form = EditProfileForm(
                fullName: profile.fullName,
                username: profile.username,
                status: profile.status,
                subtitle: profile.subtitle,
                bio: profile.bio,
                avatarSystemName: profile.avatarSystemName
            )
            screenState = .loaded
        } catch {
            screenState = .error
            analytics.track(
                .errorOccurred(
                    screen: AnalyticsScreen.profileOnboarding.rawValue,
                    message: error.localizedDescription
                )
            )
        }
    }
}
