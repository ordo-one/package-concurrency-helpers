// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-concurrency-helpers",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "ConcurrencyHelpers",
            targets: ["ConcurrencyHelpers"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],

    targets: [
        .target(
            name: "ConcurrencyHelpers",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "ConcurrencyHelpersTests",
            dependencies: ["ConcurrencyHelpers"]
        ),
    ]
)
