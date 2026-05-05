import Foundation

@MainActor
final class ProfileOnboardingGate: ObservableObject {

    private let defaults: UserDefaults
    private let keyPrefix = "profileOnboardingCompleted."

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }

    func isCompleted(for userId: String) -> Bool {
        defaults.bool(forKey: keyPrefix + userId)
    }

    func markCompleted(for userId: String) {
        defaults.set(true, forKey: keyPrefix + userId)
        objectWillChange.send()
    }
}
