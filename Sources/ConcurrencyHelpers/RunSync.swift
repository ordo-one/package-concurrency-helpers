import Dispatch

/**
 * Runs async closure and waits for its result in non-async code.
 *
 * Use with care as this blocks the current thread and violates
 * "forward progress" Swift concurrency runtime contract.
 *
 * See https://developer.apple.com/videos/play/wwdc2021/10254/?time=1582
 *
 * - Parameters:
 *   - priority: The priority of the task that will run the operation.
 *               Pass nil to use the priority from `Task.currentPriority`.
 *   - operation: The operation to perform.
 *
 * - Returns: The value returned from the `operation`.
 */
public func runSync<T: Sendable>(priority: TaskPriority? = nil, _ operation: @escaping @Sendable () async -> T) -> T {
    let result = UnsafeMutableTransferBox<T?>(nil)

    let semaphore = DispatchSemaphore(value: 0)

    Task(priority: priority) {
        result.wrappedValue = await operation()
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
 *
 * - Parameters:
 *   - priority: The priority of the task that will run the operation.
 *               Pass nil to use the priority from `Task.currentPriority`.
 *   - operation: The operation to perform.
 *
 * - Returns: The value returned from the `operation`.
 *
 * - Throws: The error thrown by the `operation`.
 */
public func runSync<T: Sendable>(priority: TaskPriority? = nil, _ operation: @escaping @Sendable () async throws -> T) throws -> T {
    let result = runSync(priority: priority) { () -> Result<T, Error> in
        do {
            return .success(try await operation())
        } catch {
            return .failure(error)
        }
    }
    return try result.get()
}
