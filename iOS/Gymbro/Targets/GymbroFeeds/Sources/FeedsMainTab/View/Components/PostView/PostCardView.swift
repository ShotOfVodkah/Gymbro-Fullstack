import SwiftUI

struct PostCardView: View {
    
    let post: FeedPost
    let onAuthorTap: () -> Void
//    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentTap: () -> Void
    let onExerciseTap: (FeedExercise) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            PostHeaderView(
                avatar: post.authorAvatar,
                authorName: post.authorName,
                postedAt: post.postedAt,
                onAuthorTap: onAuthorTap
            )

//            Button(action: onTap) {
//                feedImage(post.coverImageName)
//                    .frame(height: 130)
//                    .clipShape(RoundedRectangle(cornerRadius: 26))
//            }
//            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 14) {
                Text(post.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)

                PostMetaTagsView(
                    category: post.category,
                    duration: post.duration,
                    timeAgo: post.timeAgo
                )

                if let location = post.location {
                    HStack(spacing: 8) {
                        Image(systemName: "location.fill")
                            .foregroundStyle(.gray)
                        Text(location)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                }

                Text(post.description)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.95))
                    .fixedSize(horizontal: false, vertical: true)

                Text("Exercises")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .textCase(.uppercase)

                VStack(spacing: 12) {
                    ForEach(Array(post.exercises.prefix(2).enumerated()), id: \.element.id) { index, exercise in
                        ExercisePreviewCardView(
                            exercise: exercise,
                            index: index + 1
                        ) {
                            onExerciseTap(exercise)
                        }
                    }

                    if post.exercises.count > 2 {
                        Button {
                            print("Mock: show all exercises")
                        } label: {
                            Text("Show all")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.white.opacity(0.06))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Divider()
                    .overlay(Color.white.opacity(0.8))

                PostActionsView(
                    likesCount: post.likesCount,
                    commentsCount: post.commentsCount,
                    isLiked: post.isLiked,
                    onLikeTap: onLikeTap,
                    onCommentTap: onCommentTap
                )
            }
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: [
                Color(red: 18/255, green: 24/255, blue: 42/255),
                Color(red: 19/255, green: 30/255, blue: 56/255)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.7)
    }

//    @ViewBuilder
//    private func feedImage(_ name: String) -> some View {
//        if UIImage(named: name) != nil {
//            Image(name)
//                .resizable()
//                .scaledToFill()
//        } else {
//            Rectangle()
//                .fill(
//                    LinearGradient(
//                        colors: [Color.gray.opacity(0.6), Color.appPurple.opacity(0.5)],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .overlay(
//                    Image(systemName: "photo")
//                        .font(.system(size: 34))
//                        .foregroundStyle(.white.opacity(0.8))
//                )
//        }
//    }
}
