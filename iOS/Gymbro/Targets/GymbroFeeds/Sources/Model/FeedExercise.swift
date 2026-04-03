import Foundation

struct FeedExercise: Identifiable, Hashable {
    let id: UUID
    let title: String
    let subtitle: String
    let imageName: String

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        imageName: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
}
