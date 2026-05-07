import SwiftUI
import GymbroCommonUI

struct WorkoutShareActionBar: View {
    let backButtonTitle: String
    let primaryButtonTitle: String
    let isPrimaryDisabled: Bool
    let onBackTap: () -> Void
    let onPrimaryTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AppButton(
                backButtonTitle,
                size: .xl,
                action: onBackTap,
                wrapContent: false
            )
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("feeds.workoutShare.back")
            
            AppButton(
                primaryButtonTitle,
                size: .xl,
                action: onPrimaryTap,
                wrapContent: false
            )
            .frame(maxWidth: .infinity)
            .accessibilityIdentifier("feeds.workoutShare.primary")
            .disabled(isPrimaryDisabled)
            .opacity(isPrimaryDisabled ? 0.5 : 1.0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 16)
        .background(Color.clear)
    }
}
