// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription


let package = Package(
    name: "benchmarks",
    platforms: [
        .macOS("14"),
    ],
    dependencies: [
        .package(path: "../"),
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.23.0"),
    ],
    targets: [
        .executableTarget(
            name: "ConcurrencyBenchmarks",
            dependencies: [
                .product(name: "Benchmark", package: "package-benchmark"),
                .product(name: "PackageConcurrencyHelpers", package: "package-concurrency-helpers")
            ],
            path: "Benchmarks/ConcurrencyBenchmarks",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark")
            ]
        ),
    ]
)
