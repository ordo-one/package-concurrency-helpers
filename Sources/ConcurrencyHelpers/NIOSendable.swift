//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2021-2022 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

// Adopted from SwiftNIO for boxing values between concurrency domains when needed

/*
 #if swift(>=5.5) && canImport(_Concurrency)
 public typealias NIOSendable = Swift.Sendable
 #else
 public typealias NIOSendable = Any
 #endif

 #if swift(>=5.6)
 @preconcurrency public protocol NIOPreconcurrencySendable: Sendable {}
 #else
 public protocol NIOPreconcurrencySendable {}
 #endif
 */

/// ``UnsafeTransfer`` can be used to make non-`Sendable` values `Sendable`.
/// As the name implies, the usage of this is unsafe because it disables the sendable checking of the compiler.
/// It can be used similar to `@unsafe Sendable` but for values instead of types.

public struct UnsafeTransfer<Wrapped> {
    public var wrappedValue: Wrapped

    @inlinable
    public init(_ wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }
}

#if swift(>=5.5) && canImport(_Concurrency)
    extension UnsafeTransfer: @unchecked Sendable {}
#endif

extension UnsafeTransfer: Equatable where Wrapped: Equatable {}
extension UnsafeTransfer: Hashable where Wrapped: Hashable {}

/// ``UnsafeMutableTransferBox`` can be used to make non-`Sendable` values `Sendable` and mutable.
/// It can be used to capture local mutable values in a `@Sendable` closure and mutate them from within the closure.
/// As the name implies, the usage of this is unsafe because it disables the sendable checking of the compiler and does not add any synchronisation.
public final class UnsafeMutableTransferBox<Wrapped> {
    public var wrappedValue: Wrapped

    @inlinable
    public init(_ wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }
}

#if swift(>=5.5) && canImport(_Concurrency)
    extension UnsafeMutableTransferBox: @unchecked Sendable {}
#endif
