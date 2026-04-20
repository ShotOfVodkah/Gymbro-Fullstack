import SwiftUI

struct WorkoutSharePreviewStepView: View {
    @ObservedObject var viewModel: WorkoutShareViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            WorkoutShareSectionCard(title: "Workout") {
                previewCard(
                    icon: "figure.strengthtraining.traditional",
                    title: viewModel.summaryTitle,
                    subtitle: viewModel.summarySubtitle
                )
            }
            
            WorkoutShareSectionCard(title: "Caption") {
                previewTextCard(viewModel.previewCaptionText)
            }
            
            if let location = viewModel.previewLocationText {
                WorkoutShareSectionCard(title: "Location") {
                    HStack(spacing: 10) {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.white.opacity(0.65))
                        
                        Text(location)
                            .foregroundStyle(.white)
                        
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
            
            WorkoutShareSectionCard(title: "Destinations") {
                VStack(spacing: 10) {
                    ForEach(viewModel.previewDestinationTitles, id: \.self) { title in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appPurple)
                            
                            Text(title)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                        .padding(14)
                        .background(Color.white.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
        }
    }
    
    private func previewCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.appPurple.opacity(0.9), Color.purple.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }
            
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private func previewTextCard(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(.white.opacity(0.94))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
