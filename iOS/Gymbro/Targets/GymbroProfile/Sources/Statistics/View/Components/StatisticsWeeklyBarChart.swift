import Foundation
import SwiftUI
import GymbroTypes

struct StatisticsWeeklyBarChart: View {
    
    init(
        items: [StatisticsBarItem],
        selectedBarID: Binding<String?>
    ) {
        self.items = items
        self._selectedBarID = selectedBarID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerView
            
            GeometryReader { geometry in
                let chartHeight: CGFloat = 150
                let maxValue = max(items.map(\.value).max() ?? 1, 1)
                let stepWidth = geometry.size.width / CGFloat(max(items.count, 1))
                
                ZStack(alignment: .topLeading) {
                    chartGrid(height: chartHeight)
                    
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach(items) { item in
                            barView(
                                for: item,
                                maxValue: maxValue,
                                chartHeight: chartHeight
                            )
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.25)) {
                                    selectedBarID = item.id
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
                                y: 10
                            )
                            .animation(.spring(duration: 0.25), value: selectedBarID)
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
                            if selectedBarID != item.id {
                                withAnimation(.spring(duration: 0.18)) {
                                    selectedBarID = item.id
                                }
                            }
                        }
                )
            }
            .frame(height: 190)
        }
        .onAppear {
            if selectedBarID == nil {
                selectedBarID = items.max(by: { $0.value < $1.value })?.id
            }
            
            animateBars = false
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.65, dampingFraction: 0.82)) {
                    animateBars = true
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "statistics.chart.weekly_activity", bundle: .module))
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(selectedItemSubtitle)
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
    
    private func chartGrid(height: CGFloat) -> some View {
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
    
    private func barView(
        for item: StatisticsBarItem,
        maxValue: Int,
        chartHeight: CGFloat
    ) -> some View {
        let isSelected = selectedBarID == item.id
        let normalizedHeight = max(CGFloat(item.value) / CGFloat(maxValue), 0.08)
        let barHeight = animateBars ? normalizedHeight * chartHeight : 8
        
        return VStack(spacing: 10) {
            Spacer(minLength: 0)
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(barFill(isSelected: isSelected))
                .frame(height: barHeight)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(isSelected ? 0.24 : 0.08), lineWidth: 1)
                )
                .shadow(
                    color: isSelected ? Color.appPurple.opacity(0.35) : .clear,
                    radius: 14,
                    x: 0,
                    y: 8
                )
                .animation(
                    .spring(response: 0.65, dampingFraction: 0.82).delay(Double(barAnimationIndex(for: item)) * 0.03),
                    value: animateBars
                )
            
            Text(item.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
        }
    }
    
    private func tooltipView(for item: StatisticsBarItem) -> some View {
        VStack(spacing: 4) {
            Text(item.label)
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
    
    private func barFill(isSelected: Bool) -> some ShapeStyle {
        LinearGradient(
            colors: isSelected
            ? [Color.appPurple, Color.white]
            : [Color.appPurple.opacity(0.5), Color.purple.opacity(0.35)],
            startPoint: .bottom,
            endPoint: .top
        )
    }
    
    private func barAnimationIndex(for item: StatisticsBarItem) -> Int {
        items.firstIndex(where: { $0.id == item.id }) ?? 0
    }
    
    private var selectedItem: StatisticsBarItem? {
        guard let selectedBarID else { return nil }
        return items.first(where: { $0.id == selectedBarID })
    }
    
    private var selectedItemSubtitle: String {
        guard let selectedItem else {
            return "Tap or drag across the chart"
        }
        return "Focused on \(selectedItem.label)"
    }
    
    @Binding private var selectedBarID: String?
    @State private var animateBars: Bool = false
    
    private let items: [StatisticsBarItem]
}
