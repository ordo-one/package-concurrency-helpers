// Copyright 2002 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

public protocol Releasable {
    func release()
}

public class UnsafeRetained<T: Releasable> {
    public enum ReleasePolicy {
        case release
        case forsake
    }

    public let data: T
    public let policy: ReleasePolicy

    public init(_ data: T, _ policy: ReleasePolicy = .release) {
        self.data = data
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
