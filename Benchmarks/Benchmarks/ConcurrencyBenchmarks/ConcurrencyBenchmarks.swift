import PackageConcurrencyHelpers
import Benchmark

private func generateRandomArray(size: Int) -> [Int] {
    return (1...size).map { _ in Int.random(in: 1...10_000) }
}

private func generateRandomStringArray(size: Int) -> [String] {
    return (1...size).map { _ in String((0..<30).map { _ in "abcdefghijklmnopqrstuvwxyz".randomElement()! }) }
}

let largeIntArray = generateRandomArray(size: 100000)
let largeStringArray = generateRandomStringArray(size: 100000)

let benchmarks = {
    Benchmark.defaultConfiguration.maxIterations = 100_000
    Benchmark.defaultConfiguration.maxDuration = .seconds(3)
    Benchmark.defaultConfiguration.metrics = [
        .wallClock,
        .threadsRunning,
        .instructions,
        .cpuTotal,
        .mallocCountTotal,
        .peakMemoryResident
    ]

    Benchmark("Normal map baseline") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(largeIntArray.map { $0 * 2 })
        }
    }

    Benchmark("Concurrent map baseline") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(await largeIntArray.concurrentMap { $0 * 2 })
        }
    }

    Benchmark("Map with trigonometric function") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(largeIntArray.map { Int(.sin(Double($0) * Double.pi / 180) * 1000) })
        }
    }

    Benchmark("Concurrent map with trigonometric function") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(await largeIntArray.concurrentMap { Int(.sin(Double($0) * Double.pi / 180) * 1000) })
        }
    }

    Benchmark("Map with string manipulation") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(largeStringArray.map { $0.range(of: "ab", options:. caseInsensitive) != nil ? $0 : "abc" })
        }
    }

    Benchmark("Concurrent map with string manipulation") { benchmark in
        for _ in benchmark.scaledIterations {
            blackHole(await largeStringArray.concurrentMap { $0.range(of: "ab", options:. caseInsensitive) != nil ? $0 : "abc" })
        }
    }
}
