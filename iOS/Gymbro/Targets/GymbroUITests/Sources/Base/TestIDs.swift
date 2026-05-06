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
        static let myLoaded = "profile.my.loaded"
        static let otherUserScreen = "profile.other.user.screen"
        static let editScreen = "profile.edit.screen"
        static let editCancel = "profile.edit.cancel"
        static let editSave = "profile.edit.save"
        static let editFullName = "profile.edit.field.fullName"
        static let editUsername = "profile.edit.field.username"
        static let editStatus = "profile.edit.field.status"
        static let editSubtitle = "profile.edit.field.subtitle"
        static let editBio = "profile.edit.field.bio"
        static let statisticsScreen = "profile.statistics.screen"
        static let settingsScreen = "profile.settings.screen"
        static let actionEditProfile = "profile.action.edit_profile.button"
        static let actionStatistics = "profile.action.statistics.button"
        static let actionLogout = "profile.action.logout.button"
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

    enum Workouts {
        static let listLoaded = "workouts.list.loaded"
        static let infoScreen = "workout.info.screen"
        static let infoBack = "workouts.info.back"

        static let playerLoaded = "workouts.player.loaded"
        static let playerBack = "workouts.player.back"
        static let playerFinish = "workouts.player.finish"

        static let finishSaveOnly = "workouts.finish.save_only"
        static let finishShare = "workouts.finish.share"

        static let shareLoaded = "workouts.share.loaded"

        static let builderLoaded = "workouts.builder.loaded"
        static let builderBack = "workouts.builder.back"

        static let builderForTypeLoaded = "workouts.builderForType.loaded"
        static let builderForTypeBack = "workouts.builderForType.back"
        static let builderForTypeSave = "workouts.builderForType.save"
        static let builderName = "workouts.builder.name"

        static let generatorLoaded = "workouts.generator.loaded"
        static let generatorBack = "workouts.generator.back"
        static let generatorPrompt = "workouts.generator.prompt"
        static let generatorGenerate = "workouts.generator.generate"
        static let generatorResultSave = "workouts.generator.result.save"

        static let offlineBanner = "workouts.offline.banner"
    }

    enum Challenges {
        static let listLoaded = "challenges.list.loaded"
        static let detailsLoaded = "challenges.details.loaded"
        static let detailsBack = "challenges.details.back"
        static let detailsLeave = "challenges.details.leave"
        static let detailsLeaderboardViewAll = "challenges.details.leaderboard.viewAll"

        static let joinLoaded = "challenges.join.loaded"
        static let joinBack = "challenges.join.back"
        static let joinConfirm = "challenges.join.confirm"
        static let joinConfirmCancel = "challenges.join.confirm.cancel"
        static let joinSuccess = "challenges.join.success"
        static let joinSuccessDone = "challenges.join.success.done"

        static let leaderboardLoaded = "challenges.leaderboard.loaded"
        static let leaderboardBack = "challenges.leaderboard.back"

        static func card(_ id: String) -> String { "challenges.card.\(id)" }
        static func cardJoin(_ id: String) -> String { "challenges.card.\(id).join" }
        static func joinTeam(_ chatID: String) -> String { "challenges.join.team.\(chatID)" }
    }

    enum Perks {
        static let dashboardLoaded = "perks.dashboard.loaded"
        static let streakCard = "perks.streak.card"
        static let recentUnlocksSection = "perks.recentUnlocks.section"
        static let achievementsSection = "perks.achievements.section"
        static let leaderboardSection = "perks.leaderboard.section"
        static let leaderboardMyRank = "perks.leaderboard.myRank"
        static let achievementExpanded = "perks.achievement.expanded"
        static let achievementExpandedClose = "perks.achievement.expanded.close"

        static let streakStateNormal = "perks.streak.state.normal"
        static let streakStateCompleted = "perks.streak.state.completed"
        static let streakStateFreeze = "perks.streak.state.freeze"
        static let streakStateDanger = "perks.streak.state.danger"

        static func achievementCard(_ code: String) -> String { "perks.achievement.card.\(code)" }
        static func achievementCategory(_ rawValue: String) -> String { "perks.achievements.category.\(rawValue)" }
        static func leaderboardFilter(_ rawValue: String) -> String { "perks.leaderboard.filter.\(rawValue)" }
        static func leaderboardSort(_ rawValue: String) -> String { "perks.leaderboard.sort.\(rawValue)" }
        static func leaderboardRow(_ id: String) -> String { "perks.leaderboard.row.\(id)" }
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
