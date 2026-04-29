import SwiftUI
import GymbroTypes

struct ChallengeFilterChipsView: View {
    
    let selectedFilter: ChallengeFilter
    let onSelect: (ChallengeFilter) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(ChallengeFilter.allCases) { filter in
                    Button {
                        onSelect(filter)
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(selectedFilter == filter ? .white : .white.opacity(0.62))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedFilter == filter ? Color.purple.opacity(0.42) : Color.white.opacity(0.06))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct ChallengeCategoryChipsView: View {
    
    let selectedCategory: ChallengeCategory
    let onSelect: (ChallengeCategory) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 11) {
                ForEach(ChallengeCategory.allCases) { category in
                    Button {
                        onSelect(category)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: category.iconName)
                                .font(.system(size: 13, weight: .semibold))
                            
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundStyle(selectedCategory == category ? .white : .white.opacity(0.62))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? Color.purple.opacity(0.42) : Color.white.opacity(0.06))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
