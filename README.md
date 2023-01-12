[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fordo-one%2Fpackage-concurrency-helpers%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ordo-one/package-concurrency-helpers)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fordo-one%2Fpackage-concurrency-helpers%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ordo-one/package-concurrency-helpers)
[![Swift Linux build](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-concurrency-helpers/branch/main/graph/badge.svg?token=mSfhIPMpJE)](https://codecov.io/gh/ordo-one/package-concurrency-helpers)
[![Swift lint](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-outdated-dependencies.yml)
[![Swift address sanitizer](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-address.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-address.yml)[![Swift thread sanitizer](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-thread.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-thread.yml)
# Concurrency helpers
Various concurrency related tools, including Lock and async stream additions etc.

To add to your project:
```
dependencies: [
    .package(url: "https://github.com/ordo-one/package-concurrency-helpers", .upToNextMajor(from: "0.0.1")),
]
```

and then add the dependency to your target, e.g.:

```
.executableTarget(
  name: "MyExecutableTarget",
  dependencies: [
  .product(name: "SwiftConcurrencyHelpers", package: "package-concurrency-helpers")
]),
```
