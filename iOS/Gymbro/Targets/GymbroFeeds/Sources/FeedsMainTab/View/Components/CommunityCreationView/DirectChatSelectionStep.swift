import SwiftUI

struct DirectChatSelectionStep: View {
    
    @ObservedObject var viewModel: FeedsMainTabViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            
            PeopleSearchBar(text: $viewModel.directChatSearchText)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    ForEach(viewModel.directChatSelectablePeople) { person in
                        PersonRowView(
                            person: person,
                            isCurrentUser: person.id == viewModel.currentUserID,
                            isFollowEnabled: false,
                            onTap: { viewModel.didSelectDirectPerson(person) },
                            onFollowTap: { }
                        )
                    }
                }
            }
        }
    }
    
    private var header: some View {
        ChatCreationHeaderView(
            title: String(localized: "feeds.chat.direct.choose_person", bundle: .module),
            onBackTap: viewModel.goBackInChatCreationFlow
        )
    }
}
