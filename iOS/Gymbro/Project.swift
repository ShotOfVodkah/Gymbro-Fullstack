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
            "UILaunchScreen": [:]
        ]
    ),
    sources: ["\(basePath)/Gymbro/Sources/**"],
    resources: ["\(basePath)/Gymbro/Resources/**"],
    dependencies: [
        .target(name: "GymbroNetwork"),
        .target(name: "GymbroWorkouts")
    ],
    settings: baseSettings()
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
        .target(name: "GymbroWorkouts")
    ],
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
    dependencies: [],
    settings: baseSettings()
)

// Project

let project = Project(
    name: "Gymbro",
    settings: Settings.settings(configurations: makeConfigurations()),
    targets: [
        mainAppTarget,
        networkTarget,
        workoutsTarget
    ]
)

// Helpers
private func makeConfigurations() -> [Configuration] {
    let debug: Configuration = Configuration.debug(name: "Debug", xcconfig: "Configs/Debug.xcconfig")
    let release: Configuration = Configuration.release(name: "Release", xcconfig: "Configs/Release.xcconfig")
    
    return [debug, release]
}

private func baseSettings() -> Settings {
    var settings = SettingsDictionary()
    return Settings.settings(
        base: settings,
        configurations: [],
        defaultSettings: .recommended
    )
}
