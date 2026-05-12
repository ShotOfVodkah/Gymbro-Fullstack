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
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 10) {
                        Button {
                            Task { await viewModel.fetchCurrentLocationSuggestions() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                Text(viewModel.isResolvingCurrentLocation ? "Getting location..." : "Use current location")
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.10))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .disabled(viewModel.isResolvingCurrentLocation)
                    }

                    if let message = viewModel.locationResolveErrorMessage {
                        Text(message)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    if !viewModel.locationSuggestions.isEmpty {
                        VStack(spacing: 8) {
                            ForEach(viewModel.locationSuggestions, id: \.self) { value in
                                Button {
                                    viewModel.selectLocationSuggestion(value)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin.and.ellipse")
                                            .foregroundStyle(.white.opacity(0.7))
                                        Text(value)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(.white)
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }

                    TextField(
                        "Or type a location",
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
}
