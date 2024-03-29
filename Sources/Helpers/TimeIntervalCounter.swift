// Copyright 2023 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

/// This class  tracks counter during the specified time interval

public struct TimeIntervalCounter<Time: Clock> {
    private let clock: Time
    private let timeInterval: Time.Duration
    private var nextTimeStamp: Time.Instant
    private var counter: UInt64

    /// - Parameter clock: Clock type that is used for time tracking, conforms with `Clock` protocol
    /// - Parameter timeInterval: Execute checkpoint  every `timeInterval` of type Time.Duration
    /// - Parameter initialCount: Sets initial count, `0` by default
    public init(clock: Time, timeInterval: Time.Duration, initialCount: UInt64 = 0) {
        self.clock = clock
        self.timeInterval = timeInterval
        nextTimeStamp = clock.now.advanced(by: timeInterval)
        counter = initialCount
    }

    /// Current count since the last checkpoint mark.
    public var currentCount: UInt64 {
        counter
    }

    /// Sets counter to zero and resets checkpoint time
    public mutating func reset() {
        counter = 0
        nextTimeStamp = clock.now.advanced(by: timeInterval)
    }

    /// Increments counter
    /// returns `true`if timeinterval has been reached with provided time
    public mutating func incremenet(eventTime: Time.Instant) -> Bool {
        counter += 1
        assert(nextTimeStamp.advanced(by: Time.Duration.zero - timeInterval) < eventTime, "Event time was before time interval")
        return eventTime > nextTimeStamp
    }

    /// Increments counter
    /// returns `true`if timeinterval has been reached
    /// uses Time.now as a time point
    public mutating func incremenet() -> Bool {
        incremenet(eventTime: clock.now)
    }

    /// Executes passed closure once the checkpoint time interval based on provided event time
    /// The checkpoint count is incremented with each invocatation
    public mutating func checkpoint(eventTime: Time.Instant, _ body: (UInt64) -> Void) {
        if incremenet(eventTime: eventTime) {
            body(currentCount)
            reset()
        }
    }

    /// Executes passed closure once the checkpoint time interval has been reached.
    /// The checkpoint count is incremented with each invocatation
    public mutating func checkpoint(_ body: (UInt64) -> Void) {
        checkpoint(eventTime: clock.now, body)
    }
}
