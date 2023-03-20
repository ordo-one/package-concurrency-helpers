/// Thread safe access to simple variable protected by lock
@propertyWrapper
public final class Protected<T> {
    var value: T
    var lock: ConcurrencyHelpers.Lock

    public init(wrappedValue: T) {
        value = wrappedValue
        lock = .init()
    }

    public var wrappedValue: T {
        get { lock.withLock { value } }
        set { lock.withLockVoid { value = newValue } }
    }

    public var projectedValue: Protected<T> { self }

    /// Provides thread-safe scoped access to protected value
    /// - Parameter body: The clouse to be called for scoped access
    /// - Returns: The return value of the closure
    public func read<V>(_ body: (T) -> V) -> V {
        lock.withLock {
            body(value)
        }
    }

    /// Provides thread-safe scoped mutable access to protected value
    /// - Parameter body: The clouse to be called for scoped access
    /// - Returns: The return value of the closure
    public func write<V>(_ body: (inout T) -> V) -> V {
        lock.withLock {
            body(&value)
        }
    }
}
