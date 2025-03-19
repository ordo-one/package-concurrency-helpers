/// A wrapper that forcefully marks a non-Sendable type as Sendable.
///
/// - Warning: This should only be used when you are certain that the wrapped type
///   does not introduce race conditions or shared mutable state.
///   **Improper use may lead to undefined behavior or data races.**
///
/// - Note: This wrapper applies `@unchecked Sendable`, bypassing Swift’s strict concurrency safety.
///   Use only if the wrapped type is inherently thread-safe.
public struct UnsafeSendableWrapper<T>: @unchecked Sendable {
    /// The wrapped instance of the non-Sendable type.
    public let instance: T

    /// Initializes a new `UnsafeSendableWrapper` with the provided instance.
    ///
    /// - Parameter instance: The non-Sendable instance to wrap.
    public init(instance: T) {
        self.instance = instance
    }
}
