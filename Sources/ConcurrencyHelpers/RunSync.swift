import Dispatch

/**
 * Runs async closure and waits for its result in non-async code.
 *
 * Use with care as this blocks the current thread and violates
 * "forward progress" Swift concurrency runtime contract.
 *
 * See https://developer.apple.com/videos/play/wwdc2021/10254/?time=1582
 */
public func runSync<T>(_ closure: @escaping () async -> T) -> T {
    let result = UnsafeMutableTransferBox<T?>(nil)

    let semaphore = DispatchSemaphore(value: 0)

    Task {
        result.wrappedValue = await closure()
        semaphore.signal()
    }

    semaphore.wait()

    return result.wrappedValue!
}

/**
 * Runs throwing async closure and waits for its result (incl. rethrowing exception)
 * in non-async code.
 *
 * Use with care as this blocks the current thread and violates
 * "forward progress" Swift concurrency runtime contract.
 *
 * See https://developer.apple.com/videos/play/wwdc2021/10254/?time=1582
 */
public func runSync<T>(_ closure: @escaping () async throws -> T) throws -> T{
    func nonthowing() async -> Result<T, Error> {
        do {
            return .success(try await closure())
        } catch {
            return .failure(error)
        }
    }

    return try runSync(nonthowing).get()
}
