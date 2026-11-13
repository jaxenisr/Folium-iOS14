//
//  JITSupport.swift
//  Folium
//

import Darwin

/// Detects whether this process may execute memory it writes to.
///
/// The 3DS core compiles guest code with dynarmic, which needs writable memory that can be
/// turned executable. iOS only allows that when the app was launched with a JIT enabler
/// attached (a debugger, hence `get-task-allow`) or when it carries the `dynamic-codesigning`
/// entitlement, as TrollStore-style installers grant on iOS 14 and later.
///
/// Without it the first jump into compiled code crashes the app, so the CPU and shader JIT
/// settings are only enabled by default when this probe succeeds. Users can still turn them
/// on manually in Settings, and the interpreter is used otherwise.
nonisolated enum JITSupport {
    static let isAvailable: Bool = {
        let pageSize: Int = Int(sysconf(_SC_PAGESIZE))
        guard pageSize > 0 else {
            return false
        }

        guard let address: UnsafeMutableRawPointer = mmap(nil, pageSize, PROT_READ | PROT_WRITE,
                                                          MAP_PRIVATE | MAP_ANON, -1, 0),
              address != MAP_FAILED else {
            return false
        }
        defer {
            _ = munmap(address, pageSize)
        }

        return mprotect(address, pageSize, PROT_READ | PROT_EXEC) == 0
    }()
}
