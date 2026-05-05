import ProjectDescription

// General variables

private let bundleId: String = "dev.tuist.Gymbro"
private let version: String = "0.0.1"
private let bundleVersion: String = "1"
private let iOSTargetVersion: String = "17.0"
private let basePath = "Targets"

// Targets

let mainAppTarget: ProjectDescription.Target = .target(
    name: "Gymbro",
    destinations: .iOS,
    product: .app,
    bundleId: bundleId,
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:],
            "CFBundleDevelopmentRegion": "en",
            "CFBundleLocalizations": ["en", "ru"],
            "CFBundleAllowMixedLocalizations": true,
            "CFBundleURLTypes": [
                [
                    "CFBundleURLName": "dev.tuist.Gymbro",
                    "CFBundleURLSchemes": [
                        "gymbro"
                    ]
                ]
            ]
        ]
    ),
    sources: ["\(basePath)/Gymbro/Sources/**"],
    resources: ["\(basePath)/Gymbro/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroWorkouts"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroTypes"),
        .target(name: "GymbroFeeds"),
        .target(name: "GymbroAuth"),
        .target(name: "GymbroProfile"),
        .target(name: "GymbroAnalytics"),
        .target(name: "GymbroPerks"),
        .target(name: "GymbroChallenges"),
        .target(name: "GymBroWatch"),
        .target(name: "GymbroWidgetExtension")
    ],
    settings: baseSettings(entitlements: "\(basePath)/Gymbro/Gymbro.entitlements")
)

let networkTarget: ProjectDescription.Target = .target(
    name: "GymbroNetwork",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).network",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroNetwork/Sources/**"],
    resources: ["\(basePath)/GymbroNetwork/Resources/**"],
    dependencies: [
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

let navigationTarget: ProjectDescription.Target = .target(
    name: "GymbroNavigation",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).navigation",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroNavigation/Sources/**"],
    resources: ["\(basePath)/GymbroNavigation/Resources/**"],
    dependencies: [
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

let gymbroCommonUITests: ProjectDescription.Target = .target(
    name: "GymbroCommonUITests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "\(bundleId).GymbroCommonUITests",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(with: [:]),
    sources: ["\(basePath)/GymbroCommonUI/Tests/**"],
    dependencies: [
        .target(name: "GymbroCommonUI"),
        .external(name: "SnapshotTesting")
    ],
    settings: baseSettings()
)

let commonUITarget: ProjectDescription.Target = .target(
    name: "GymbroCommonUI",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).commonUI",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroCommonUI/Sources/**"],
    resources: ["\(basePath)/GymbroCommonUI/Resources/**"],
    dependencies: [
        .external(name: "Lottie")
    ],
    settings: baseSettings()
)

let typesTarget: ProjectDescription.Target = .target(
    name: "GymbroTypes",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).workouts",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroTypes/Sources/**"],
    resources: ["\(basePath)/GymbroTypes/Resources/**"],
    dependencies: [],
    settings: baseSettings()
)

let workoutsTarget: ProjectDescription.Target = .target(
    name: "GymbroWorkouts",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).workouts",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroWorkouts/Sources/**"],
    resources: ["\(basePath)/GymbroWorkouts/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroTypes"),
        .external(name: "DivKit")
    ],
    settings: baseSettings()
)

let gymbroWorkoutsTests: ProjectDescription.Target = .target(
    name: "GymbroWorkoutsTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "\(bundleId).GymbroWorkoutsTests",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(with: [:]),
    sources: ["\(basePath)/GymbroWorkouts/Tests/**"],
    dependencies: [
        .target(name: "GymbroWorkouts"),
        .external(name: "SnapshotTesting")
    ],
    settings: baseSettings()
)

let feedsTarget: ProjectDescription.Target = .target(
    name: "GymbroFeeds",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).feeds",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroFeeds/Sources/**"],
    resources: ["\(basePath)/GymbroFeeds/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

let gymbroFeedsTests: ProjectDescription.Target = .target(
    name: "GymbroFeedsTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "\(bundleId).GymbroFeedsTests",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(with: [:]),
    sources: ["\(basePath)/GymbroFeeds/Tests/**"],
    dependencies: [
        .target(name: "GymbroFeeds"),
        .external(name: "SnapshotTesting")
    ],
    settings: baseSettings()
)

let authTarget: ProjectDescription.Target = .target(
    name: "GymbroAuth",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).auth",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroAuth/Sources/**"],
    resources: ["\(basePath)/GymbroAuth/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

let profileTarget: ProjectDescription.Target = .target(
    name: "GymbroProfile",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).profile",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroProfile/Sources/**"],
    resources: ["\(basePath)/GymbroProfile/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroTypes"),
        .target(name: "GymbroAuth")
    ],
    settings: baseSettings()
)

let gymbroProfileTests: ProjectDescription.Target = .target(
    name: "GymbroProfileTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "\(bundleId).GymbroProfileTests",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(with: [:]),
    sources: ["\(basePath)/GymbroProfile/Tests/**"],
    dependencies: [
        .target(name: "GymbroProfile"),
        .external(name: "SnapshotTesting")
    ],
    settings: baseSettings()
)

