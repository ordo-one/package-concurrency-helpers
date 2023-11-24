// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import class Foundation.ProcessInfo
import PackageDescription

let externalDependencies: [String: Range<Version>] = [
    "https://github.com/apple/swift-docc-plugin": .upToNextMajor(from: "1.0.0"),
    "https://github.com/apple/swift-atomics": .upToNextMajor(from: "1.0.0"),
    "https://github.com/mattgallagher/CwlPreconditionTesting": .upToNextMajor(from: "2.0.0")
]

let internalDependencies: [String: Range<Version>] = [
    "package-latency-tools": .upToNextMajor(from: "1.0.0")
]

func makeDependencies() -> [Package.Dependency] {
    var dependencies: [Package.Dependency] = []
    dependencies.reserveCapacity(externalDependencies.count + internalDependencies.count)

    for extDep in externalDependencies {
        dependencies.append(.package(url: extDep.key, extDep.value))
    }

    // Setting LOCAL_PACKAGES_DIR environment variable allows to use local version of repositories owned by Ordo One.
    let localPath = ProcessInfo.processInfo.environment["LOCAL_PACKAGES_DIR"]

    for intDep in internalDependencies {
        if let localPath {
            dependencies.append(.package(name: "\(intDep.key)", path: "\(localPath)/\(intDep.key)"))
        } else {
            dependencies.append(.package(url: "https://github.com/ordo-one/\(intDep.key)", intDep.value))
        }
    }
    return dependencies
}

let package = Package(
    name: "package-concurrency-helpers",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "PackageConcurrencyHelpers",
            targets: ["PackageConcurrencyHelpers"]
        ),
        .library(
            name: "Helpers",
            targets: ["Helpers"]
        )
    ],
    dependencies: makeDependencies(),
    targets: [
        .target(
            name: "_PauseShims"
        ),
        .target(
            name: "PackageConcurrencyHelpers",
            dependencies: [
                "_PauseShims",
                .product(name: "Atomics", package: "swift-atomics"),
            ],
            path: "Sources/ConcurrencyHelpers",
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .target(
            name: "Helpers",
            dependencies: [
                .product(name: "LatencyTimer", package: "package-latency-tools"),
            ]
        ),
        .testTarget(
            name: "ConcurrencyHelpersTests",
            dependencies: [
                .product(
                    name: "CwlPreconditionTesting",
                    package: "CwlPreconditionTesting",
                    condition: .when(platforms: [.macOS])),
                "PackageConcurrencyHelpers",
            ]
        ),
        .testTarget(
            name: "HelpersTests",
            dependencies: ["Helpers", "PackageConcurrencyHelpers"]
        ),
    ]
)
