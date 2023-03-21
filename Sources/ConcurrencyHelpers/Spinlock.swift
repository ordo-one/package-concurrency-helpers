// Copyright 2023 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Atomics
import _PauseShims

/// Lock to protect very short critical sections.
public final class Spinlock {
    private typealias State = Bool

    private static let locked: State = true
    private static let unlocked: State = false

    private let stateStorage = UnsafeMutablePointer<State.AtomicRepresentation>.allocate(capacity: 1)
    private var state: UnsafeAtomic<State>

    /// Create a new spin-lock.
    public init() {
        stateStorage.initialize(to: State.AtomicRepresentation(Self.unlocked))
        state = .init(at: stateStorage)
    }

    deinit {
        stateStorage.deallocate()
    }

    /// Acquire the lock.
    ///
    /// Whenever possible, consider using `Lockable.withLock()` instead of this method and
    /// `unlock`, to simplify lock handling.
    public func lock() {
        repeat {
            // Idea is to wait for unlocked state first to avoid transfer of cache line
            // when the spinlock is locked, since when the owner will unlock it the cache
            // line will be sent back.
            while state.load(ordering: .relaxed) != Self.unlocked {
                _concurrency_helpers_pause()
            }
        } while !state.compareExchange(expected: Self.unlocked, desired: Self.locked, ordering: .acquiringAndReleasing).exchanged
    }

    /// Release the lock.
    ///
    /// Whenever possible, consider using `Lockable.withLock()` instead of this method and
    /// `lock()`, to simplify lock handling.
    public func unlock() {
        state.store(Self.unlocked, ordering: .releasing)
    }
}

extension Spinlock: Lockable {}

#if compiler(>=5.5) && canImport(_Concurrency)
    extension Spinlock: @unchecked Sendable {}
#endif