let perksTarget: ProjectDescription.Target = .target(
    name: "GymbroPerks",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).perks",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroPerks/Sources/**"],
    resources: ["\(basePath)/GymbroPerks/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

let challengesTarget: ProjectDescription.Target = .target(
    name: "GymbroChallenges",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).challenges",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroChallenges/Sources/**"],
    resources: ["\(basePath)/GymbroChallenges/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroNavigation"),
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

let analyticsTarget: ProjectDescription.Target = .target(
    name: "GymbroAnalytics",
    destinations: .iOS,
    product: .staticFramework,
    bundleId: "\(bundleId).analytics",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/GymbroAnalytics/Sources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings()
)

// watchOS

let watchOSTarget: ProjectDescription.Target = .target(
    name: "GymBroWatch",
    destinations: .watchOS,
    product: .app,
    bundleId: "\(bundleId).watchkitapp",
    deploymentTargets: .watchOS("9.0"),
    infoPlist: InfoPlist.extendingDefault(with: [
        "WKApplication": true,
        "WKCompanionAppBundleIdentifier": "\(bundleId)",
        "CFBundleDevelopmentRegion": "en",
        "CFBundleLocalizations": ["en", "ru"],
        "CFBundleAllowMixedLocalizations": true
        ]
    ),
    sources: ["\(basePath)/GymbroWatchApp/Sources/**"],
    resources: ["\(basePath)/GymbroWatchApp/Resources/**"],
    dependencies: []
)

let widgetExtensionTarget: ProjectDescription.Target = .target(
    name: "GymbroWidgetExtension",
    destinations: .iOS,
    product: .appExtension,
    bundleId: "\(bundleId).widget",
    deploymentTargets: .iOS(iOSTargetVersion),
    infoPlist: .extendingDefault(
        with: [
            "CFBundleDevelopmentRegion": "en",
            "CFBundleLocalizations": ["en", "ru"],
            "CFBundleAllowMixedLocalizations": true,
            "NSExtension": [
                "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
            ]
        ]
    ),
    sources: ["\(basePath)/GymbroWidgetExtension/Sources/**"],
    resources: ["\(basePath)/GymbroWidgetExtension/Resources/**"],
    dependencies: [
        .target(name: "GymbroCommonUI"),
        .target(name: "GymbroTypes")
    ],
    settings: baseSettings(entitlements: "\(basePath)/GymbroWidgetExtension/GymbroWidgetExtension.entitlements")
)

// Schemes

let gymbroWorkoutsTestsScheme: Scheme = .scheme(
    name: "GymbroWorkoutsTests",
    shared: true,
    buildAction: .buildAction(
        targets: [TargetReference(stringLiteral: "GymbroWorkoutsTests")],
        preActions: [],
        postActions: []
    ),
    testAction: .targets(
        [TestableTarget(stringLiteral: "GymbroWorkoutsTests")],
        configuration: .debug
    )
)

let gymbroFeedsTestsScheme: Scheme = .scheme(
    name: "GymbroFeedsTests",
    shared: true,
    buildAction: .buildAction(
        targets: [TargetReference(stringLiteral: "GymbroFeedsTests")],
        preActions: [],
        postActions: []
    ),
    testAction: .targets(
        [TestableTarget(stringLiteral: "GymbroFeedsTests")],
        configuration: .debug
    )
)

let gymbroProfileTestsScheme: Scheme = .scheme(
    name: "GymbroProfileTests",
    shared: true,
    buildAction: .buildAction(
        targets: [TargetReference(stringLiteral: "GymbroProfileTests")],
        preActions: [],
        postActions: []
    ),
    testAction: .targets(
        [TestableTarget(stringLiteral: "GymbroProfileTests")],
        configuration: .debug
    )
)

// Project

let project = Project(
    name: "Gymbro",
    settings: Settings.settings(configurations: makeConfigurations()),
    targets: [
        mainAppTarget,
        networkTarget,
        workoutsTarget,
        gymbroWorkoutsTests,
        navigationTarget,
        commonUITarget,
        gymbroCommonUITests,
        typesTarget,
        feedsTarget,
        gymbroFeedsTests,
        authTarget,
        profileTarget,
        perksTarget,
        challengesTarget,
        gymbroProfileTests,
        analyticsTarget,
        watchOSTarget,
        widgetExtensionTarget
    ],
    schemes: [gymbroWorkoutsTestsScheme, gymbroFeedsTestsScheme, gymbroProfileTestsScheme]
)

// Helpers
private func makeConfigurations() -> [Configuration] {
    let debug: Configuration = Configuration.debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig")
    let release: Configuration = Configuration.release(name: "Release", xcconfig: "Configs/Release.xcconfig")
    
    return [debug, release]
}

private func baseSettings(entitlements: String? = nil) -> Settings {
    var settings = SettingsDictionary()
    if let entitlements {
        settings["CODE_SIGN_ENTITLEMENTS"] = .string(entitlements)
    }
    return Settings.settings(
        base: settings,
        configurations: [],
        defaultSettings: .recommended
    )
}
