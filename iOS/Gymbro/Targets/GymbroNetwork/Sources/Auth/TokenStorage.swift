import Foundation
import Security

public protocol TokenStorage: AnyObject {
    var accessToken: String? { get set }
    var refreshToken: String? { get set }
    var userId: String? { get set }
    func clear()
}

public final class KeychainTokenStorage: TokenStorage {
    private enum Key {
        static let accessToken = "gymbro.accessToken"
        static let refreshToken = "gymbro.refreshToken"
        static let userId = "gymbro.userId"
    }

    private let service = "com.gymbro.auth"

    public init() {}

    public var accessToken: String? {
        get { read(for: Key.accessToken) }
        set {
            if let newValue {
                save(newValue, for: Key.accessToken)
            } else {
                delete(for: Key.accessToken)
            }
        }
    }

    public var refreshToken: String? {
        get { read(for: Key.refreshToken) }
        set {
            if let newValue {
                save(newValue, for: Key.refreshToken)
            } else {
                delete(for: Key.refreshToken)
            }
        }
    }

    public func clear() {
        delete(for: Key.accessToken)
        delete(for: Key.refreshToken)
        delete(for: Key.userId)
    }

    public var userId: String? {
        get { read(for: Key.userId) }
        set {
            if let newValue {
                save(newValue, for: Key.userId)
            } else {
                delete(for: Key.userId)
            }
        }
    }

    private func save(_ value: String, for account: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain save error for \(account): \(status)")
        }
    }

    private func read(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                print("Keychain read error for \(account): \(status)")
            }
            return nil
        }

        guard let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(for account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete error for \(account): \(status)")
        }
    }
}

