import Foundation
import SwiftUI
import GymbroTypes

struct StatisticsCategoryBarsSection: View {
    
    init(items: [StatisticsCategoryItem]) {
        self.items = items
    }
    
    var body: some View {
        ProfileSectionContainer(
            title: String(localized: "statistics.categories.title", bundle: .module),
            subtitle: String(localized: "statistics.categories.sub", bundle: .module)
        ) {
            VStack(spacing: 14) {
                ForEach(items) { item in
                    StatisticsCategoryBarRow(
                        item: item,
                        maxValue: maxValue
                    )
                }
            }
        }
    }
    
    private var maxValue: Int {
        items.map(\.value).max() ?? 1
    }
    
    private let items: [StatisticsCategoryItem]
}
