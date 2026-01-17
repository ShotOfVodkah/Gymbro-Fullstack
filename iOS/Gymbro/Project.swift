import ProjectDescription

// General variables

private let bundleId: String = "dev.tuist.Gymbro"
private let version: String = "0.0.1"
private let bundleVersion: String = "1"
private let iOSTargetVersion: String = "17.0"
private let basePath = "Targets/Gymbro"

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
    sources: ["\(basePath)/Sources/**"],
    resources: ["\(basePath)/Resources/**"],
    dependencies: [],
    settings: baseSettings()
)

let testTarget: ProjectDescription.Target = .target(
    name: "GymbroTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "dev.tuist.GymbroTests",
    infoPlist: .default,
    sources: ["\(basePath)/Tests/**"],
    dependencies: [.target(name: "Gymbro")]
)

// Project

let project = Project(
    name: "Gymbro",
    settings: Settings.settings(configurations: makeConfigurations()),
    targets: [
        mainAppTarget,
        testTarget,
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
