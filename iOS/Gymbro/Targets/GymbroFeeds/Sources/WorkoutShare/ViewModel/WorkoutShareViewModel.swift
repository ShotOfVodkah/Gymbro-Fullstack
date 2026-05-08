import Foundation
import GymbroNavigation
import GymbroTypes
import GymbroNetwork

@MainActor
final class WorkoutShareViewModel: ObservableObject {
    @Published private(set) var input: WorkoutShareInput
    @Published private(set) var isSubmitting: Bool = false
    @Published var currentStep: WorkoutShareStep = .recipients
    @Published var draft: ShareActionDraft
    @Published var screenState: ScreenState = .loading
    @Published var showSubmitError: Bool = false
    @Published var submitErrorMessage: String = ""
    @Published var deliverySummary: WorkoutShareDeliverySummary?
    @Published var isShowingSuccessState: Bool = false

    @Published private(set) var availableChatDestinations: [ShareDestination] = []
    @Published private(set) var availableFriendDestinations: [ShareDestination] = []

    private let router: any Router
    private let service: any WorkoutShareService
    private let analytics: any AnalyticsService
    private let locationProvider = WorkoutShareLocationProvider()

    init(
        input: WorkoutShareInput,
        router: any Router,
        service: any WorkoutShareService,
        analytics: any AnalyticsService
    ) {
        self.input = input
        self.router = router
        self.service = service
        self.analytics = analytics
        self.draft = ShareActionDraft(sessionID: input.sessionID)
        
        analytics.track(.screenViewed(screen: .workoutShare))
        analytics.track(.workoutShareOpened(sessionId: input.sessionID))
        analytics.track(.workoutShareStepViewed(step: currentStepAnalyticsName))

        Task {
            await loadRecipients()
        }
    }

    // MARK: - Header / Step UI

    var title: String {
        switch currentStep {
        case .recipients:
            return "Choose recipients"
        case .details:
            return "Add details"
        case .preview:
            return "Preview"
        }
    }

    var stepTitle: String {
        title
    }

    var stepSubtitle: String {
        switch currentStep {
        case .recipients:
            return "Choose where to share your completed workout"
        case .details:
            return "Add a caption and optional location"
        case .preview:
            return "Review everything before sending"
        }
    }

    var currentStepIndex: Int {
        switch currentStep {
        case .recipients:
            return 0
        case .details:
            return 1
        case .preview:
            return 2
        }
    }

    var totalSteps: Int { 3 }

    var progressValue: Double {
        Double(currentStepIndex + 1) / Double(totalSteps)
    }

    // MARK: - Step State

    var isFirstStep: Bool {
        currentStep == .recipients
    }

    var isLastStep: Bool {
        currentStep == .preview
    }

    var canGoNext: Bool {
        switch currentStep {
        case .recipients:
            return draft.publishToFeed || !draft.destinations.isEmpty
        case .details:
            return true
        case .preview:
            return false
        }
    }

    var canSubmit: Bool {
        !isSubmitting
    }

    var backButtonTitle: String {
        isFirstStep ? "Cancel" : "Back"
    }

    var primaryButtonTitle: String {
        if isLastStep {
            return isSubmitting ? "Sharing..." : "Share"
        }
        return "Next"
    }

    var shouldDisablePrimaryButton: Bool {
        if isLastStep {
            return isSubmitting
        }
        return !canGoNext
    }
    
    private var currentStepAnalyticsName: String {
        switch currentStep {
        case .recipients:
            return "recipients"
        case .details:
            return "details"
        case .preview:
            return "preview"
        }
    }

    // MARK: - Summary Card UI

    var summaryTitle: String {
        input.workoutName
    }

    var summarySubtitle: String {
        input.workoutType.capitalized
    }

    // MARK: - Recipients UI

    var selectedDestinationsCount: Int {
        draft.destinations.count + (draft.publishToFeed ? 1 : 0)
    }

    var hasAnyRecipientsSelected: Bool {
        draft.publishToFeed || !draft.destinations.isEmpty
    }

