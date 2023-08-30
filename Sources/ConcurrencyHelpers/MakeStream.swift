/// `makeStream` is part of Swift 5.9
/// https://github.com/apple/swift-evolution/blob/main/proposals/0388-async-stream-factory.md
public func makeStream<T>(of _: T.Type) -> (AsyncStream<T>, AsyncStream<T>.Continuation) {
    var resultContinuation: AsyncStream<T>.Continuation?
    let asyncStream = AsyncStream<T> { continuation in
        resultContinuation = continuation
    }

    guard let resultContinuation else {
        fatalError("makeStream internal error, couldn't extract resultContinuation")
    }
    return (asyncStream, resultContinuation)
}

public func makeSingleStream<T>(of _: T.Type) -> (AsyncStream<T>, AsyncStream<T>.Continuation) {
    var resultContinuation: AsyncStream<T>.Continuation?
    let asyncStream = AsyncStream<T>(bufferingPolicy: .bufferingNewest(1)) { continuation in
        resultContinuation = continuation
    }

    guard let resultContinuation else {
        fatalError("makeStream internal error, couldn't extract resultContinuation")
    }
    return (asyncStream, resultContinuation)
}
