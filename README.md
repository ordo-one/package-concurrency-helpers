[![Swift version](https://img.shields.io/badge/Swift-5.7-orange)](https://img.shields.io/badge/Swift-5.7-orange) [![Code complexity analysis](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/scc-code-complexity.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/scc-code-complexity.yml) [![Swift Linux build](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-concurrency-helpers/branch/main/graph/badge.svg?token=mSfhIPMpJE)](https://codecov.io/gh/ordo-one/package-concurrency-helpers)
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
