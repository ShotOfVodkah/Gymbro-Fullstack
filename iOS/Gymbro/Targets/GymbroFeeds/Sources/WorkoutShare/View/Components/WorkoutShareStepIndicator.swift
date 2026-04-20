import SwiftUI

struct WorkoutShareStepIndicator: View {
    let currentStepIndex: Int
    let totalSteps: Int
    let progressValue: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("Step \(currentStepIndex + 1) of \(totalSteps)")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
                
                Spacer()
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.07))
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPurple.opacity(0.95), Color.purple.opacity(0.75)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(12, geo.size.width * progressValue))
                }
            }
            .frame(height: 7)
            
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStepIndex ? Color.appPurple.opacity(0.9) : Color.white.opacity(0.10))
                        .frame(height: 6)
                }
            }
        }
    }
}
