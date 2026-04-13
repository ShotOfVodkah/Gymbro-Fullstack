import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct FeedCommentsSheetView: View {
    
    let post: FeedPost?
    let comments: [FeedComment]
    @Binding var draftText: String
    let isLoading: Bool
    let onSendTap: () -> Void
    
    var body: some View {
        ZStack {
            backgroundView
            
            VStack(spacing: 0) {
                header
                
                Divider()
                    .overlay(Color.white.opacity(0.08))
                
                content
                
                Divider()
                    .overlay(Color.white.opacity(0.08))
                
                inputBar
            }
        }
    }
    
    private var header: some View {
        VStack(spacing: 8) {
            Text("Comments")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
            
            if let post {
                Text(post.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private var content: some View {
        if isLoading {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(.white)
                
                Text("Loading comments...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            
        } else if comments.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("No comments yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                
                Text("Be the first to say something")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 12) {
                    ForEach(comments) { comment in
                        commentRow(comment)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }
    
    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Write a comment...", text: $draftText, axis: .vertical)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .lineLimit(1...4)
            
            Button(action: onSendTap) {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.appPurple)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 18)
    }
    
    private func commentRow(_ comment: FeedComment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.appPurple.opacity(0.75))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: comment.authorAvatarSystemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(comment.authorName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(comment.timeAgo)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Text(comment.text)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.92))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 18.0 / 255.0, green: 20.0 / 255.0, blue: 28.0 / 255.0),
                Color(red: 28.0 / 255.0, green: 32.0 / 255.0, blue: 42.0 / 255.0),
                Color(red: 20.0 / 255.0, green: 24.0 / 255.0, blue: 34.0 / 255.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
