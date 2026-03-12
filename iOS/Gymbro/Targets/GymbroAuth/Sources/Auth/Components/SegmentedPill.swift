import SwiftUI
import GymbroCommonUI

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
