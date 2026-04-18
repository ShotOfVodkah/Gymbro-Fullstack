import SwiftUI
import GymbroTypes

struct StatisticsMonthlyTrendChart: View {
    
    init(
        items: [StatisticsPointItem],
        selectedPointID: Binding<String?>
    ) {
        self.items = items
        self._selectedPointID = selectedPointID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            headerView
            
            GeometryReader { geometry in
                let layout = chartLayout(in: geometry.size)
                let points = layout.points
                let baselineY = layout.baselineY
                let stepWidth = geometry.size.width / CGFloat(max(items.count - 1, 1))
                
                ZStack(alignment: .topLeading) {
                    gridView(height: geometry.size.height)
                    
                    if points.count > 1 {
                        areaPath(points: points, baselineY: baselineY)
                            .fill(areaGradient)
                        
                        linePath(points: points, baselineY: baselineY)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.appPurple, Color.purple, Color.white.opacity(0.9)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                            .shadow(color: Color.appPurple.opacity(0.25), radius: 10, x: 0, y: 6)
                    }
                    
                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        pointView(
                            item: items[index],
                            isSelected: selectedPointID == items[index].id
                        )
                        .position(point)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.22)) {
                                selectedPointID = items[index].id
                            }
                        }
                    }
                    
                    if let selectedItem = selectedItem,
                       let selectedIndex = items.firstIndex(where: { $0.id == selectedItem.id }),
                       points.indices.contains(selectedIndex) {
                        let point = points[selectedIndex]
                        
                        selectionIndicator(
                            x: point.x,
                            height: geometry.size.height
                        )
                        
                        tooltipView(for: selectedItem)
                            .position(
                                x: adjustedTooltipX(for: point.x, in: geometry.size.width),
                                y: max(18, point.y - 36)
                            )
                            .animation(.spring(duration: 0.22), value: selectedPointID)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let rawIndex = Int(round(value.location.x / stepWidth))
                            let clampedIndex = min(max(rawIndex, 0), max(items.count - 1, 0))
                            guard items.indices.contains(clampedIndex) else { return }
                            
                            let item = items[clampedIndex]
                            if selectedPointID != item.id {
                                withAnimation(.spring(duration: 0.18)) {
                                    selectedPointID = item.id
                                }
                            }
                        }
                )
            }
            .frame(height: 220)
        }
        .onAppear {
            if selectedPointID == nil {
                selectedPointID = items.last?.id
            }
            
            animateChart = false
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.65)) {
                    animateChart = true
                }
            }
        }
    }
    
    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Monthly Trend")
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

    private func pointView(
        item: StatisticsPointItem,
        isSelected: Bool
    ) -> some View {
        ZStack {
            Circle()
                .fill(Color.appPurple.opacity(isSelected ? 0.28 : 0.0))
                .frame(width: isSelected ? 28 : 14, height: isSelected ? 28 : 14)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: isSelected
                        ? [Color.white, Color.appPurple]
                        : [Color.white.opacity(0.9), Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: isSelected ? 12 : 8, height: isSelected ? 12 : 8)
                .shadow(color: isSelected ? Color.appPurple.opacity(0.32) : .clear, radius: 10, x: 0, y: 4)
        }
        .animation(.spring(duration: 0.2), value: isSelected)
    }
    
    private func selectionIndicator(x: CGFloat, height: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color.white.opacity(0.14), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1.5, height: height)
            .position(x: x, y: height / 2)
    }
    
    private func tooltipView(for item: StatisticsPointItem) -> some View {
        VStack(spacing: 4) {
            Text(item.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
            
            Text("\(item.value) workouts")
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
    
    private func linePath(points: [CGPoint], baselineY: CGFloat) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: animatedPoint(first, baselineY: baselineY))
            
            for point in points.dropFirst() {
                path.addLine(to: animatedPoint(point, baselineY: baselineY))
            }
        }
    }
    
    private func areaPath(points: [CGPoint], baselineY: CGFloat) -> Path {
        Path { path in
            guard let first = points.first,
                  let last = points.last else { return }
            
            let animatedFirst = animatedPoint(first, baselineY: baselineY)
            path.move(to: CGPoint(x: animatedFirst.x, y: baselineY))
            path.addLine(to: animatedFirst)
            
            for point in points.dropFirst() {
                path.addLine(to: animatedPoint(point, baselineY: baselineY))
            }
            
            let animatedLast = animatedPoint(last, baselineY: baselineY)
            path.addLine(to: CGPoint(x: animatedLast.x, y: baselineY))
            path.closeSubpath()
        }
    }
    
    private func animatedPoint(_ point: CGPoint, baselineY: CGFloat) -> CGPoint {
        CGPoint(
            x: point.x,
            y: baselineY - (baselineY - point.y) * animationProgress
        )
    }
    
    private func chartLayout(in size: CGSize) -> (points: [CGPoint], baselineY: CGFloat) {
        guard !items.isEmpty else { return ([], size.height - 28) }
        
        let maxValue = max(items.map(\.value).max() ?? 1, 1)
        let width = size.width
        let height = size.height
        let topPadding: CGFloat = 24
        let bottomPadding: CGFloat = 28
        let usableHeight = height - topPadding - bottomPadding
        let stepX = width / CGFloat(max(items.count - 1, 1))
        let baselineY = height - bottomPadding
        
        let points = items.enumerated().map { index, item in
            let x = stepX * CGFloat(index)
            let normalized = CGFloat(item.value) / CGFloat(maxValue)
            let y = baselineY - normalized * usableHeight
            return CGPoint(x: x, y: y)
        }
        
        return (points, baselineY)
    }
    
    private func adjustedTooltipX(for x: CGFloat, in width: CGFloat) -> CGFloat {
        min(max(x, 56), width - 56)
    }
    
    private var selectedItem: StatisticsPointItem? {
        guard let selectedPointID else { return nil }
        return items.first(where: { $0.id == selectedPointID })
    }
    
    private var selectedSubtitle: String {
        guard let selectedItem else {
            return "Drag across the monthly trend"
        }
        return "Focused on \(selectedItem.label)"
    }
    
    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.appPurple.opacity(0.28),
                Color.purple.opacity(0.12),
                Color.clear
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    @Binding private var selectedPointID: String?
    @State private var animateChart: Bool = false
    
    private var animationProgress: CGFloat {
        animateChart ? 1 : 0.04
    }
    
    private let items: [StatisticsPointItem]
}
