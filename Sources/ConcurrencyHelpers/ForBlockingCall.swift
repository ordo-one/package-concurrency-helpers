// Copyright 2022 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

import Dispatch

/// This function is a helper for calling blocking function from Task
/// and properly suspend the Task while such call take place.
/// The blocking function call happens in global dispatch queue
/// and when it's done calls continuation to resume suspended Task.
///
/// #### Usage example:
///  ```swift
///  Task {
///      let result = await forBlockingFunc {
///          myBlockingFunction()
///      }
///      // end here only when myBlockingFunction() is done
///  }
///  ```
///
/// - Parameter queue: The queue where blocking call will be invoked
/// - Parameter body: Function to be called in the `queue`
///
/// - Returns: The function returns a value returned by `body` function
public func forBlockingFunc<T>(queue: DispatchQueue = .global(),
                               body: @escaping () -> T) async -> T {
    await withCheckedContinuation { continuation in
        queue.async {
            continuation.resume(returning: body())
        }
    }
}
