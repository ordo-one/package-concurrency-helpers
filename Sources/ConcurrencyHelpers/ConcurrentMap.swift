extension RandomAccessCollection where Self: Sendable, Element: Sendable {
    @inlinable
    public func concurrentMap<B: Sendable>(minBatchSize: Int = 4096, _ transform: @Sendable @escaping (Element) async -> B) async -> [B] {
        precondition(minBatchSize >= 1)
        let n = self.count
        let batchCount = (n + minBatchSize - 1) / minBatchSize
        if batchCount < 2 {
            return await withTaskGroup(of: B.self) { group in
                var results: [B] = []
                for element in self {
                    group.addTask { await transform(element) }
                }
                for await result in group {
                    results.append(result)
                }
                return results
            }
        }

        return await withTaskGroup(of: (Int, [B]).self) { group in
            for batchIndex in 0..<batchCount {
                group.addTask {
                    let startOffset = batchIndex * n / batchCount
                    let endOffset = (batchIndex + 1) * n / batchCount
                    var results = [B]()
                    results.reserveCapacity(endOffset - startOffset)
                    var sourceIndex = index(startIndex, offsetBy: startOffset)
                    for _ in startOffset..<endOffset {
                        let result = await transform(self[sourceIndex])
                        results.append(result)
                        formIndex(after: &sourceIndex)
                    }
                    return (startOffset, results)
                }
            }

            var finalResults = Array<B?>(repeating: nil, count: n)
            for await (startOffset, results) in group {
                for (offset, result) in results.enumerated() {
                    finalResults[startOffset + offset] = result
                }
            }

            return finalResults.compactMap { $0 } // Remove nils, should not be any
        }
    }
}

extension RandomAccessCollection where Self: Sendable, Element: Sendable {
    @inlinable
    public func concurrentMap<B: Sendable>(minBatchSize: Int = 4096, _ transform: @Sendable @escaping (Element) -> B) async -> [B] {
        precondition(minBatchSize >= 1)
        let n = self.count
        let batchCount = (n + minBatchSize - 1) / minBatchSize
        if batchCount < 2 {
            return self.map(transform)
        }

        return await withTaskGroup(of: (Int, [B]).self) { group in
            for batchIndex in 0..<batchCount {
                group.addTask {
                    let startOffset = batchIndex * n / batchCount
                    let endOffset = (batchIndex + 1) * n / batchCount
                    var results = [B]()
                    results.reserveCapacity(endOffset - startOffset)
                    var sourceIndex = index(startIndex, offsetBy: startOffset)
                    for _ in startOffset..<endOffset {
                        let result = transform(self[sourceIndex])
                        results.append(result)
                        formIndex(after: &sourceIndex)
                    }
                    return (startOffset, results)
                }
            }

            var finalResults = Array<B?>(repeating: nil, count: n)
            for await (startOffset, results) in group {
                for (offset, result) in results.enumerated() {
                    finalResults[startOffset + offset] = result
                }
            }

            return finalResults.compactMap { $0 } // Remove nils, should not be any
        }
    }
}
