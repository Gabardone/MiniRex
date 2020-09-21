// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MiniRex",
    platforms: [
        .macOS(.v10_9),
        .iOS(.v9_3),
        .watchOS(.v2_2),
        .tvOS(.v9)
    ],
    products: [
        .library(
            name: "MiniRex",
            targets: ["MiniRex"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MiniRex",
            dependencies: [],
            path: "./MiniRex"
        ),
        .testTarget(
            name: "MiniRexTests",
            dependencies: ["MiniRex"],
            path: "./MiniRexTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
