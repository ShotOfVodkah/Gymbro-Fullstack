import Foundation

@MainActor
final class ProfileOnboardingGate: ObservableObject {

    private let defaults: UserDefaults
    private static let keyPrefix = "profileOnboardingCompleted."

    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults
    }

    static func userDefaultsKey(for userId: String) -> String {
        keyPrefix + userId
    }

    func isCompleted(for userId: String) -> Bool {
        defaults.bool(forKey: Self.userDefaultsKey(for: userId))
    }

    func markCompleted(for userId: String) {
        defaults.set(true, forKey: Self.userDefaultsKey(for: userId))
        objectWillChange.send()
    }
}
