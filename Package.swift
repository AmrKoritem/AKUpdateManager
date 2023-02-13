// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AKUpdateManager",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "AKUpdateManager",
            targets: ["AKUpdateManager"]),
    ],
    targets: [
        .target(
            name: "AKUpdateManager",
            dependencies: []),
        .testTarget(
            name: "AKUpdateManagerTests",
            dependencies: ["AKUpdateManager"]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
