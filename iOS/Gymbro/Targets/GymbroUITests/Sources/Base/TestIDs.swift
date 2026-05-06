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
}
