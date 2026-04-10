import SwiftUI
import GymbroCommonUI

struct ChatView: View {
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    ChatViewStub()
                case .loaded:
                    contentView
                case .error:
                    VStack(alignment: .center) {
                        Text("Something went wrong, oopsie...")
                            .font(.title3)
                            .foregroundStyle(.white)
                        
                        AppButton("Refresh", size: .xl) {
                            viewModel.reload()
                        }
                    }
                    .padding(.horizontal, 40)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingGroupInfo) {
            if let groupInfo = viewModel.groupInfo {
                GroupInfoSheetView(
                    info: groupInfo,
                    onUpdate: viewModel.updateGroupInfo(title:description:),
                    onDelete: viewModel.deleteGroup,
                    onRemovePerson: viewModel.removePersonFromGroup(_:),
                    onAddPeople: viewModel.addPeopleToGroup(_:)
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(.clear)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var contentView: some View {
        VStack(spacing: 0) {
            ChatHeaderView(
                title: viewModel.title,
                isGroup: viewModel.isGroup,
                onBackTap: viewModel.didTapBack,
                onTitleTap: viewModel.didTapHeaderTitle,
                onCalendarTap: viewModel.didTapCalendar
            )
            
            ChatMessageListView(
                sections: viewModel.messageSections,
                selectedMessageID: viewModel.selectedMessageForQuickReaction?.id,
                isShowingQuickReactionPicker: viewModel.isShowingQuickReactionPicker,
                onWorkoutTap: viewModel.didTapWorkoutMessage(_:),
                onReactionTap: viewModel.toggleReaction(_:for:),
                onLongPress: viewModel.didLongPressMessage(_:),
                onQuickReactionTap: viewModel.addQuickReaction(_:),
                onDismissQuickReaction: viewModel.hideQuickReactionPicker
            )
            
            ChatInputBarView(
                text: $viewModel.draftText,
                onSendTap: viewModel.sendMessage
            )
        }
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
    
    @ObservedObject private var viewModel: ChatViewModel
}
