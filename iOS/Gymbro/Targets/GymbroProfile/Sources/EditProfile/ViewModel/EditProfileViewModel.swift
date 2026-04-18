import Foundation
import GymbroNavigation
import GymbroTypes

@MainActor
final class EditProfileViewModel: ObservableObject {
    
    enum ScreenState: Equatable {
        case loading
        case loaded
        case error
    }
    
    @Published var screenState: ScreenState = .loading
    
    @Published var form: EditProfileForm = .init(
        fullName: "",
        username: "",
        status: "",
        subtitle: "",
        bio: "",
        avatarSystemName: "person.crop.circle.fill"
    )
    
    @Published var initialForm: EditProfileForm?
    @Published var validationErrors: [EditProfileValidationError] = []
    @Published var isSaving: Bool = false
    @Published var didSaveSuccessfully: Bool = false
    @Published var shouldShowDiscardAlert: Bool = false
    
    private let router: any Router
    private let service: any EditProfileService
    private let analytics: any AnalyticsService
    
    init(
        router: any Router,
        service: any EditProfileService,
        analytics: any AnalyticsService
    ) {
        self.router = router
        self.service = service
        self.analytics = analytics
        
        reload()
//        analytics.track(.screenViewed(screen: .profileEdit))
    }
    
    var hasUnsavedChanges: Bool {
        guard let initialForm else { return false }
        return form != initialForm
    }
    
    var canSave: Bool {
        !isSaving && validate().isEmpty && hasUnsavedChanges
    }
    
    func onAppear() {}
    
    func reload() {
        Task {
            await loadProfile()
        }
    }
    
    func updateName(_ value: String) {
        form.fullName = value
        clearValidationErrors()
    }
    
    func updateUsername(_ value: String) {
        form.username = value
        clearValidationErrors()
    }
    
    func updateStatus(_ value: String) {
        form.status = value
        clearValidationErrors()
    }
    
    func updateSubtitle(_ value: String) {
        form.subtitle = value
        clearValidationErrors()
    }
    
    func updateBio(_ value: String) {
        form.bio = value
        clearValidationErrors()
    }
    
    func updateAvatarSystemName(_ value: String) {
        form.avatarSystemName = value
    }
    
    func didTapSave() {
        let errors = validate()
        validationErrors = errors
        
        guard errors.isEmpty else { return }
        guard hasUnsavedChanges else { return }
        
        isSaving = true
        
        Task {
            do {
                let savedProfile = try await service.saveProfile(form)
                
                let savedForm = EditProfileForm(
                    fullName: savedProfile.fullName,
                    username: savedProfile.username,
                    status: savedProfile.status,
                    subtitle: savedProfile.subtitle,
                    bio: savedProfile.bio,
                    avatarSystemName: savedProfile.avatarSystemName
                )
                
                form = savedForm
                initialForm = savedForm
                validationErrors = []
                didSaveSuccessfully = true
                isSaving = false
                
                router.pop()
            } catch {
                isSaving = false
                screenState = .error
            }
        }
    }
    
    func didTapCancel() {
        if hasUnsavedChanges {
            shouldShowDiscardAlert = true
        } else {
            router.pop()
        }
    }
    
    func confirmDiscardChanges() {
        shouldShowDiscardAlert = false
        if let initialForm {
            form = initialForm
        }
        validationErrors = []
        didSaveSuccessfully = false
        router.pop()
    }
    
    func dismissDiscardAlert() {
        shouldShowDiscardAlert = false
    }
    
    func dismissSaveBanner() {
        didSaveSuccessfully = false
    }
    
    private func loadProfile() async {
        screenState = .loading
        
        do {
            let profile = try await service.fetchProfile()
            let loadedForm = EditProfileForm(
                fullName: profile.fullName,
                username: profile.username,
                status: profile.status,
                subtitle: profile.subtitle,
                bio: profile.bio,
                avatarSystemName: profile.avatarSystemName
            )
            form = loadedForm
            initialForm = loadedForm
            screenState = .loaded
        } catch {
            screenState = .error
        }
    }
    
    private func clearValidationErrors() {
        validationErrors = []
    }
    
    private func validate() -> [EditProfileValidationError] {
        var errors: [EditProfileValidationError] = []
        
        if form.fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyName)
        }
        
        let trimmedUsername = form.username.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedUsername.count < 3 {
            errors.append(.usernameTooShort)
        }
        
        let usernameRegex = "^[A-Za-z0-9._]+$"
        if trimmedUsername.range(of: usernameRegex, options: .regularExpression) == nil {
            errors.append(.usernameInvalid)
        }
        
        if form.status.count > 60 {
            errors.append(.statusTooLong)
        }
        
        if form.subtitle.count > 80 {
            errors.append(.subtitleTooLong)
        }
        
        if form.bio.count > 220 {
            errors.append(.bioTooLong)
        }
        
        return errors
    }
}
