import SwiftUI

public struct OfflineHeader: View {
    
    public init() { }
    
    public var body: some View {
        Text(GymbroCommonStrings.offlineMode)
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 10)
            .background(LinearGradient(colors: [.red, .pink], startPoint: .leading, endPoint: .trailing))
            .foregroundStyle(Color.white)
            .accessibilityIdentifier("workouts.offline.banner")
    }
}
