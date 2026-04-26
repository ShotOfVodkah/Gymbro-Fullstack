import SwiftUI

import GymbroCommonUI
import GymbroTypes

struct ActivityCalendarWidgetView: View {
    let payload: ActivityCalendarWidgetPayload

    private var monthDate: Date? {
        let p = payload.month.split(separator: "-")
        guard p.count == 2,
              let y = Int(p[0]),
              let m = Int(p[1])
        else { return nil }
        return Calendar.current.date(from: DateComponents(year: y, month: m, day: 1))
    }

    private var monthTitle: String {
        guard let monthDate else { return "" }
        let f = DateFormatter()
        f.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return f.string(from: monthDate)
    }

    private var workoutSet: Set<Int> {
        Set(payload.workoutDays)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.subheadline)
                    Text(WidgetActivityCalendarL10n.widgetHeader)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Spacer()
                
                Text(monthTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .glassCapsuleStyle()

            weekdayRow

            dayGrid
        }
        .padding(4)
        .containerBackground(for: .widget) {
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.appPurple,
                            Color.appDarkGray,
                            Color.appDarkGray
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }

    private var weekdayRow: some View {
        let cal = Calendar.current
        let symbols = cal.veryShortWeekdaySymbols
        let first = cal.firstWeekday
        let ordered: [String] = (0..<7).map { i in
            let idx = (first - 1 + i) % 7
            return symbols[idx]
        }
        return HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Text(ordered[i])
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    @ViewBuilder
    private var dayGrid: some View {
        if let (leading, count) = monthLayout() {
            let cols = 7
            let cells = leading + count
            let totalRows = (cells + cols - 1) / cols
            VStack(spacing: 2) {
                ForEach(0..<totalRows, id: \.self) { row in
                    HStack(spacing: 2) {
                        ForEach(0..<cols, id: \.self) { col in
                            let idx = row * cols + col
                            dayCell(index: idx, leading: leading, count: count) { day in
                                workoutSet.contains(day)
                            }
                        }
                    }
                }
            }
        } else {
            Spacer()
        }
    }

    @ViewBuilder
    private func dayCell(
        index: Int,
        leading: Int,
        count: Int,
        hasWorkout: (Int) -> Bool
    ) -> some View {
        if index < leading {
            Color.clear.frame(maxWidth: .infinity, minHeight: 14, maxHeight: 18)
        } else {
            let day = index - leading + 1
            if day <= count {
                let isWorkout = hasWorkout(day)
                ZStack {
                    if isWorkout {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.appPurple.opacity(0.9),
                                        Color.appPurple,
                                        Color.appPurple.opacity(0.75)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                            )
                            .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)
                    }
                    Text("\(day)")
                        .font(.system(size: 9, weight: isWorkout ? .bold : .regular, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 14, maxHeight: 18)
            } else {
                Color.clear.frame(maxWidth: .infinity, minHeight: 14, maxHeight: 18)
            }
        }
    }

    private func monthLayout() -> (leading: Int, dayCount: Int)? {
        guard let monthDate else { return nil }
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: monthDate)
        guard let y = comps.year, let m = comps.month,
              let start = cal.date(from: DateComponents(year: y, month: m, day: 1)),
              let dayRange = cal.range(of: .day, in: .month, for: start)
        else { return nil }
        let firstWeekday = cal.component(.weekday, from: start)
        let first = cal.firstWeekday
        let leading = (firstWeekday - first + 7) % 7
        return (leading, dayRange.count)
    }
}
