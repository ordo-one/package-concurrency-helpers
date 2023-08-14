// Copyright 2023 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

// Calculate next highest power of 2
public func nearestPowerOf2<T: FixedWidthInteger>(_ num: T) -> T {
    return T(1) << (num.bitWidth - (num - T(1)).leadingZeroBitCount)
}
