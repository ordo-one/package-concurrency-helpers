// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

@testable import Helpers
import XCTest

final class ProcessingRateTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    private func processingRateTest(forIterations iterations: UInt64, overInternal sleep: Double,
                                    expectedRate: Double, allowedError: Double = 0.2) {
        let rate = ProcessingRate(interval: iterations)
        for _ in 0 ..< iterations - 1 {
            rate.checkpoint { _ in }
        }

        Thread.sleep(forTimeInterval: sleep)

        rate.checkpoint { rate in
            var rateSuccess = false

            if abs(rate - expectedRate) < expectedRate * allowedError {
                rateSuccess = true
            }

            XCTAssert(rateSuccess,
                      "Wrong rate: \(Int(rate)) for forTimeInterval: \(sleep) and \(iterations) invokes")
        }

        XCTAssert(rate.checkpointCount == 0, "Checkpoint was not reset")
    }

    func testProcessingRate10() {
        processingRateTest(forIterations: 10, overInternal: 1, expectedRate: 10)
    }

    func testProcessingRateKilo() {
        processingRateTest(forIterations: 200_000, overInternal: 1, expectedRate: 200_000)
    }

//    func testProcessingRateMega() {
//        // Seems this test is too slow to execute in GitHub CI
//        processingRateTest(forIterations: 1_000_000, overInternal: 1, expectedRate: 1_000_000, allowedError: 0.3)
//    }

    func testProcessingRateSlow2K() {
        processingRateTest(forIterations: 2_000, overInternal: 2, expectedRate: 1_000)
    }

    func testProcessingRateSlow100K() {
        processingRateTest(forIterations: 100_000, overInternal: 5, expectedRate: 20_000)
    }

    func testProcessingRateUnderSecond50K() {
        processingRateTest(forIterations: 50_000, overInternal: 0.2, expectedRate: 250_000)
    }

    func testProcessingRateUnderSecond100k() {
        processingRateTest(forIterations: 100_000, overInternal: 0.5, expectedRate: 200_000)
    }
}
