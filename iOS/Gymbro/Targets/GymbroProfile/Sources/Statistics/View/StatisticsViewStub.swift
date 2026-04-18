import SwiftUI
import GymbroCommonUI

struct ProfileStatisticsViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    heroSkeleton
                    chartSkeleton(height: 210)
                    chartSkeleton(height: 240)
                    chartSkeleton(height: 220)
                    detailsGridSkeleton
                    insightsSkeleton
                    categoriesSkeleton
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 120)
            }
        }
        .shimmer(active: true)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 10.0 / 255.0, green: 16.0 / 255.0, blue: 34.0 / 255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var heroSkeleton: some View {
        VStack(spacing: 12) {
            statCard(height: 150)
            
            HStack(spacing: 12) {
                statCard(height: 150)
                statCard(height: 150)
            }
        }
    }
    
    private func chartSkeleton(height: CGFloat) -> some View {
        ProfileSectionContainer {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .frame(height: height)
        }
    }
    
    private var detailsGridSkeleton: some View {
        ProfileSectionContainer {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    compactCard
                    compactCard
                }
                HStack(spacing: 12) {
                    compactCard
                    compactCard
                }
            }
        }
    }
    
    private var insightsSkeleton: some View {
        ProfileSectionContainer {
            VStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 74)
                }
            }
        }
    }
    
    private var categoriesSkeleton: some View {
        ProfileSectionContainer {
            VStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectLine(width: 110, height: 14, cornerRadius: 6)
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 12)
                    }
                }
            }
        }
    }
    
    private func statCard(height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.06))
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
    
    private var compactCard: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.white.opacity(0.05))
            .frame(maxWidth: .infinity)
            .frame(height: 110)
    }
}
