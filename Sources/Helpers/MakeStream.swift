// Copyright 2023 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

#if swift(<5.9)
public extension AsyncStream {
    /// `makeStream` is part of Swift 5.9
    /// https://github.com/apple/swift-evolution/blob/main/proposals/0388-async-stream-factory.md
    static func makeStream(
        of elementType: Element.Type = Element.self,
        bufferingPolicy limit: Continuation.BufferingPolicy = .unbounded
    ) -> (stream: AsyncStream<Element>, continuation: AsyncStream<Element>.Continuation) {
        var resultContinuation: AsyncStream<Element>.Continuation?
        let stream = AsyncStream<Element>(bufferingPolicy: limit) { continuation in
            resultContinuation = continuation
        }

        guard let resultContinuation else {
            fatalError("makeStream internal error, couldn't extract resultContinuation")
        }
        return (stream: stream, continuation: resultContinuation)
    }
}
#endif
