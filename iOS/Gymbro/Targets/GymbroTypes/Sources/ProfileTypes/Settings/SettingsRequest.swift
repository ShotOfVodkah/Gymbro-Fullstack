import Foundation

public struct UpdateProfileSettingsRequest: Encodable, Hashable {
    public let push_notifications_enabled: Bool
    public let workout_reminders: Bool
    public let private_account: Bool
    public let show_activity: Bool
    public let discover_visibility: Bool
    
    public init(
        push_notifications_enabled: Bool,
        workout_reminders: Bool,
        private_account: Bool,
        show_activity: Bool,
        discover_visibility: Bool
    ) {
        self.push_notifications_enabled = push_notifications_enabled
        self.workout_reminders = workout_reminders
        self.private_account = private_account
        self.show_activity = show_activity
        self.discover_visibility = discover_visibility
    }
}
