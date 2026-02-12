import SwiftUI

public struct ErrorView: View {
    
    private let action: () -> Void
    
    public init(
            action: @escaping () -> Void
        ) {
            self.action = action
        }
    
    public var body: some View {
        VStack(alignment: .center) {
            Text("Something went wrong, oopsie...")
                .font(.title3)
                .foregroundStyle(Color.white)
            AppButton("Refresh", size: .xl) {
                action()
            }
        }
        .padding(.horizontal, 40)
    }
}

