import Foundation

/// Base URLs for deployed backends (Yandex Cloud VM).
public enum APIBaseURLs {
    public static let gateway = "http://111.88.145.152:8080"

    public static let divKit = "http://111.88.145.152:8090"

    public static var gatewayURL: URL { URL(string: gateway)! }

    public static var divKitURL: URL { URL(string: divKit)! }
}
