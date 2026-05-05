import SwiftUI
import GymbroCommonUI

struct FeedsProfilePostsView: View {
    
    init(viewModel: FeedsProfilePostsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            backgroundView
            
            Group {
                switch viewModel.screenState {
                case .loading:
                    FeedsViewStub()
                    
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
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var contentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 15) {
                ForEach(viewModel.posts) { post in
                    PostCardView(
                        post: post,
                        mode: .exerciseOnly,
                        onExerciseTap: { exercise in viewModel.didTapExercise(exercise, in: post) }
                    )
                }
            }
            .padding(.horizontal, 7)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .refreshable {
            await viewModel.refresh()
        }
    }
    
    private var backgroundView: some View {
        LinearGradient(
            colors: [
                Color.black,
                Color(red: 12.0 / 255.0, green: 18.0 / 255.0, blue: 36.0 / 255.0),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
    
    @ObservedObject private var viewModel: FeedsProfilePostsViewModel
}
