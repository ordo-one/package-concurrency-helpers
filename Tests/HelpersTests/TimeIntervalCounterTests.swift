// Copyright 2023 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

@testable import Helpers
import XCTest

final class TimeIntervalCounterTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    private func counterTest(forIterations iterations: UInt64, interval: Duration) {
        var counter = TimeIntervalCounter(clock: ContinuousClock(), timeInterval: interval)
        var checkPointExecuted = false

        for _ in 0 ..< iterations - 1 {
            counter.checkpoint { _ in
                checkPointExecuted = true
            }
        }
        XCTAssert(!checkPointExecuted, "Checkpoint was unexpectedly executed")

        Thread.sleep(forTimeInterval: TimeInterval(interval.components.seconds + 1))

        counter.checkpoint { count in
            checkPointExecuted = true

            XCTAssert(count == iterations, "Count is not equal to iterations")
        }
        XCTAssert(checkPointExecuted, "Checkpoint was not executed")
        XCTAssert(counter.currentCount == 0, "Counter was not reset")
    }

    private func counterTestWithInc(forIterations iterations: UInt64, interval: Duration) {
        var counter = TimeIntervalCounter(clock: ContinuousClock(), timeInterval: interval)

        for _ in 0 ..< iterations - 1 {
            let res = counter.incremenet()
            XCTAssert(!res, "Checkpoint was unexpectedly reached")
        }

        Thread.sleep(forTimeInterval: TimeInterval(interval.components.seconds + 1))

        let result = counter.incremenet()
        XCTAssert(result, "Checkpoint was not reached")
        XCTAssert(counter.currentCount == iterations, "Count is not equal to iterations")
        counter.reset()
        XCTAssert(counter.currentCount == 0, "Counter was not reset")
    }

    private func counterTestWithTimeProvided(forIterations iterations: UInt64, interval: Duration) {
        let clock = ContinuousClock()
        var counter = TimeIntervalCounter(clock: ContinuousClock(), timeInterval: interval)
        let startTs = clock.now
        var checkPointExecuted = false

        for idx in 0 ..< iterations - 1 {
            counter.checkpoint(eventTime: startTs + Duration.nanoseconds(idx)) { _ in
                checkPointExecuted = true
            }
        }
        XCTAssert(!checkPointExecuted, "Checkpoint was unexpectedly executed")

        counter.checkpoint(eventTime: startTs + interval) { count in
            checkPointExecuted = true

            XCTAssert(count == iterations, "Count is not equal to iterations")
        }
        XCTAssert(checkPointExecuted, "Checkpoint was not executed")
        XCTAssert(counter.currentCount == 0, "Counter was not reset")
    }

    private func counterTestWithTimeProvidedInc(forIterations iterations: UInt64, interval: Duration) {
        let clock = ContinuousClock()
        var counter = TimeIntervalCounter(clock: clock, timeInterval: interval)
        let startTs = clock.now

        for idx in 0 ..< iterations - 1 {
            let res = counter.incremenet(eventTime: startTs + Duration.nanoseconds(idx))
            XCTAssert(!res, "Checkpoint was unexpectedly reached")
        }

        let result = counter.incremenet(eventTime: startTs + interval)
        XCTAssert(result, "Checkpoint was not reached")
        XCTAssert(counter.currentCount == iterations, "Count is not equal to iterations")
        counter.reset()
        XCTAssert(counter.currentCount == 0, "Counter was not reset")
    }

    func testCounter10Iters1SecondSlow() {
        counterTest(forIterations: 10, interval: Duration.seconds(1))
        counterTestWithInc(forIterations: 10, interval: Duration.seconds(1))
    }

    func testCounter200000Iters2secondsSlow() {
        counterTest(forIterations: 200_000, interval: Duration.seconds(2))
        counterTestWithInc(forIterations: 200_000, interval: Duration.seconds(2))
    }

    func testCounter10Iters1SecondTimeProvided() {
        counterTestWithTimeProvided(forIterations: 10, interval: Duration.seconds(1))
        counterTestWithTimeProvidedInc(forIterations: 10, interval: Duration.seconds(1))
    }

    func testCounter200000Iters2secondsTimeProvided() {
        counterTestWithTimeProvided(forIterations: 200_000, interval: Duration.seconds(2))
        counterTestWithTimeProvidedInc(forIterations: 200_000, interval: Duration.seconds(2))
    }
}
