import Foundation

enum MockDecoder {
    static func decode<T: Decodable>(_ json: String) -> T {
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(T.self, from: data)
    }
}
