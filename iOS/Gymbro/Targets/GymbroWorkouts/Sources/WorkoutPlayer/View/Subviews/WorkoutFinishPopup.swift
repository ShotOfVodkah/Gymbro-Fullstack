import SwiftUI
import GymbroCommonUI

struct WorkoutFinishPopup: View {
    @Binding var isPresented: Bool
    var onSaveOnly: () -> Void
    var onShareWorkout: () -> Void

    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.5)
                    .ignoresSafeArea(.all)

                popupCard
                    .opacity(opacity)
            }
        }
        .onChange(of: isPresented) { newValue in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                opacity = newValue ? 1.0 : 0.0
            }
        }
    }

    private var popupCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(String(localized: "workout.finish.title", bundle: .module))
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text(String(localized: "workout.finish.subtitle", bundle: .module))
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 24)

            VStack(spacing: 12) {
                AppButton(
                    String(localized: "workout.finish.action_save_only", bundle: .module),
                    size: .xl,
                    action: onSaveOnly,
                    wrapContent: false
                )
                .accessibilityIdentifier("workouts.finish.save_only")

                AppButton(
                    String(localized: "workout.finish.action_share", bundle: .module),
                    size: .xl,
                    action: onShareWorkout,
                    wrapContent: false
                )
                .accessibilityIdentifier("workouts.finish.share")
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.black)
                .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 12)
        )
        .padding(.horizontal, 24)
    }

    @State private var opacity: Double = 0.0
}
