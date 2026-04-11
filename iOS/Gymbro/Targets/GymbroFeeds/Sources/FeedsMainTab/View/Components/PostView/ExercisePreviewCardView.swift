import SwiftUI
import GymbroTypes

struct ExercisePreviewCardView: View {
    
    let exercise: ExerciseItem
    let index: Int
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.07))
                    .overlay(exerciseImage)
                    .frame(width: 72, height: 72)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(index). \(exercise.title)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                    
                    Text(exercise.subtitle)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.6))
                    
                    HStack(spacing: 6) {
                        ExerciseMetaTagView(text: exercise.typeTitle, color: exercise.accentColor)
                        ExerciseMetaTagView(text: exercise.muscleGroupTitle, color: exercise.accentColor)
                    }
                }
                
                Spacer()
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [Color.appPurple.opacity(0.3), Color.purple.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }
    
    private var exerciseImage: some View {
        if exercise.imageName.isEmpty {
            Image(systemName: "xmark.square")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        } else {
            Image(systemName: exercise.imageName)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}
