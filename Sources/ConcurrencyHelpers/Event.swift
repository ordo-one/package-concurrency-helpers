import Atomics

/**
 * Synchronization primitive modelled after Event from WinAPI.
 */
public final class Event {
    // Protects continuations array and write to signaled flag.
    private var lock = Lock()

    // Can be accessed for read without taking lock
    private var signaled: UnsafeAtomic<Bool>

    private typealias Continuation = CheckedContinuation<Void, Never>

    private var continuations = [Continuation]()

    /**
     * Initialize a new event.
     *
     * - argument signaled: Initial state of event. Non-signaled by default.
     */
    public init(signaled: Bool = false) {
        self.signaled = .create(signaled)
    }

    /**
     * Wait for event to become signaled.
     */
    public func wait() async {
        guard !isSignaled else {
            return
        }

        lock.lock()

        guard !isSignaled else {
            lock.unlock()
            return
        }

        await withCheckedContinuation {
            continuations.append($0)
            lock.unlock()
        }
    }

    /**
     * Check if event is in signaled state.
     */
    public var isSignaled: Bool {
        signaled.load(ordering: .relaxed)
    }

    /**
     * Mark event as signaled.
     *
     * - returns: 'true' if event was in non-signaled state, 'false' otherwise.
     */
    @discardableResult
    public func signal() -> Bool {
        guard !isSignaled else { return false }

        var continuationsToResume = [Continuation]()

        let wasSignaled = lock.withLock {
            guard !isSignaled else { return false }

            signaled.store(true, ordering: .relaxed)
            swap(&continuations, &continuationsToResume)
            return true
        }

        continuationsToResume.forEach { $0.resume() }

        return wasSignaled
    }

    /**
     * Reset the event back to non-signaled state.
     *
     * - returns: 'true' if event was signaled, 'false' otherwise.
     */
    @discardableResult
    public func reset() -> Bool {
        guard isSignaled else { return false }

        return lock.withLock {
            guard isSignaled else { return false }
            signaled.store(false, ordering: .relaxed)
            return true
        }
    }
}
