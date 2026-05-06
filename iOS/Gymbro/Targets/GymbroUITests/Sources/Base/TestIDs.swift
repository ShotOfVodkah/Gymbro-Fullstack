enum TestIDs {

    enum App {
        static let root = "app.root"
        static let mainContent = "app.main.content"
    }

    enum Auth {
        static let screen = "auth.screen"
        static let emailTextField = "auth.email.textfield"
        static let passwordSecureField = "auth.password.securefield"
        static let loginButton = "auth.login.button"
        static let registerButton = "auth.register.button"
        
        static let loginSegment = "auth.segment.login"
        static let registerSegment = "auth.segment.register"

        static let athleteRole = "auth.role.athlete"
        static let coachRole = "auth.role.coach"

        static let checkEmailScreen = "auth.check_email.screen"
    }
    
    enum Profile {
        static let settingsButton = "profile.settings.button"
    }

    enum Settings {
        static let logoutButton = "profile.settings.logout.button"
    }

    enum Tab {
        static let workouts = "tab.workouts"
        static let feeds = "tab.feeds"
        static let profile = "tab.profile"
        static let challenge = "tab.challenge"
        static let perks = "tab.perks"
    }

    enum Screen {
        static let workouts = "workouts.list.screen"
        static let feeds = "feeds.main.screen"
        static let profile = "profile.main.screen"
        static let challenges = "challenges.main.screen"
        static let perks = "perks.main.screen"
    }

    enum Debug {
        static let mockNetwork = "debug.network.mock"
        static let realNetwork = "debug.network.real"
    }

    enum Feeds {
        static let contentLoaded = "feeds.content.loaded"
        static let topBarFriends = "feeds.topbar.friends"
        static let topBarCalendar = "feeds.topbar.calendar"
        static let friendsScreen = "feeds.friends.screen"
        static let calendarScreen = "feeds.calendar.screen"
        static let chatScreen = "feeds.chat.screen"
        static let chatInput = "feeds.chat.input"
        static let chatSend = "feeds.chat.send"
        static let commentsSheet = "feeds.comments.sheet"
        static let commentsInput = "feeds.comments.input"
        static let commentsSend = "feeds.comments.send"
        static let workoutShareOptionFeed = "feeds.workoutShare.option.feed"
        static let workoutSharePrimary = "feeds.workoutShare.primary"
        static let workoutShareSuccess = "feeds.workoutShare.success"
        static let workoutInfoScreen = "workout.info.screen"
        static let profileOtherUser = "profile.other.user.screen"

        static func feedTab(_ rawValue: String) -> String { "feeds.tab.\(rawValue)" }
        static func postLike(_ postID: String) -> String { "feeds.post.\(postID).like" }
        static func postComments(_ postID: String) -> String { "feeds.post.\(postID).comments" }
        static func postAuthor(_ postID: String) -> String { "feeds.post.\(postID).author" }
        static func postDoubleTapArea(_ postID: String) -> String { "feeds.post.\(postID).doubleTapLikeArea" }
        static func postExercise(_ postID: String, index: Int) -> String { "feeds.post.\(postID).exercise.\(index)" }
        static func community(_ id: String) -> String { "feeds.community.\(id)" }
    }
}
