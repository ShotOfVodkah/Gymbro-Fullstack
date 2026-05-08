import SwiftUI
import GymbroCommonUI

struct FeedsPeopleView: View {

    @State private var contentSafeAreaTop: CGFloat = 0

    init(viewModel: FeedsPeopleViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            switch viewModel.screenState {
            case .loading:
                FeedsPeopleViewStub(topSafeInset: contentSafeAreaTop)
                
            case .loaded:
                contentView
                
            case .error:
                VStack(alignment: .center) {
                    Text(GymbroCommonStrings.genericError)
                        .font(.title3)
                        .foregroundStyle(Color.white)
                    
                    AppButton(GymbroCommonStrings.refresh, size: .xl) {
                        viewModel.reload()
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .sheet(item: $viewModel.selectedPerson, onDismiss: {
            viewModel.dismissPersonSheet()
        }) { person in
            PersonDetailsSheet(
                person: person,
                onFollowTap: { viewModel.toggleFollow(for: person.id) },
                onViewProfileTap: { viewModel.didTapViewProfile(for: person) },
                onViewMessageTap: { viewModel.didTapViewMessage(for: person) }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.clear)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea(.all))
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: FeedsContentSafeAreaTopKey.self,
                    value: proxy.safeAreaInsets.top
                )
            }
        )
        .onPreferenceChange(FeedsContentSafeAreaTopKey.self) { contentSafeAreaTop = $0 }
        .onAppear {
            viewModel.onAppear()
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var contentView: some View {
        ZStack {
            backgroundView
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    header
                        .padding(.top, 4)
                    
                    PeopleSearchBar(text: $viewModel.searchText)
                        .padding(.horizontal, 12)
                    
                    PeopleSegmentPicker(
                        selectedTab: viewModel.selectedTab,
                        availableTabs: viewModel.availableTabs,
                        onSelectTab: viewModel.didSelectTab(_:)
                    )
                    
                    if viewModel.orderedSections.allSatisfy({ $0.people.isEmpty }) {
                        FeedsEmptyStateView(
                            systemImage: "person.2",
                            title: viewModel.emptyStateTitle,
                            subtitle: viewModel.emptyStateSubtitle
                        )
                        .padding(.horizontal, 12)
                        .frame(minHeight: 320)
                    } else {
                        VStack(spacing: 18) {
                            ForEach(viewModel.orderedSections, id: \.title) { section in
                                if !section.people.isEmpty {
                                    PeopleSectionView(
                                        title: section.title,
                                        people: section.people,
                                        currentUserID: viewModel.currentUserID,
                                        onPersonTap: viewModel.didTapPerson(_ :),
                                        onFollowTap: { person in
                                            viewModel.toggleFollow(for: person.id)
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
            .tint(.white)
            .overlay(alignment: .topLeading) {
                UITestMarker(id: "feeds.friends.screen")
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    private var header: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.didTapBack()
            } label: {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 46, height: 46)
                    .overlay(
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
            .buttonStyle(.plain)
            
            Text(viewModel.title)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)
            
            Spacer()
        }
        .padding(.horizontal, 16)
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
    
    @ObservedObject private var viewModel: FeedsPeopleViewModel
}
