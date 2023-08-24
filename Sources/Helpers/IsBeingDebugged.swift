// Copyright 2023 Ordo One AB
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0

#if canImport(Foundation)
import Foundation
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported Platform")
#endif

/// Returns true if the process is currently being traced by a debugger.
public var isBeingDebugged: Bool {
#if os(macOS) || os(iOS)
     var processInfo = kinfo_proc()
     var processInfoSize = MemoryLayout<kinfo_proc>.size
     var processInfoMIB = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]

     let success = processInfoMIB.withUnsafeMutableBytes { pointer in
         guard let name = pointer.bindMemory(to: Int32.self).baseAddress else {
             return false
         }

         return sysctl(name, 4, &processInfo, &processInfoSize, nil, 0) != -1
     }

     guard success else {
         return false
     }

    return (processInfo.kp_proc.p_flag & P_TRACED) != 0
#elseif os(Linux)
    guard let status = try? String(contentsOfFile: "/proc/\(getpid())/status") else {
        return false
    }

    let pairs: [(String, String)] = status.components(separatedBy: .newlines).compactMap {
        let components = $0.components(separatedBy: ":")

        guard components.count == 2 else {
            return nil
        }

        return (components[0], components[1].trimmingCharacters(in: .whitespaces))
    }

    let values = pairs.reduce(into: [:]) { $0[$1.0] = $1.1 }

    guard let string = values["TracerPid"], let tracer = Int(string) else {
        return false
    }

    return tracer != 0
#else
    #error("Unsupported Platform")
#endif
}
