import Foundation
import SwiftUI
import GymbroTypes

struct StatisticsMonthlyCountChart: View {
    
    init(
        items: [StatisticsMonthCountItem],
        selectedItemID: Binding<String?>
    ) {
        self.items = items
        self._selectedItemID = selectedItemID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerView
            
            GeometryReader { geometry in
                let maxValue = max(items.map(\.value).max() ?? 1, 1)
                let stepWidth = geometry.size.width / CGFloat(max(items.count, 1))
                let chartHeight: CGFloat = 170
                
                ZStack(alignment: .topLeading) {
                    gridView(height: chartHeight)
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(items) { item in
                            monthBarView(
                                item: item,
                                maxValue: maxValue,
                                chartHeight: chartHeight
                            )
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.22)) {
                                    selectedItemID = item.id
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    
                    if let selectedItem = selectedItem,
                       let selectedIndex = items.firstIndex(where: { $0.id == selectedItem.id }) {
                        tooltipView(for: selectedItem)
                            .position(
                                x: stepWidth * (CGFloat(selectedIndex) + 0.5),
                                y: 12
                            )
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let rawIndex = Int(value.location.x / stepWidth)
                            let clampedIndex = min(max(rawIndex, 0), max(items.count - 1, 0))
                            guard items.indices.contains(clampedIndex) else { return }
                            
                            let item = items[clampedIndex]
                            if selectedItemID != item.id {
                                withAnimation(.spring(duration: 0.18)) {
                                    selectedItemID = item.id
                                }
                            }
                        }
                )
            }
            .frame(height: 210)
        }
        .onAppear {
            if selectedItemID == nil {
                selectedItemID = items.last?.id
            }
            
            animateBars = false
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.7, dampingFraction: 0.84)) {
                    animateBars = true
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "statistics.chart.year_summary", bundle: .module))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(selectedSubtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            if let selectedItem {
                Text("\(selectedItem.value)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }
        }
    }
    
    private func gridView(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { _ in
                Spacer()
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
            }
        }
        .frame(height: height)
    }
    
    private func monthBarView(
        item: StatisticsMonthCountItem,
        maxValue: Int,
        chartHeight: CGFloat
    ) -> some View {
        let isSelected = selectedItemID == item.id
        let normalizedHeight = max(CGFloat(item.value) / CGFloat(maxValue), 0.08)
        let barHeight = animateBars ? normalizedHeight * chartHeight : 10
        
        return VStack(spacing: 10) {
            Spacer(minLength: 0)
            
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: isSelected
                        ? [Color.appPurple, Color.white]
                        : [Color.appPurple.opacity(0.5), Color.purple.opacity(0.35)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: barHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(isSelected ? 0.18 : 0.05), lineWidth: 1)
                )
                .shadow(
                    color: isSelected ? Color.appPurple.opacity(0.25) : .clear,
                    radius: 12,
                    x: 0,
                    y: 6
                )
                .animation(.spring(response: 0.65, dampingFraction: 0.82), value: animateBars)
            
            Text(item.monthLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
        }
    }
    
    private func tooltipView(for item: StatisticsMonthCountItem) -> some View {
        VStack(spacing: 4) {
            Text(item.monthLabel)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            Text(String(format: String(localized: "statistics.chart.workouts_count", bundle: .module), locale: .current, item.value))
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    private var selectedItem: StatisticsMonthCountItem? {
        guard let selectedItemID else { return nil }
        return items.first(where: { $0.id == selectedItemID })
    }
    
    private var selectedSubtitle: String {
        guard let selectedItem else {
            return "Drag across the chart"
        }
        return "Focused on \(selectedItem.monthLabel)"
    }
    
    @Binding private var selectedItemID: String?
    @State private var animateBars: Bool = false
    
    private let items: [StatisticsMonthCountItem]
}
