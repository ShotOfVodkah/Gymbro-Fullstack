import SwiftUI

struct ChatCreationSheet: View {
    
    @ObservedObject var viewModel: FeedsMainTabViewModel
    
    var body: some View {
        ZStack {
            backgroundView
            
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 24)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.chatCreationStep {
        case .chooseType:
            ChatTypeSelectionStep(
                onDirectTap: viewModel.didChooseDirectChat,
                onGroupTap: viewModel.didChooseGroupChat
            )
        case .chooseDirectPerson:
            DirectChatSelectionStep(viewModel: viewModel)
        case .createGroup:
            GroupChatCreationStep(viewModel: viewModel)
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color(red: 18.0/255.0, green: 20.0/255.0, blue: 28.0/255.0),
                Color(red: 28.0/255.0, green: 32.0/255.0, blue: 42.0/255.0),
                Color(red: 20.0/255.0, green: 24.0/255.0, blue: 34.0/255.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
