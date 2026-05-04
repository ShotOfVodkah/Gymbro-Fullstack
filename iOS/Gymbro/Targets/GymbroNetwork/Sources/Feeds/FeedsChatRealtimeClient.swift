import Foundation
import GymbroTypes

public final class FeedsChatRealtimeClient {
    private let baseURL: URL
    private let tokenProvider: () -> String?

    public init(baseURL: URL, tokenProvider: @escaping () -> String?) {
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
    }

    public func stream(chatID: String) -> AsyncThrowingStream<ChatRealtimeEventResponse, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let url = baseURL.appendingPathComponent("chats/\(chatID)/stream")
                    var request = URLRequest(url: url)
                    request.httpMethod = "GET"
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

                    if let token = tokenProvider(), !token.isEmpty {
                        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                    }

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    if let http = response as? HTTPURLResponse {
                        print("SSE STATUS:", http.statusCode)
                    }

                    guard let http = response as? HTTPURLResponse,
                          (200..<300).contains(http.statusCode) else {
                        throw NetworkError.invalidResponse
                    }

                    let decoder = makeDecoder()
                    for try await line in bytes.lines {
                        guard line.hasPrefix("data:") else {
                            continue
                        }

                        let rawData = line
                            .replacingOccurrences(of: "data:", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)

                        guard !rawData.isEmpty else {
                            continue
                        }

                        let data = Data(rawData.utf8)

                        do {
                            let event = try decoder.decode(
                                ChatRealtimeEventResponse.self,
                                from: data
                            )

                            continuation.yield(event)
                        } catch {
                            print("SSE decode failed:", error)
                            print("SSE raw data:", rawData)
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let withFraction = ISO8601DateFormatter()
            withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            let withoutFraction = ISO8601DateFormatter()
            withoutFraction.formatOptions = [.withInternetDateTime]

            if let date = withFraction.date(from: dateString) {
                return date
            }

            if let date = withoutFraction.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(dateString)"
            )
        }

        return decoder
    }
}
