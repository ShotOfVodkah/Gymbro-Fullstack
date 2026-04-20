import SwiftUI
import GymbroTypes

struct CalendarWorkoutChoicesView: View {
    
    let day: CalendarDayItem
    let onWorkoutTap: (CalendarWorkoutPreview, CalendarWorkoutOwner) -> Void
    let onCloseTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            headerView
            
            if !day.myWorkouts.isEmpty {
                sectionView(
                    title: "My workouts",
                    workouts: day.myWorkouts,
                    owner: .mine
                )
            }
            
            if !day.partnerWorkouts.isEmpty {
                sectionView(
                    title: "Partner workouts",
                    workouts: day.partnerWorkouts,
                    owner: .partner
                )
            }
        }
        .padding(18)
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
            .stroke(Color.white.opacity(0.28), lineWidth: 1))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .shadow(color: .black.opacity(0.18), radius: 18, x: 0, y: 8)
    }
    
    private var headerView: some View {
        VStack (alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Selected day")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .textCase(.uppercase)
                    
                    Text("Workouts for day \(day.dayNumber)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                Button(action: onCloseTap) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 30, height: 30)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .buttonStyle(.plain)
            }
            
            Text("Choose a completed workout to open")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.white.opacity(0.65))
                .lineLimit(1)
                .layoutPriority(1)
        }
    }
    
    private func sectionView(
        title: String,
        workouts: [CalendarWorkoutPreview],
        owner: CalendarWorkoutOwner
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.55))
                .textCase(.uppercase)
            
            VStack(spacing: 10) {
                ForEach(workouts) { workout in
                    workoutCard(workout: workout, owner: owner)
                }
            }
        }
    }
    
    private func workoutCard(
        workout: CalendarWorkoutPreview,
        owner: CalendarWorkoutOwner
    ) -> some View {
        let accent = accentColor(for: workout.category, owner: owner)
        
        return Button {
            onWorkoutTap(workout, owner)
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(accent.opacity(0.36))
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(accent.opacity(0.78), lineWidth: 1)
                        )
                    
                    Image(systemName: iconName(for: workout.category))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(workout.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text(workout.category.capitalized)
                        Text("•")
                        Text(workout.timeLabel)
                        Text("•")
                        Text("\(workout.durationMinutes) min")
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: true, vertical: false)
                    .layoutPriority(1)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.1),
                                accent.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func accentColor(for category: String, owner: CalendarWorkoutOwner) -> Color {
        switch category.lowercased() {
        case "strength":
            return .strengthColor
        case "cardio":
            return .cardioColor
        case "yoga":
            return .yogaColor
        default:
            return owner == .mine ? .appPurple : .blue.opacity(0.9)
        }
    }
    
    private func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "strength":
            return "dumbbell.fill"
        case "cardio":
            return "figure.run"
        case "yoga":
            return "figure.mind.and.body"
        default:
            return "flame.fill"
        }
    }
}
