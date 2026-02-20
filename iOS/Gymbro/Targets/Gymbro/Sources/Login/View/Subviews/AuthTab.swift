import SwiftUI
import GymbroCommonUI


enum AuthTab: String, CaseIterable {
    case login = "Log in"
    case register = "Sign in"
}

enum UserRole: String, CaseIterable {
    case athlete = "Athlete"
    case coach = "Coach"
}

struct SegmentedPill: View {
    @Binding var tab: AuthTab

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AuthTab.allCases, id: \.self) { item in
                Text(item.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(tab == item ? .white : .white.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        Group {
                            if tab == item {
                                LinearGradient(
                                    colors: [Color.appPurple.opacity(0.95), Color.purple.opacity(0.75)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                                .cornerRadius(15)
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.18)) { tab = item } }
            }
        }
        .padding(6)
    }
}

struct RoleCard: View {
    let title: String
    let systemImage: String
    let selected: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(selected ? Color.purple.opacity(0.5) : Color.white.opacity(0.06))
                    .frame(width: 54, height: 54)

                Image(systemName: systemImage)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(selected ? .white : .white.opacity(0.65))
            }

            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(selected ? .purple : .white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(selected ? Color.purple : Color.white.opacity(0.2), lineWidth: selected ? 2 : 1.5)
        )
    }
}
