import SwiftUI
import GymbroCommonUI

struct FeedsCalendarViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                    personPicker
                    calendarCard
                    Spacer(minLength: 24)
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .shimmer(active: true)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0/255.0, green: 18.0/255.0, blue: 36.0/255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 46, height: 46)
                .overlay(
                    RoundedRectLine(width: 14, height: 18, cornerRadius: 4)
                )
            
            RoundedRectLine(width: 120, height: 30, cornerRadius: 8)
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
    
    private var personPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(SkeletonFill())
                            .frame(width: 18, height: 18)
                        
                        RoundedRectLine(
                            width: index == 0 ? 36 : 52,
                            height: 14,
                            cornerRadius: 6
                        )
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(SkeletonFill())
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var calendarCard: some View {
        VStack(spacing: 16) {
            monthNavigation
            
            weekdayRow
            
            monthGrid
            
            legend
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.04))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }
    
    private var monthNavigation: some View {
        HStack {
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 38, height: 38)
                .overlay(
                    RoundedRectLine(width: 10, height: 14, cornerRadius: 4)
                )
            
            Spacer()
            
            RoundedRectLine(width: 120, height: 20, cornerRadius: 7)
            
            Spacer()
            
            Circle()
                .fill(Color.white.opacity(0.07))
                .frame(width: 38, height: 38)
                .overlay(
                    RoundedRectLine(width: 10, height: 14, cornerRadius: 4)
                )
        }
    }
    
    private var weekdayRow: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { _ in
                RoundedRectLine(width: 24, height: 12, cornerRadius: 4)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var monthGrid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(0..<35, id: \.self) { index in
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        index == 8 || index == 11 || index == 16 || index == 24
                        ? Color.appPurple.opacity(0.35)
                        : Color.white.opacity(0.04)
                    )
                    .frame(height: 42)
                    .overlay(
                        RoundedRectLine(width: 14, height: 14, cornerRadius: 4)
                    )
                    .opacity(index < 2 || index > 31 ? 0.25 : 1)
            }
        }
    }
    
    private var legend: some View {
        HStack(spacing: 18) {
            legendItem()
            legendItem()
            legendItem()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func legendItem() -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 16, height: 16)
            
            RoundedRectLine(width: 52, height: 12, cornerRadius: 5)
        }
    }
}
