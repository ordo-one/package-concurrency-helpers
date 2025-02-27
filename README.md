[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fordo-one%2Fpackage-concurrency-helpers%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ordo-one/package-concurrency-helpers)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fordo-one%2Fpackage-concurrency-helpers%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ordo-one/package-concurrency-helpers)
[![Swift Linux build](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-linux-build.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-linux-build.yml) [![Swift macOS build](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-macos-build.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-macos-build.yml) [![codecov](https://codecov.io/gh/ordo-one/package-concurrency-helpers/branch/main/graph/badge.svg?token=mSfhIPMpJE)](https://codecov.io/gh/ordo-one/package-concurrency-helpers)
[![Swift lint](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-lint.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-lint.yml) [![Swift outdated dependencies](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-outdated-dependencies.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-outdated-dependencies.yml)
[![Swift address sanitizer](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-address.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-address.yml)[![Swift thread sanitizer](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-thread.yml/badge.svg)](https://github.com/ordo-one/package-concurrency-helpers/actions/workflows/swift-sanitizer-thread.yml)
# Concurrency helpers
Various concurrency related tools, including Lock and async stream additions etc.

### To add to your project:
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

### Helpers provided:

* Safely call a blocking function from an async context:

  ```swift
  let result = await forBlockingFunc {
      // Call your blocking function here.
  }
  ```

* Run async code in a non-async context:

  ```swift
  let result = runSync {
      await someFunction()
  }
  ```

* Simple locks, including a variant that sleeps while waiting for the lock:

  ```swift
  let lock = Lock()
  
  let result = lock.withLock {
      …
  }
  ```

  …and a variant that spins waiting for the lock:

  ```swift
  let lock = Spinlock()
  
  let result = lock.withLock {
      … // Make sure whatever you do here is quick; other threads may be busy waiting.
  }
  ```

* A simple thread-safe box for a value:

  ```swift
  let safeValue = Protected(myValue)

  safeValue.write {
      // Have exclusive access to the contents here.
      $0.someField = true
  }

  safeValue.read {
      // Have exclusive, read-only access to the contents here.
      if $0.someField {
          …
      }
  }
  ```

* An unsafe `Sendable` wrapper for value types:

  ```swift
  var someNonSendable = …

  let wrapper = UnsafeTransfer(someNonSendable)

  Task.detached {
      let value = wrapper.wrappedValue
      // Use `value` here, instead of the original name `someNonSendable`.
  }
  ```

  There is also an `UnsafeMutableTransfer` variant, for mutable values.

* Yield a value to an `AsyncStream` with back-pressure support (waiting in a Concurrency-safe way until the stream is ready to accept the message):

  ```swift
  guard yieldWithBackPressure(message: …, to: continuation) else {
      // Stream was closed or this task has been cancelled.
  }
  ```

* A simple reference-typed box for value types:

  ```swift
  let a = Box(5)
  let b = a

  b.value += 1

  // 'b' and 'a' both now hold 6.
  ```

  It inherits the `Equatable`, `Comparable`, `CustomStringConvertible`, and `CustomDebugStringConvertible` conformances of the contained type.

* Determine if a debugger is attached (a Swift version of [Apple's C `AmIBeingDebugged`](https://developer.apple.com/library/archive/qa/qa1361/_index.html)):

  ```swift
  if isBeingDebugged {
      // Running under, or attached by, a debugger of some kind.
  } else {
      // *Probably* not being debugged.
  }
  ```

  Note that this is not foolproof; [debuggers can hide themselves from detection](https://alexomara.com/blog/defeating-anti-debug-techniques-macos-amibeingdebugged/).

* A backport of Apple's [AsyncStream.makeStream(of:bufferingPolicy:)](https://developer.apple.com/documentation/swift/asyncstream/makestream(of:bufferingpolicy:)), to make it available in Swift 5.8 and earlier as well.

* Calculate the next highest power of two, above a given integer:

  ```swift
  let roundedUp = nearestPowerOf2(27)
  // 'roundedUp' is 32.
  ```

* Count events, then at designated checkpoints run a closure & reset the count if a set duration has passed since the last reset (or since the counter was created, if never before reset).

  ```swift
  let monitor = TimeIntervalCounter(clock: ContinuousClock(),
                                    timeInterval: .seconds(5))

  while true {
      if monitor.incremenet() {
          // It has been at least five seconds since the monitor was last reset.
      }

      monitor.checkpoint {
          // Runs at most once every five seconds.
          print("Current count: \(monitor.count)")
          // The count will automatically be reset to zero when this closure exits.
      }
  }
  ```
  
