public struct DictionaryWithLock<K: Hashable, V> {
    var lock: ConcurrencyHelpers.Lock = .init()
    var map: [K: V] = [:]

    public subscript(key: K) -> V? {
        get {
            lock.withLock {
                guard let value = map[key] else {
                    return nil
                }
                return value
            }
        }
        set {
            lock.withLock {
                map[key] = newValue
            }
        }
    }
}
