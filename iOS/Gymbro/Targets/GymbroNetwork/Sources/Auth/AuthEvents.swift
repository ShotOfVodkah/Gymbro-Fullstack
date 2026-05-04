import Foundation

public enum AuthEvents {
    public static var onSessionExpired: (@MainActor () -> Void)?
    public static var onSessionCleared: (@MainActor () -> Void)?
}
