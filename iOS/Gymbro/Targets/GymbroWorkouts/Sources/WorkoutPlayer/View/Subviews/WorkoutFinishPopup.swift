import SwiftUI
import GymbroCommonUI

struct WorkoutFinishPopup: View {

    @Binding var isPresented: Bool
    var onDone: () -> Void

    @State private var opacity: Double = 0.0

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
                Text("Workout Complete!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("You crushed it! Choose friends to share with:")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 20)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(Self.mockFriends) { friend in
                        FriendActivityCard(friend: friend)
                    }
                }
            }
            .frame(maxHeight: 220)

            AppButton("Done", size: .xl, action: onDone, wrapContent: false)
                .padding(.top, 24)
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 24)
        .frame(maxWidth: 400)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.black))
                .shadow(color: .black.opacity(0.4), radius: 24, x: 0, y: 12)
        )
        .padding(.horizontal, 24)
    }

    private static let mockFriends: [FriendActivity] = [
        FriendActivity(id: "1", name: "Alex R.", workoutName: "Chest Day"),
        FriendActivity(id: "2", name: "Maria K.", workoutName: "Morning Cardio"),
        FriendActivity(id: "3", name: "Denis P.", workoutName: "Leg Day"),
        FriendActivity(id: "4", name: "Sofya M.", workoutName: "Full Body"),
    ]
}
