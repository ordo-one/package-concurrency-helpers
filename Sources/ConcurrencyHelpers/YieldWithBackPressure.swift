// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

/// Yields the `message` to the AsyncStream `continuation`
/// with back pressure logic.
///
/// If `continuation` returns `.dropped`, the method yields the Task and try again.
/// If the task is cancelled it stops trying and return `false`.
///
/// - Parameter message: The value to yield to the continuation.
/// - Parameter continuation: The continuation to yield message to.
/// - Returns: `true` if the `message` has been succesfully yielded to the stream and `false` in otherwise.
@discardableResult
public func yieldWithBackPressure<Message>(message: Message,
                                           to continuation: AsyncStream<Message>.Continuation) async -> Bool {
    while true {
        let result = continuation.yield(message)
        switch result {
        case .terminated:
            // Stream is closed
            return false
        case .enqueued:
            // Here we can know how many slots remains in the stream
            return true
        case .dropped:
            // Here we can know that a message has been dropped
            if Task.isCancelled {
                return false
            }
            await Task.yield()
            continue
        @unknown default:
            fatalError("Runtime error: unknown case in \(#function), \(#file):\(#line)")
        }
    }
}
