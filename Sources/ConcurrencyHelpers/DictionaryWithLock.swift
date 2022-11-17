// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

public struct DictionaryWithLock<K: Hashable, V> {
    var lock: ConcurrencyHelpers.Lock = .init()
    var map: [K: V] = [:]

    public init() {}

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
