public func yieldWithBackPressure<Message>(message: Message, to continuation: AsyncStream<Message>.Continuation) async {
    var enqueued = false
    while !enqueued {
        let result = continuation.yield(message)
        switch result {
        case .terminated:
            // Stream is closed
            return
        case .enqueued:
            // Here we can know how many slots remains in the stream
            enqueued = true
        case .dropped:
            // Here we can know what message has beed dropped
            await Task.yield()
            continue
        @unknown default:
            fatalError("Runtime error: unknown case in \(#function), \(#file):\(#line)")
        }
    }
}
