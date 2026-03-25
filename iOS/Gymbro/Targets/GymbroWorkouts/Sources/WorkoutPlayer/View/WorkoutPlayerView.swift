import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct WorkoutPlayerViewState {
    let workoutName: String
    let workoutType: WorkoutType
    let exercises: [ExerciseItem]
}

struct WorkoutPlayerView: View {

    init(viewModel: WorkoutPlayerViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            TopGradientBackground()
            switch viewModel.screenState {
            case .loading:
                Text("loading")
            case .loaded:
                content
            case .offline:
                VStack(spacing: 0){
                    OfflineHeader()
                    content
                }
                .ignoresSafeArea(.container, edges: .bottom)
            case .error:
                VStack(alignment: .center) {
                    Text("Something went wrong, oopsie...")
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    AppButton("Refresh", size: .xl) {
                        Task { await viewModel.loadWorkout() }
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(false)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .onAppear {
            if scrolledExerciseId == nil {
                scrolledExerciseId = viewModel.exercises.first?.id
            }
        }
        .onChange(of: scrolledExerciseId) { _, newId in
            syncIndexFromScrollId(newId)
        }
        .customAlert(
            isPresented: $viewModel.showAlert,
            data: CustomAlertData(
                message: "Are you sure you want to exit this workout?",
                primaryButton: AppButton("Yes", action: {
                    viewModel.showAlert = false
                    viewModel.exit()
                })
            )
        )
    }
    
    // Subviews
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerBlock
                .padding(.horizontal, 16)

            if viewModel.exercises.isEmpty {
                Spacer()
                Text("No exercises in this workout")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                Spacer()
            } else {
                exerciseScrollPager
                    .padding(.top, 12)
                
                upNext
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                
                progressBar
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
            }
        }
    }
    
    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                
                Button {
                    viewModel.backButtonTapped()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .imageScale(.large)
                }
                
                Text(viewModel.workoutName)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.leading, 24)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(viewModel.workoutType.title)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 24)
            
            Text(viewModel.positionLabel)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.leading, 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var exerciseScrollPager: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(viewModel.exercises, id: \.id) { item in
                    WorkoutPlayerExerciseSlideView(
                        exercise: item,
                        onNext: makeNextAction(for: item),
                        onWeightChanged: { viewModel.updateWeight(exerciseId: item.id, weight: $0) }
                    )
                        .padding(.horizontal, 16)
                        .containerRelativeFrame(.horizontal, alignment: .center)
                        .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                            content
                                .scaleEffect(1 - abs(phase.value) * 0.22, anchor: .center)
                                .rotation3DEffect(
                                    .degrees(phase.value * -14),
                                    axis: (x: 0, y: 1, z: 0),
                                    perspective: 0.82
                                )
                                .offset(y: CGFloat(phase.value) * 6)
                        }
                        .id(item.id)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: $scrolledExerciseId)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    private var upNext: some View {
        HStack {
            if let nextExercise = viewModel.nextExercise {
                VStack(alignment: .leading) {
                    Text("Up Next")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(nextExercise.name)")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            } else {
                VStack(alignment: .leading) {
                    Text("Looks like you're all done!")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundStyle(.white)
                }
                Spacer()
                AppButton("Finish", action: {})
            }
            
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(LinearGradient(
                    colors: upNextGradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.25), value: viewModel.progress)
    }

    private var progressBar: some View {
        GeometryReader { geo in
            let width = max(geo.size.width * viewModel.progress, 0)
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .fill(Color.white.opacity(0.1))

                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.clear, .white.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .fill(
                        LinearGradient(
                            colors: progressGradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width)
                    .animation(.easeInOut(duration: 0.25), value: viewModel.progress)
            }
        }
        .frame(height: 6)
    }

    @State private var scrolledExerciseId: String?
    @ObservedObject private var viewModel: WorkoutPlayerViewModel
}

// Helpers

extension WorkoutPlayerView {
    private var progressGradientColors: [Color] {
        guard let current = viewModel.currentExercise else {
            return [.appPurple, .appPurple.opacity(0.7)]
        }
        return [current.accentColor.opacity(0.85), current.accentColor.opacity(0.45)]
    }
    
    private var upNextGradientColors: [Color] {
        guard let next = viewModel.nextExercise else {
            return [Color.appPurple.opacity(0.9), .clear]
        }
        return [Color.appDarkGray.opacity(0.9), .clear]
    }
    
    private func syncIndexFromScrollId(_ newId: String?) {
        guard let newId,
              let index = viewModel.exercises.firstIndex(where: { $0.id == newId }),
              viewModel.currentExerciseIndex != index
        else { return }
        viewModel.currentExerciseIndex = index
    }
    
    private func makeNextAction(for item: ExerciseItem) -> () -> Void {
        guard
            let idx = viewModel.exercises.firstIndex(where: { $0.id == item.id }),
            idx + 1 < viewModel.exercises.count
        else { return {} }
        return { withAnimation { scrolledExerciseId = viewModel.exercises[idx + 1].id } }
    }
}

extension ExerciseItem {
    fileprivate var accentColor: Color {
        switch self {
        case .strength: return Color.strengthColor
        case .cardio: return Color.cardioColor
        case .yoga: return Color.yogaColor
        case .fallback: return Color.appPurple
        }
    }
}
