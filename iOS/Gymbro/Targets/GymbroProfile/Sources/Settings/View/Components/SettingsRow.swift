import SwiftUI
import GymbroTypes

struct SettingsRow: View {
    
    let item: SettingsItem
    let onTap: () -> Void
    let onToggle: (Bool) -> Void
    
    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: 12) {
                
                Image(systemName: item.icon)
                    .font(.headline)
                    .foregroundStyle(iconColor)
                    .frame(width: 18)
                
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(textColor)
                
                Spacer()
                
                trailingView
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundView)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(accessibilityID)
    }
    
    @ViewBuilder
    private var trailingView: some View {
        switch item.type {
        case .navigation:
            Image(systemName: "hand.tap.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.45))
            
        case .toggle(let isOn):
            Toggle("", isOn: Binding(
                get: { isOn },
                set: onToggle
            ))
            .labelsHidden()
            .tint(Color.appPurple)
            .accessibilityIdentifier("profile.settings.\(item.id).toggle")
            
        case .destructive:
            EmptyView()
        }
    }
    
    private var accessibilityID: String {
        switch item.id {
        case "logout":
            return "profile.settings.logout.button"
        default:
            return "profile.settings.\(item.id).row"
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }

    private var backgroundColors: [Color] {
        switch item.type {
        case .destructive:
            return [
                Color.red.opacity(0.35),
                Color.red.opacity(0.25)
            ]
        default:
            return [
                Color.appPurple.opacity(0.3),
                Color.purple.opacity(0.3)
            ]
        }
    }
    
    private var textColor: Color {
        switch item.type {
        case .destructive:
            return .red
        default:
            return .white
        }
    }
    
    private var iconColor: Color {
        switch item.type {
        case .destructive:
            return .red
        default:
            return .white
        }
    }
    
    private func handleTap() {
        switch item.type {
        case .navigation, .destructive:
            onTap()
        case .toggle:
            break
        }
    }
}
