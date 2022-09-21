// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "package-concurrency-helpers",
    platforms: [
        .macOS(.v12),
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
        .package(url: "https://github.com/ordo-one/package-latency-tools", branch: "main"),
    ],
    targets: [
        .target(
            name: "ConcurrencyHelpers",
            dependencies: [
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
    ]
)
