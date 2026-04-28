import SwiftUI
import GymbroCommonUI

struct StreakSettingsSheetView: View {
    
    let currentGoal: Int
    let scheduledGoal: Int?
    let isSaving: Bool
    let onSave: (Int) -> Void
    let onCancel: () -> Void
    
    @State private var selectedGoal: Int
    
    private let goals = [1, 2, 3, 4, 5, 6, 7]
    
    init(
        currentGoal: Int,
        scheduledGoal: Int?,
        isSaving: Bool,
        onSave: @escaping (Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.currentGoal = currentGoal
        self.scheduledGoal = scheduledGoal
        self.isSaving = isSaving
        self.onSave = onSave
        self.onCancel = onCancel
        self._selectedGoal = State(initialValue: scheduledGoal ?? currentGoal)
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(alignment: .leading, spacing: 22) {
                headerView
                goalPickerView
                hintView
                actionsView
            }
            .padding(22)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Weekly Goal")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Choose how many workouts you want to complete every week.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.62))
        }
    }
    
    private var goalPickerView: some View {
        HStack(spacing: 10) {
            ForEach(goals, id: \.self) { goal in
                Button {
                    selectedGoal = goal
                } label: {
                    VStack(spacing: 6) {
                        Text("\(goal)")
                            .font(.system(size: 20, weight: .bold))
                        
                        Text("x")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.54))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedGoal == goal ? Color.appPurple : Color.white.opacity(0.10))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.85),
                                        Color.white.opacity(0.25),
                                        Color.clear
                                    ],
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading
                                ),
                                lineWidth: 1
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.35),
                                        Color.white.opacity(0.15),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .blendMode(.screen)
                    )
                }
                .buttonStyle(.plain)
                .disabled(isSaving)
            }
        }
    }
    
    private var hintView: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.68))
            
            VStack(alignment: .leading,spacing: 6) {
                if let scheduledGoal {
                    Text("Currently scheduled: \(scheduledGoal) workouts per week")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.purple.opacity(0.8))
                }
                
                Text("This change will be applied from next week to keep streak progress fair and prevent streak abuse.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.56))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var actionsView: some View {
        HStack(spacing: 12) {
            AppButton("Cancel", size: .l, action: {
                onCancel()
            }, wrapContent: false)
            .opacity(isSaving ? 0.6 : 1)
            .disabled(isSaving)
            
            AppButton(isSaving ? "Saving..." : "Save", size: .l, action: {
                onSave(selectedGoal)
            }, wrapContent: false)
            .opacity(isSaveDisabled ? 0.55 : 1)
            .disabled(isSaveDisabled)
        }
    }
    
    private var isSaveDisabled: Bool {
        isSaving || selectedGoal == scheduledGoal || (scheduledGoal == nil && selectedGoal == currentGoal)

    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 18.0/255.0, green: 20.0/255.0, blue: 28.0/255.0),
                Color(red: 28.0/255.0, green: 32.0/255.0, blue: 42.0/255.0),
                Color(red: 20.0/255.0, green: 24.0/255.0, blue: 34.0/255.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
