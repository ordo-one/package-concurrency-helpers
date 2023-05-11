// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-concurrency-helpers",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "ConcurrencyHelpers",
            targets: ["ConcurrencyHelpers"]
        ),
        .library(
            name: "Helpers",
            targets: ["Helpers"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-atomics", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/ordo-one/package-latency-tools", .upToNextMajor(from: "1.0.0")),
    ],
    targets: [
        .target(
            name: "_PauseShims"
        ),
        .target(
            name: "ConcurrencyHelpers",
            dependencies: [
                "_PauseShims",
                .product(name: "Atomics", package: "swift-atomics"),
            ]
        ),
        .target(
            name: "Helpers",
            dependencies: [
                .product(name: "LatencyTimer", package: "package-latency-tools"),
            ]
        ),
        .testTarget(
            name: "ConcurrencyHelpersTests",
            dependencies: ["ConcurrencyHelpers"]
        ),
        .testTarget(
            name: "HelpersTests",
            dependencies: ["Helpers", "ConcurrencyHelpers"]
        ),
    ]
)
