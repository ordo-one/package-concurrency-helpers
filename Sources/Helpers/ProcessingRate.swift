// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import LatencyTimer

/// This class  tracks how many times per second during the specified interval the checkpoint was called
///
/// - Parameter interval: Execute checkpoint  every `interval` executions
public class ProcessingRate {
    var checkpointCount: UInt64
    var lastCheckpointTime: UInt64
    let checkpointInterval: UInt64

    public init(interval: UInt64) {
        checkpointCount = 0
        lastCheckpointTime = LatencyTimer.getTimestamp()
        checkpointInterval = interval
    }

    /// Current rate per second since the last checkpoint mark.
    public var ratePerSecond: Double {
        let duration = LatencyTimer.getTimestamp() - lastCheckpointTime

        if checkpointCount == 0 {
            return 0
        }
        return Double(checkpointCount) / Double(duration) * 1_000_000.0
    }

    /// Executes passed closure once the checkpoint interval has been reached.
    /// The checkpoint count is incremented with each invocatation
    public func checkpoint(_ body: (Double) -> Void) {
        checkpointCount += 1
        if checkpointCount == checkpointInterval {
            body(ratePerSecond)
            lastCheckpointTime = LatencyTimer.getTimestamp()
            checkpointCount = 0
        }
    }
}
