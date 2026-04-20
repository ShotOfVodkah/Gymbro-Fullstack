import SwiftUI

struct WorkoutShareHeader: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            
            Text(subtitle)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.68))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}
