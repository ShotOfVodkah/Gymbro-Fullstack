import SwiftUI

struct WorkoutPlayerView: View {

    init(viewModel: WorkoutPlayerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Text("Workout Player")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.white)

                Text(viewModel.workoutId)
                    .font(.subheadline)
                    .foregroundStyle(Color.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                Spacer()
            }
            .padding(.top, 72)
            .padding(.horizontal, 24)

            Button {
                viewModel.backButtonTapped()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .imageScale(.large)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 16)
            .padding(.leading, 16)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
    }

    @ObservedObject private var viewModel: WorkoutPlayerViewModel
}
