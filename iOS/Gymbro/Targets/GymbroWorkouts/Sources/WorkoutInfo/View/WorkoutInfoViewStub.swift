import SwiftUI
import GymbroCommonUI

struct WorkoutInfoViewStub: View {
    var body: some View {
        VStack(spacing: 0) {
            buttonsRow
            headerCard
                .padding(.horizontal, 16)
                .padding(.top, 10)

            sectionTitle
                .padding(.top, 17)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { _ in
                        exerciseCardSkeleton
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            startButtonSkeleton
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 12)
        }
        .shimmer(active: true)
    }

    private var buttonsRow: some View {
        HStack {
            Spacer()

            HStack(spacing: 12) {
                actionPillIcon
                actionPillIcon
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .padding(.bottom, 12)
        }
    }

    private var actionPillIcon: some View {
        ZStack {
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.60),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            Capsule()
                .fill(Color.white.opacity(0.35))

            Capsule()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)

            RoundedRectLine(width: 21, height: 21, cornerRadius: 6)
        }
        .frame(width: 44, height: 44)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            RoundedRectLine(width: 220, height: 22, cornerRadius: 7)
                .padding(.top, 18)

            HStack(spacing: 10) {
                headerPillSkeleton(iconSize: 20, textWidth: 110)
                headerPillSkeleton(iconSize: 20, textWidth: 120)
            }
            .padding(.top, 15)
            .padding(.bottom, 18)
        }
        .padding(.horizontal, 15)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.18),
                    Color.white.opacity(0.55)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func headerPillSkeleton(iconSize: CGFloat, textWidth: CGFloat) -> some View {
        HStack(spacing: 10) {
            RoundedRectLine(width: iconSize, height: iconSize, cornerRadius: 6)
            RoundedRectLine(width: textWidth, height: 15, cornerRadius: 6)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.20))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var sectionTitle: some View {
        HStack {
            RoundedRectLine(width: 110, height: 16, cornerRadius: 6)
            Spacer()
        }
        .padding(.horizontal, 25)
    }

    private var exerciseCardSkeleton: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                // номер
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.black.opacity(0.22))
                    .frame(width: 38, height: 38)
                    .overlay(
                        RoundedRectLine(width: 14, height: 14, cornerRadius: 6)
                    )

                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectLine(width: 200, height: 18, cornerRadius: 7)
                    RoundedRectLine(width: 120, height: 14, cornerRadius: 6)
                }

                Spacer(minLength: 0)

                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.black.opacity(0.22))
                    .frame(width: 90, height: 30)
                    .overlay(
                        RoundedRectLine(width: 65, height: 14, cornerRadius: 6)
                    )
            }

            HStack(spacing: 10) {
                statPillSkeleton
                statPillSkeleton
                statPillSkeleton
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 14)
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.45),
                    Color.white.opacity(0.30)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var statPillSkeleton: some View {
        VStack(spacing: 8) {
            RoundedRectLine(width: 60, height: 12, cornerRadius: 6)
            RoundedRectLine(width: 48, height: 12, cornerRadius: 6)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(Color.black.opacity(0.22))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var startButtonSkeleton: some View {
        ZStack {
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.60),
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            Capsule()
                .fill(Color.white.opacity(0.4))

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

            RoundedRectLine(width: 160, height: 18, cornerRadius: 7)
        }
        .frame(height: 56)
    }
}



