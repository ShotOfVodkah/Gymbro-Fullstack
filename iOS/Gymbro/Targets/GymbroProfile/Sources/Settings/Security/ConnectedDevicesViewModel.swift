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

    private var isRefreshing = false

    init(onSessionEnded: @escaping () -> Void) {
        self.onSessionEnded = onSessionEnded
    }

    func load() {
        Task {
            await performLoad(showLoading: true)
        }
    }

    func refresh() async {
        await performLoad(showLoading: false)
    }

    private func performLoad(showLoading: Bool) async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        let alreadyLoaded: Bool = {
            if case .loaded = screenState { return true }
            return false
        }()

        if showLoading || !alreadyLoaded {
            screenState = .loading
        }

        do {
            let response = try await AppMicroservices.auth.listSessions()
            sessions = response.sessions
            screenState = .loaded
        } catch {
            if sessions.isEmpty {
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
                    Task {
                        await performLoad(showLoading: false)
                    }
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
