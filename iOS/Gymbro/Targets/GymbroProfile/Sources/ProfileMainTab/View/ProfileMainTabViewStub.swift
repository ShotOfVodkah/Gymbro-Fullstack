import SwiftUI
import GymbroCommonUI

struct ProfileViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    headerSkeleton
                    actionsSkeleton
                    quickStatsSkeleton
                    weeklyActivitySkeleton
                    aboutSkeleton
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
        }
        .shimmer(active: true)
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12 / 255, green: 18 / 255, blue: 36 / 255),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    private var headerSkeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(SkeletonFill())
                    .frame(width: 84, height: 84)
                
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectLine(width: 170, height: 24, cornerRadius: 8)
                    RoundedRectLine(width: 92, height: 14, cornerRadius: 6)
                    
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(SkeletonFill())
                        .frame(width: 94, height: 28)
                }
                
                Spacer()
            }
            
            infoRow(width: 210)
            infoRow(width: 180)
        }
        .padding(16)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    private var actionsSkeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectLine(width: 72, height: 18, cornerRadius: 6)
            
            VStack(spacing: 10) {
                actionRowSkeleton
                actionRowSkeleton
                actionRowSkeleton
                actionRowSkeleton
            }
        }
        .padding(16)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    private var quickStatsSkeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectLine(width: 96, height: 18, cornerRadius: 6)
            
            HStack(spacing: 12) {
                statCardSkeleton
                statCardSkeleton
            }
            
            HStack(spacing: 12) {
                statChipSkeleton
                statChipSkeleton
                statChipSkeleton
            }
        }
        .padding(16)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    private var weeklyActivitySkeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                RoundedRectLine(width: 120, height: 18, cornerRadius: 6)
                RoundedRectLine(width: 180, height: 12, cornerRadius: 6)
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                chartColumn(height: 56, label: "M")
                chartColumn(height: 24, label: "T")
                chartColumn(height: 76, label: "W")
                chartColumn(height: 42, label: "T")
                chartColumn(height: 64, label: "F")
                chartColumn(height: 36, label: "S")
                chartColumn(height: 14, label: "S")
            }
        }
        .padding(16)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    private var aboutSkeleton: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectLine(width: 62, height: 18, cornerRadius: 6)
            
            VStack(alignment: .leading, spacing: 10) {
                RoundedRectLine(width: 280, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 245, height: 14, cornerRadius: 6)
                RoundedRectLine(width: 210, height: 14, cornerRadius: 6)
            }
        }
        .padding(16)
        .background(sectionBackground)
        .overlay(sectionBorder)
    }
    
    private var actionRowSkeleton: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 18, height: 18)
            
            RoundedRectLine(width: 130, height: 16, cornerRadius: 6)
            
            Spacer()
            
            RoundedRectLine(width: 8, height: 14, cornerRadius: 4)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var statCardSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(SkeletonFill())
                .frame(width: 18, height: 18)
            
            RoundedRectLine(width: 46, height: 24, cornerRadius: 8)
            RoundedRectLine(width: 92, height: 16, cornerRadius: 6)
            RoundedRectLine(width: 74, height: 12, cornerRadius: 6)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 120, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private var statChipSkeleton: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectLine(width: 42, height: 18, cornerRadius: 6)
            RoundedRectLine(width: 56, height: 12, cornerRadius: 6)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 68, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
    }
    
    private func chartColumn(height: CGFloat, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 88)
                
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(SkeletonFill())
                    .frame(height: height)
            }
            .frame(maxWidth: .infinity)
            
            RoundedRectLine(width: 10, height: 10, cornerRadius: 4)
        }
    }
    
    private func infoRow(width: CGFloat) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(SkeletonFill())
                .frame(width: 14, height: 14)
            
            RoundedRectLine(width: width, height: 14, cornerRadius: 6)
            
            Spacer()
        }
    }
    
    private var sectionBackground: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(Color.white.opacity(0.06))
    }
    
    private var sectionBorder: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .stroke(Color.white.opacity(0.05), lineWidth: 1)
    }
}
