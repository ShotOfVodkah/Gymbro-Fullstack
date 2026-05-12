import SwiftUI
import GymbroTypes

struct PeopleSegmentPicker: View {
    
    let selectedTab: PeopleTab
    let availableTabs: [PeopleTab]
    let onSelectTab: (PeopleTab) -> Void
    
    var body: some View {
        HStack(spacing: 9) {
            ForEach(availableTabs) { tab in
                Button {
                    onSelectTab(tab)
                } label: {
                    Text(tab.localizedTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .white : .gray)
                        .padding(.horizontal, 14)
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
