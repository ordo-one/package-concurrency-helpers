/// Yields the `message` to the AsyncStream `continuation`
/// with back pressure logic.
///
/// If `continuation` returns `.dropped`, the method yields the Task and try again.
///
/// - Parameter message: The value to yield to the continuation.
/// - Parameter continuation: The continuation to yield message to.
/// - Returns: `true` if the `message` has been succesfully yielded to the stream and `false` in otherwise.
public func yieldWithBackPressure<Message>(message: Message,
                                           to continuation: AsyncStream<Message>.Continuation) async -> Bool {
    var enqueued = false
    while !enqueued {
        let result = continuation.yield(message)
        switch result {
        case .terminated:
            // Stream is closed
            return false
        case .enqueued:
            // Here we can know how many slots remains in the stream
            enqueued = true
            return true
        case .dropped:
            // Here we can know what message has beed dropped
            await Task.yield()
            continue
        @unknown default:
            fatalError("Runtime error: unknown case in \(#function), \(#file):\(#line)")
        }
    }
}
