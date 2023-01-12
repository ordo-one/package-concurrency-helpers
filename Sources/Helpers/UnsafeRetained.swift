// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

/// Protocol defines a correct way to release an object
public protocol Releasable {
    
    /// The function is called when and only when last reference to the object is dropped
    /// Object have be properly released, owned memory deallocated etc
    func release()
}

/// The helper class for reference counting on top of value type data (like structs or enums)
///
/// #### Usage example:
///
/// ```swift
/// extension UnsafeRawBufferPointer: Releasable {
///     public func release() {
///         deallocate()
///     }
/// }
///
/// let buffer = UnsafeRetained<UnsafeRawBufferPointer>(...)
/// ```
/// This class can be used when multiple readers need to keep a reference to a buffer in memory.
/// Then memory will be deallocated when last reader is done and doesn't need the buffer any more.
///
/// #### Using with `storage`:
///
/// The helper also can additionally keep a reference to `storage` class.
/// The purpose is to increase / decrease reference conting on `storage` class while using the data.
///
/// #### Example with `storage`:
///
/// There is a 3rd party library for interacting other service over network. The library allocates a buffer in memory,
/// read a multiple messages from network and pass the entire buffer to an application. The library requies that application
/// is responsible to deallocataiton of the buffer. Application reads those messages and pass them downstream to multiple readers.
///
/// In thise case the allocated buffer can be wrapped as `UnsafeRetained<AllocatedBuffer>` and passed as `storage` to
/// individual pieces of the entire buffer. The buffer will be deallocated only when all readers are done with reading all messages.
///
public class UnsafeRetained<Data: Releasable> {
    /// Defines release policy for an object
    public enum ReleasePolicy {
        /// Means that `release` function will be invoked when last reference to class is dropped
        case release
        /// Means that `release` function will NOT be called when last reference to class is dropped
        case forsake
    }

    /// Data stored in the class
    public let data: Data
    /// Release policy for the data
    public let policy: ReleasePolicy
    /// The reference to a storage where the data is stored
    public let storage: AnyObject?

    /// Initializer
    ///
    /// - Parameter data: data to be stored
    /// - Parameter policy: release policy for the stored data, default is `release`
    /// - Parameter storage: optional, reference to underlying storage of the date, default is `nil` (no underlying storage)
    public init(_ data: Data, _ policy: ReleasePolicy = .release, _ storage: AnyObject? = nil) {
        self.data = data
        self.storage = storage
        self.policy = policy
    }

    deinit {
        if case .release = policy {
            data.release()
        }
    }
}

public typealias UnsafeRetainedBufferUInt8 = UnsafeRetained<UnsafeBufferPointer<UInt8>>
public typealias UnsafeRetainedRawBuffer = UnsafeRetained<UnsafeRawBufferPointer>

extension UnsafeBufferPointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafeMutablePointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafeMutableRawPointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafePointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafeRawPointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafeRawBufferPointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafeMutableBufferPointer: Releasable {
    public func release() {
        deallocate()
    }
}

extension UnsafeMutableRawBufferPointer: Releasable {
    public func release() {
        deallocate()
    }
}
