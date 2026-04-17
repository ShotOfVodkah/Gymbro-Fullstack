import SwiftUI
import GymbroCommonUI
import GymbroTypes

struct GroupChatCreationStep: View {
    
    @ObservedObject var viewModel: FeedsMainTabViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            groupNameField
            
            Text(String(localized: "feeds.chat.group.select_members_title", bundle: .module))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
            
            PeopleSearchBar(text: $viewModel.groupChatSearchText)
            
            Text(FeedsL10n.groupSelectedLine(count: viewModel.chatCreationDraft.selectedGroupMembers.count))
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(viewModel.groupChatSelectablePeople) { person in
                        selectableRow(person)
                    }
                }
            }
            
            AppButton(
                String(localized: "feeds.chat.group.create_chat_action", bundle: .module),
                size: .l,
                action: viewModel.createGroupChat,
                wrapContent: false
            )
            .opacity(viewModel.canCreateGroupChat ? 1 : 0.5)
            .disabled(!viewModel.canCreateGroupChat)
        }
    }
    
    private var header: some View {
        ChatCreationHeaderView(
            title: String(localized: "feeds.chat.group.header_create", bundle: .module),
            onBackTap: viewModel.goBackInChatCreationFlow
        )
    }
    
    private var groupNameField: some View {
        TextField(
            String(localized: "feeds.chat.group.name_placeholder", bundle: .module),
            text: Binding(
                get: { viewModel.chatCreationDraft.groupName },
                set: { viewModel.updateGroupName($0) }
            )
        )
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private func selectableRow(_ person: PersonItem) -> some View {
        let isSelected = viewModel.chatCreationDraft.selectedGroupMembers.contains(person)
        
        return Button {
            viewModel.toggleGroupMember(person)
        } label: {
            HStack(spacing: 14) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.appPurple, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: person.avatarSystemName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(person.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(person.username)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.appPurple : .white.opacity(0.45))
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }
}
