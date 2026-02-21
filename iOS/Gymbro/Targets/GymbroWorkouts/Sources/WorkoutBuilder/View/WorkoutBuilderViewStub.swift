import SwiftUI
import GymbroCommonUI

struct WorkoutBuilderViewStub: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                header
                    .padding(.top, 16)

                aiCard
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                categoriesSection
                    .padding(.top, 18)

                premadeSection
                    .padding(.top, 22)
                    .padding(.bottom, 24)
            }
        }
        .shimmer(active: true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectLine(width: 240, height: 26, cornerRadius: 9)
                .padding(.leading, 45)

            RoundedRectLine(width: 300, height: 16, cornerRadius: 7)
                .padding(.horizontal, 20)
                .padding(.top, 10)

            RoundedRectLine(width: 260, height: 16, cornerRadius: 7)
                .padding(.horizontal, 20)
                .padding(.top, 6)
        }
    }

    private var aiCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                pillIcon
                Spacer()
            }
            .padding(.top, 16)

            RoundedRectLine(width: 220, height: 20, cornerRadius: 8)
                .padding(.top, 14)

            RoundedRectLine(width: 300, height: 16, cornerRadius: 7)
                .padding(.top, 12)

            RoundedRectLine(width: 260, height: 16, cornerRadius: 7)
                .padding(.top, 6)

            aiButtonSkeleton
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.65),
                    Color.white.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var pillIcon: some View {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(Color.white.opacity(0.35))
            .frame(width: 44, height: 44)
            .overlay(
                RoundedRectLine(width: 18, height: 18, cornerRadius: 6)
            )
    }

    private var aiButtonSkeleton: some View {
        ZStack {
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.40),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            Capsule()
                .fill(Color.white.opacity(0.30))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.22),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)

            RoundedRectLine(width: 120, height: 16, cornerRadius: 7)
        }
        .frame(height: 56)
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                RoundedRectLine(width: 170, height: 16, cornerRadius: 7)
                Spacer()
            }
            .padding(.horizontal, 16)

            HStack(spacing: 12) {
                categoryCardSkeleton
                categoryCardSkeleton
                categoryCardSkeleton
            }
            .padding(.top, 14)
            .padding(.horizontal, 16)
        }
    }

    private var categoryCardSkeleton: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.18))
                .frame(width: 54, height: 54)
                .overlay(
                    RoundedRectLine(width: 26, height: 26, cornerRadius: 8)
                )
                .padding(.top, 18)

            RoundedRectLine(width: 80, height: 14, cornerRadius: 6)
                .padding(.top, 12)

            Spacer(minLength: 0)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.65),
                    Color.white.opacity(0.35)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var premadeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                RoundedRectLine(width: 150, height: 16, cornerRadius: 7)
                Spacer()
            }
            .padding(.horizontal, 16)

            pagerSkeleton
                .padding(.top, 14)

            indicatorSkeleton
                .padding(.top, 12)
                .padding(.horizontal, 10)
        }
    }

    private var pagerSkeleton: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(0..<5, id: \.self) { _ in
                    premadeCardSkeleton
                        .frame(width: 320, height: 220)
                }
            }
            .padding(.horizontal, 10)
        }
    }

    private var premadeCardSkeleton: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white.opacity(0.45))

                RoundedRectLine(width: 180, height: 18, cornerRadius: 7)
            }
            .frame(height: 64)
            .padding(.top, 16)
            .padding(.horizontal, 16)

            RoundedRectLine(width: 200, height: 14, cornerRadius: 6)
                .padding(.top, 16)
                .padding(.horizontal, 20)

            Spacer(minLength: 0)
        }
        .background(Color.white.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var indicatorSkeleton: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.white.opacity(0.55))
                .frame(width: 20, height: 10)

            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.gray.opacity(0.35))
                    .frame(width: 10, height: 10)
            }

            Spacer(minLength: 0)
        }
    }
}