    var previewDestinationTitles: [String] {
        var result: [String] = []

        if draft.publishToFeed {
            result.append("My Feed")
        }

        result.append(contentsOf: draft.destinations.map(destinationTitle(_:)))
        return result
    }

    func destinationTitle(_ destination: ShareDestination) -> String {
        switch destination {
        case .feed:
            return "My Feed"
        case .existingChat(_, let title, _):
            return title
        case .directUser(_, let name, _):
            return name
        case .community(_, let title):
            return title
        }
    }

    func destinationSubtitle(_ destination: ShareDestination) -> String {
        switch destination {
        case .feed:
            return "Publish workout to feed"

        case .existingChat(_, _, let kind):
            switch kind {
            case .direct:
                return "Direct chat"
            case .group:
                return "Group chat"
            }

        case .directUser(_, _, let username):
            return username.map { "@\($0)" } ?? "Friend"

        case .community:
            return "Community"
        }
    }

    func isSelected(_ destination: ShareDestination) -> Bool {
        draft.destinations.contains(destination)
    }

    func toggleDestination(_ destination: ShareDestination) {
        let wasSelected = draft.destinations.contains(destination)
        
        if let index = draft.destinations.firstIndex(of: destination) {
            draft.destinations.remove(at: index)
        } else {
            draft.destinations.append(destination)
        }
        
        analytics.track(.workoutShareDestinationToggled(
            kind: analyticsDestinationKind(destination),
            isSelected: !wasSelected,
            selectedCount: selectedDestinationsCount
        ))
    }

    func togglePublishToFeed() {
        draft.publishToFeed.toggle()
        analytics.track(.workoutShareFeedToggled(isEnabled: draft.publishToFeed))
    }

    // MARK: - Details UI

    @Published private(set) var isResolvingCurrentLocation: Bool = false
    @Published private(set) var locationSuggestions: [String] = []
    @Published private(set) var locationResolveErrorMessage: String? = nil

    func updateCaption(_ text: String) {
        let oldWasEmpty = draft.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let newWasEmpty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        draft.caption = text
        
        if oldWasEmpty != newWasEmpty {
            analytics.track(.workoutShareCaptionEdited(length: text.count))
        }
    }

