import SwiftUI
import GymbroTypes

struct ChallengeProgressBarView: View {
    
    let progress: Double
    let color: Color
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.09))
                
                Capsule()
                    .fill(color)
                    .frame(width: proxy.size.width * clampedProgress)
            }
        }
        .frame(height: 8)
    }
}
