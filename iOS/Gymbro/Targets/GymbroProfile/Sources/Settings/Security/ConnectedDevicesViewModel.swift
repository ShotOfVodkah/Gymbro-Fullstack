import Foundation
import GymbroNetwork
import GymbroAuth

@MainActor
final class ConnectedDevicesViewModel: ObservableObject {

    enum ScreenState {
        case loading
        case loaded
        case error(String)
    }

    @Published var screenState: ScreenState = .loading
    @Published var sessions: [AuthSessionResponse] = []
    private let onSessionEnded: () -> Void

    init(onSessionEnded: @escaping () -> Void) {
        self.onSessionEnded = onSessionEnded
    }

    func load() {
        Task {
            screenState = .loading

            do {
                let response = try await AppMicroservices.auth.listSessions()
                sessions = response.sessions
                screenState = .loaded
            } catch {
                screenState = .error(error.localizedDescription)
            }
        }
    }

    func revoke(_ session: AuthSessionResponse) {
        Task {
            do {
                _ = try await AppMicroservices.auth.revokeSession(sessionID: session.sessionID)

                if session.isCurrent {
                    onSessionEnded()
                    SessionManager.shared.forceLogoutLocally()
                } else {
                    load()
                }
            } catch {
                screenState = .error(error.localizedDescription)
            }
        }
    }

    func logoutAllDevices() {
        Task {
            do {
                _ = try await AppMicroservices.auth.logoutAllDevices()
                onSessionEnded()
                SessionManager.shared.forceLogoutLocally()
            } catch {
                screenState = .error(error.localizedDescription)
            }
        }
    }
}
