import Dispatch
import Helpers

/**
 * Runs async closure and waits for its result in non-async code.
 */
public func runSync<T>(_ closure: @escaping () async -> T) -> T {
    let result = Box<T?>(nil)

    let semaphore = DispatchSemaphore(value: 0)

    Task {
        result.value = await closure()
        semaphore.signal()
    }

    semaphore.wait()

    return result.value!
}

/**
 * Runs throwing async closure and waits for its result (incl. rethrowing exception)
 * in non-async code.
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
