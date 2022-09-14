import Dispatch

/// This function is a helper for calling blocking function from Task and properly suspend the Task while such call take place.
/// The blocking function call happens in global dispatch queue and when it's done calls continuation to resume suspended Task.
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
public func forBlockingFunc<T>(queue _: DispatchQueue = .global(),
                               body: @escaping () -> T) async -> T {
    await withCheckedContinuation { continuation in
        DispatchQueue.global().async {
            continuation.resume(returning: body())
        }
    }
}