    func updateLocation(_ text: String) {
        let oldWasFilled = !(draft.location?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        let newValue = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : text
        let newWasFilled = !(newValue?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        draft.location = newValue
        if newValue == nil {
            locationSuggestions = []
        }
        
        if oldWasFilled != newWasFilled {
            analytics.track(.workoutShareLocationEdited(isFilled: newWasFilled))
        }
    }

    func fetchCurrentLocationSuggestions() async {
        guard !isResolvingCurrentLocation else { return }
        isResolvingCurrentLocation = true
        locationResolveErrorMessage = nil

        do {
            let suggestions = try await locationProvider.requestSuggestedLocations()
            locationSuggestions = suggestions
        } catch let error as WorkoutShareLocationError {
            switch error {
            case .permissionDenied:
                locationResolveErrorMessage = "Location permission is denied. Enable it in Settings to use current location."
            case .unableToDetermineLocation:
                locationResolveErrorMessage = "Couldn’t determine your location. Try again."
            }
        } catch {
            locationResolveErrorMessage = error.localizedDescription
        }

        isResolvingCurrentLocation = false
    }

    func selectLocationSuggestion(_ value: String) {
        updateLocation(value)
    }

    var locationText: String {
        draft.location ?? ""
    }

    var previewCaptionText: String {
        draft.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "No caption"
            : draft.caption
    }

    var previewLocationText: String? {
        guard let location = draft.location,
              !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return nil }

        return location
    }

    // MARK: - Navigation

    func back() {
        analytics.track(.workoutShareStepBackTapped(step: currentStepAnalyticsName))
        if isFirstStep {
            analytics.track(.workoutShareClosed(step: currentStepAnalyticsName, selectedDestinationsCount: selectedDestinationsCount))
            router.popToRoot()
        } else {
            goBack()
        }
    }
    
    func goNext() {
        analytics.track(.workoutShareStepNextTapped(step: currentStepAnalyticsName))
        
        switch currentStep {
        case .recipients:
            guard canGoNext else { return }
            currentStep = .details

        case .details:
            currentStep = .preview

        case .preview:
            break
        }
        
        analytics.track(.workoutShareStepViewed(step: currentStepAnalyticsName))
    }

    func goBack() {
        switch currentStep {
        case .recipients:
            break
        case .details:
            currentStep = .recipients
        case .preview:
            currentStep = .details
        }
        
        analytics.track(.workoutShareStepViewed(step: currentStepAnalyticsName))
    }

    func handlePrimaryAction() {
        if isLastStep {
            submitShare()
        } else {
            goNext()
        }
    }
    
    func finishSuccessFlow() {
        analytics.track(.workoutShareDoneTapped)
        router.popToRoot()
    }

    func reload() {
        Task {
            await loadRecipients()
        }
    }
    
    private func analyticsDestinationKind(_ destination: ShareDestination) -> String {
        switch destination {
        case .feed:
            return "feed"
        case .existingChat(_, _, let kind):
            switch kind {
            case .direct:
                return "existing_direct_chat"
            case .group:
                return "existing_group_chat"
            }
        case .directUser:
            return "direct_user"
        case .community:
            return "community"
        }
    }

    // MARK: - Submit

    func resolveTargets() -> ResolvedShareTargets {
        var existingChatIDs: [String] = []
        var directUserIDs: [String] = []

        for destination in draft.destinations {
            switch destination {
            case .feed:
                break

            case .existingChat(let id, _, _):
                existingChatIDs.append(id)

            case .directUser(let id, _, _):
                directUserIDs.append(id)

            case .community:
                break
            }
        }

        return ResolvedShareTargets(
            publishToFeed: draft.publishToFeed,
            existingChatIDs: existingChatIDs,
            directUserIDs: directUserIDs
        )
    }

    func submitShare() {
        guard !isSubmitting else { return }

        let targets = resolveTargets()
        isSubmitting = true
        
        analytics.track(.workoutShareSubmitTapped(
            publishToFeed: targets.publishToFeed,
            existingChatsCount: targets.existingChatIDs.count,
            directUsersCount: targets.directUserIDs.count,
            hasCaption: !draft.caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            hasLocation: draft.location != nil
        ))

        Task {
            do {
                let response = try await service.submitShare(
                    sessionID: input.sessionID,
                    targets: targets,
                    caption: draft.caption,
                    location: draft.location
                )
                
                analytics.track(.workoutShareSubmitSucceeded(
                    createdPost: response.created_post_id != nil,
                    deliveredChatsCount: response.delivered_chat_ids.count,
                    createdChatsCount: response.created_chat_ids.count
                ))

                analytics.track(.workoutShareSuccessViewed(
                    createdPost: response.created_post_id != nil,
                    deliveredChatsCount: response.delivered_chat_ids.count,
                    createdChatsCount: response.created_chat_ids.count
                ))

                isSubmitting = false
                deliverySummary = WorkoutShareDeliverySummary(response: response)
                isShowingSuccessState = true

            } catch {
                isSubmitting = false
                submitErrorMessage = error.localizedDescription
                showSubmitError = true
                analytics.track(.workoutShareSubmitFailed(message: error.localizedDescription))
            }
        }
    }

    // MARK: - Loading State

    private func loadRecipients() async {
        screenState = .loading

        do {
            let data = try await service.fetchRecipientDestinations()
            availableChatDestinations = data.chats
            availableFriendDestinations = data.friends
            screenState = .loaded
        } catch let error as NetworkError {
            availableChatDestinations = []
            availableFriendDestinations = []

            switch error {
            case .noInternet, .hostNotFound:
                screenState = .offline
            default:
                screenState = .error
            }
        } catch {
            availableChatDestinations = []
            availableFriendDestinations = []
            screenState = .error
        }
    }
}
