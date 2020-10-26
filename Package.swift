// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "MiniRex",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v8),
        .watchOS(.v2),
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
            path: "./MiniRex/MiniRex"
        ),
        .testTarget(
            name: "MiniRexTests",
            dependencies: ["MiniRex"],
            path: "./MiniRex/MiniRexTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
