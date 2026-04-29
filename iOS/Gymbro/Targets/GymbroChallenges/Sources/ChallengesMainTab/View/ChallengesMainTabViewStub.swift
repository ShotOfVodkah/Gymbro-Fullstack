import SwiftUI
import GymbroCommonUI

struct ChallengesViewStub: View {
    
    var body: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    headerSkeleton
                    featuredSkeleton
                    statsSkeleton
                    filterSkeleton
                    categorySkeleton
                    sectionSkeleton(titleWidth: 170, subtitleWidth: 210)
                    sectionSkeleton(titleWidth: 190, subtitleWidth: 240)
                }
                .padding(.horizontal, 15)
                .padding(.top, 18)
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
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectLine(width: 190, height: 34, cornerRadius: 10)
            
            VStack(alignment: .leading, spacing: 7) {
                RoundedRectLine(width: 310, height: 14, cornerRadius: 7)
                RoundedRectLine(width: 240, height: 14, cornerRadius: 7)
            }
        }
    }
    
    private var featuredSkeleton: some View {
        VStack(alignment: .leading, spacing: 13) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: 190, height: 24, cornerRadius: 8)
                RoundedRectLine(width: 260, height: 13, cornerRadius: 7)
            }
            
            challengeCardSkeleton
        }
    }
    
    private var statsSkeleton: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            ForEach(0..<4, id: \.self) { _ in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(SkeletonFill())
                        .frame(width: 42, height: 42)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectLine(width: 34, height: 20, cornerRadius: 7)
                        RoundedRectLine(width: 72, height: 12, cornerRadius: 6)
                    }
                    
                    Spacer(minLength: 0)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.055))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
            }
        }
    }
    
    private var filterSkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                pill(width: 56)
                pill(width: 78)
                pill(width: 92)
                pill(width: 104)
                pill(width: 94)
            }
        }
    }
    
    private var categorySkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 11) {
                categoryPill(width: 108)
                categoryPill(width: 96)
                categoryPill(width: 88)
                categoryPill(width: 104)
                categoryPill(width: 86)
            }
        }
    }
    
    private func sectionSkeleton(
        titleWidth: CGFloat,
        subtitleWidth: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: 13) {
            VStack(alignment: .leading, spacing: 6) {
                RoundedRectLine(width: titleWidth, height: 23, cornerRadius: 8)
                RoundedRectLine(width: subtitleWidth, height: 13, cornerRadius: 7)
            }
            
            VStack(spacing: 12) {
                challengeCardSkeleton
                challengeCardSkeleton
            }
        }
    }
    
    private var challengeCardSkeleton: some View {
        VStack(alignment: .leading, spacing: 18) {
            cardHeaderSkeleton
            progressSkeleton
            metaSkeleton
            footerSkeleton
        }
        .padding(20)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
    
    private var cardHeaderSkeleton: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectLine(width: 180, height: 18, cornerRadius: 7)
                RoundedRectLine(width: 260, height: 13, cornerRadius: 7)
                RoundedRectLine(width: 210, height: 13, cornerRadius: 7)
            }
            
            Spacer()
            
            Circle()
                .fill(SkeletonFill())
                .frame(width: 52, height: 52)
        }
    }
    
    private var progressSkeleton: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                RoundedRectLine(width: 155, height: 22, cornerRadius: 8)
                
                Spacer()
                
                RoundedRectLine(width: 42, height: 15, cornerRadius: 6)
            }
            
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(SkeletonFill())
                .frame(height: 12)
            
            RoundedRectLine(width: 150, height: 12, cornerRadius: 6)
        }
    }
    
    private var metaSkeleton: some View {
        HStack(spacing: 10) {
            metaPillSkeleton
            metaPillSkeleton
        }
    }
    
    private var metaPillSkeleton: some View {
        VStack(alignment: .leading, spacing: 7) {
            RoundedRectLine(width: 70, height: 12, cornerRadius: 6)
            RoundedRectLine(width: 105, height: 14, cornerRadius: 7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.07))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.04), lineWidth: 1)
        )
    }
    
    private var footerSkeleton: some View {
        HStack(spacing: 8) {
            pill(width: 78)
            pill(width: 98)
            
            Spacer()
            
            RoundedRectLine(width: 78, height: 12, cornerRadius: 6)
        }
    }
    
    private func pill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 999, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 34)
    }
    
    private func categoryPill(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(SkeletonFill())
            .frame(width: width, height: 40)
    }
    
    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18 / 255, green: 24 / 255, blue: 42 / 255).opacity(0.75),
                Color(red: 19 / 255, green: 30 / 255, blue: 56 / 255).opacity(0.65)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
