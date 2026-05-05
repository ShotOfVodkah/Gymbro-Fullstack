import Foundation
import GymbroNetwork
import GymbroTypes

protocol SettingsServiceProtocol {
    func fetchState() async throws -> ProfilePrivacySettingsState
    func updateState(_ state: ProfilePrivacySettingsState) async throws -> ProfilePrivacySettingsState
}

final class SettingsService: SettingsServiceProtocol {
    
    init(client: any ProfileClientProtocol) {
        self.client = client
    }
    
    func fetchState() async throws -> ProfilePrivacySettingsState {
        let response = try await client.fetchMySettings()
        
        return ProfilePrivacySettingsState(
            pushNotificationsEnabled: response.push_notifications_enabled,
            workoutRemindersEnabled: response.workout_reminders,
            privateAccountEnabled: response.private_account,
            showActivityEnabled: response.show_activity,
            discoverVisibilityEnabled: response.discover_visibility
        )
    }
    
    func updateState(_ state: ProfilePrivacySettingsState) async throws -> ProfilePrivacySettingsState {
        let request = UpdateProfileSettingsRequest(
            push_notifications_enabled: state.pushNotificationsEnabled,
            workout_reminders: state.workoutRemindersEnabled,
            private_account: state.privateAccountEnabled,
            show_activity: state.showActivityEnabled,
            discover_visibility: state.discoverVisibilityEnabled
        )
        
        let response = try await client.updateMySettings(request)
        
        return ProfilePrivacySettingsState(
            pushNotificationsEnabled: response.push_notifications_enabled,
            workoutRemindersEnabled: response.workout_reminders,
            privateAccountEnabled: response.private_account,
            showActivityEnabled: response.show_activity,
            discoverVisibilityEnabled: response.discover_visibility
        )
    }
    
    private let client: any ProfileClientProtocol
}
