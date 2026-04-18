import SwiftUI
import GymbroTypes

struct StatisticsCategoryBarsSection: View {
    
    init(items: [StatisticsCategoryItem]) {
        self.items = items
    }
    
    var body: some View {
        ProfileSectionContainer(
            title: "Top Exercise Categories",
            subtitle: "Most frequent training focus areas"
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
