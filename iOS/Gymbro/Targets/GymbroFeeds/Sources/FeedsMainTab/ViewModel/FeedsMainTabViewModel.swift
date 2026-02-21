import Foundation

@MainActor
final class FeedsMainTabViewModel: ObservableObject {
    
    enum ScreenState {
        case loading
        case loaded
        case error
    }
    
    public init() {
        screenState = .loaded
    }
    
    @Published var screenState: ScreenState = .loading
}
