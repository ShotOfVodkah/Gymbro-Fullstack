import Foundation

public enum JWTClaimsParser {
    private struct AccessClaims: Decodable {
        let user_id: Int
    }

    public static func userId(fromAccessToken token: String) -> String? {
        let segments = token.split(separator: ".")
        guard segments.count >= 2 else { return nil }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = payload.count % 4
        if remainder != 0 {
            payload += String(repeating: "=", count: 4 - remainder)
        }

        guard let data = Data(base64Encoded: payload),
              let claims = try? JSONDecoder().decode(AccessClaims.self, from: data) else {
            return nil
        }

        return String(claims.user_id)
    }
}
