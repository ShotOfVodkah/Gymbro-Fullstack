import SwiftUI
import GymbroTypes

struct PeopleSegmentPicker: View {
    
    let selectedTab: PeopleTab
    let onSelectTab: (PeopleTab) -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(PeopleTab.allCases) { tab in
                Button {
                    onSelectTab(tab)
                } label: {
                    Text(tab.rawValue)
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
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
