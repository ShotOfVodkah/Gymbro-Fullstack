import SwiftUI
import GymbroTypes

struct ChatMessageListView: View {
    
    let sections: [ChatMessageDateSection]
    let selectedMessageID: String?
    let isShowingQuickReactionPicker: Bool
    let onWorkoutTap: (ChatMessage) -> Void
    let onReactionTap: (String, String) -> Void
    let onLongPress: (ChatMessage) -> Void
    let onQuickReactionTap: (String) -> Void
    let onDismissQuickReaction: () -> Void
    let onChallengeTap: (ChatMessage) -> Void
    
    private var lastMessageID: String? {
        sections.last?.messages.last?.id
    }
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 14, pinnedViews: [.sectionHeaders]) {
                    ForEach(sections) { section in
                        Section {
                            VStack(spacing: 14) {
                                ForEach(section.messages) { message in
                                    messageView(for: message)
                                        .id(message.id)
                                        .anchorPreference(
                                            key: ChatMessageAnchorPreferenceKey.self,
                                            value: .bounds
                                        ) { anchor in
                                            [message.id: anchor]
                                        }
                                }
                            }
                        } header: {
                            ChatDateSeparatorView(title: section.title)
                                .padding(.bottom, 6)
                                .background(Color.clear)
                        }
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id("chat-bottom-anchor")
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .onAppear {
                scrollToBottom(scrollProxy, animated: false)
            }
            .onChange(of: lastMessageID) { _, _ in
                scrollToBottom(scrollProxy, animated: true)
            }
            .overlayPreferenceValue(ChatMessageAnchorPreferenceKey.self) { anchors in
                GeometryReader { proxy in
                    if let selectedMessageID,
                       isShowingQuickReactionPicker,
                       let anchor = anchors[selectedMessageID] {
                        
                        let frame = proxy[anchor]
                        
                        ZStack {
                            Color.black.opacity(0.001)
                                .ignoresSafeArea()
                                .onTapGesture {
                                    onDismissQuickReaction()
                                }
                            
                            QuickReactionPickerView(
                                emojis: ["🔥", "💪", "✅", "👏", "❤️"],
                                onSelect: { emoji in
                                    onQuickReactionTap(emoji)
                                }
                            )
                            .position(
                                x: frame.midX,
                                y: max(30, frame.minY - 40)
                            )
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func messageView(for message: ChatMessage) -> some View {
        switch message.kind {
        case .text:
            ChatTextMessageBubbleView(
                message: message,
                onReactionTap: { emoji in
                    onReactionTap(emoji, message.id)
                },
                onLongPress: {
                    onLongPress(message)
                }
            )
            
        case .workout:
            ChatWorkoutMessageCardView(
                message: message,
                onTap: { onWorkoutTap(message) },
                onReactionTap: { emoji in
                    onReactionTap(emoji, message.id)
                },
                onLongPress: {
                    onLongPress(message)
                }
            )
        case .challengeSystem:
            ChatChallengeSystemMessageCardView(
                message: message,
                onTap: { onChallengeTap(message) },
                onReactionTap: { emoji in
                    onReactionTap(emoji, message.id)
                },
                onLongPress: {
                    onLongPress(message)
                }
            )
        }
    }
    
    private func scrollToBottom(
        _ proxy: ScrollViewProxy,
        animated: Bool
    ) {
        guard lastMessageID != nil else { return }
        
        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("chat-bottom-anchor", anchor: .bottom)
                }
            } else {
                proxy.scrollTo("chat-bottom-anchor", anchor: .bottom)
            }
        }
    }
}
