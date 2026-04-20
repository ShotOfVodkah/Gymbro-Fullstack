import SwiftUI
import GymbroCommonUI

struct WorkoutShareErrorStateView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(GymbroCommonStrings.genericError)
                .font(.title3)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
            
            AppButton(GymbroCommonStrings.refresh, size: .xl) {
                onRetry()
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
