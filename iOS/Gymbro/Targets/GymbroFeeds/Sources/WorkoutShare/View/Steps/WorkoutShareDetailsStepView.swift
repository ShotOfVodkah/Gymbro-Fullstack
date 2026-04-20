import SwiftUI

struct WorkoutShareDetailsStepView: View {
    @ObservedObject var viewModel: WorkoutShareViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            WorkoutShareSectionCard(title: "Caption") {
                TextField(
                    "Add a caption",
                    text: Binding(
                        get: { viewModel.draft.caption },
                        set: { viewModel.updateCaption($0) }
                    ),
                    axis: .vertical
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .lineLimit(3...6)
            }
            
            WorkoutShareSectionCard(title: "Location") {
                TextField(
                    "Optional location",
                    text: Binding(
                        get: { viewModel.locationText },
                        set: { viewModel.updateLocation($0) }
                    )
                )
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }
}
