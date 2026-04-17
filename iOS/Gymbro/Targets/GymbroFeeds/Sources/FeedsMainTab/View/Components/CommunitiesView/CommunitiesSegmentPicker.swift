import SwiftUI
import GymbroTypes

struct CommunitiesSegmentPicker: View {
    
    @Binding var selectedTab: FeedTab
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(FeedTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.localizedTitle)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedTab == tab ? Color.purple.opacity(0.4) : Color.white.opacity(0.07))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 11)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
