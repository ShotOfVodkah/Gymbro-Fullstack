import SwiftUI
import GymbroTypes

struct ProfileActionButton: View {
    
    init(
        model: ProfileActionModel,
        action: @escaping () -> Void
    ) {
        self.model = model
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: model.iconSystemName)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 18)
                
                Text(model.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(
                        colors: [Color.appPurple.opacity(0.3), Color.purple.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }
    
    private var accessibilityID: String {
        switch model.kind {
        case .settings:
            return "profile.settings.button"
        default:
            return "profile.action.\(Self.analyticsActionID(model.kind)).button"
        }
    }

    private static func analyticsActionID(_ kind: ProfileActionKind) -> String {
        switch kind {
        case .editProfile: return "edit_profile"
        case .settings: return "settings"
        case .posts: return "posts"
        case .friends: return "friends"
        case .workoutCalendar: return "workout_calendar"
        case .statistics: return "statistics"
        case .logout: return "logout"
        }
    }
    
    private let model: ProfileActionModel
    private let action: () -> Void
}
