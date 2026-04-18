import Foundation

public struct ProfilePrivacySettingsState: Equatable, Hashable {
    public var pushNotificationsEnabled: Bool
    public var workoutRemindersEnabled: Bool
    public var privateAccountEnabled: Bool
    public var showActivityEnabled: Bool
    public var discoverVisibilityEnabled: Bool
    
    public init(
        pushNotificationsEnabled: Bool,
        workoutRemindersEnabled: Bool,
        privateAccountEnabled: Bool,
        showActivityEnabled: Bool,
        discoverVisibilityEnabled: Bool
    ) {
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.workoutRemindersEnabled = workoutRemindersEnabled
        self.privateAccountEnabled = privateAccountEnabled
        self.showActivityEnabled = showActivityEnabled
        self.discoverVisibilityEnabled = discoverVisibilityEnabled
    }
}
