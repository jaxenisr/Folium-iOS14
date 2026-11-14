//
//  LaunchDiagnostics.swift
//  Folium
//
//  Writes a small, flushed launch log into the app's Documents directory so a
//  failure on a device without Xcode or a crash reporter still leaves evidence
//  of how far startup got. The log is visible in Files because the app already
//  enables UIFileSharingEnabled.
//

import Foundation

private nonisolated func foliumUncaughtExceptionHandler(_ exception: NSException) {
    LaunchDiagnostics.log("UNCAUGHT \(exception.name.rawValue): \(exception.reason ?? "no reason")")
}

nonisolated enum LaunchDiagnostics {
    private static let queue = DispatchQueue(label: "com.antique.Folium.launchDiagnostics")

    private static let fileURL: URL? = FileManager.default
        .urls(for: .documentDirectory, in: .userDomainMask)
        .first?
        .appendingPathComponent("FoliumLaunch.log")

    static func install() {
        log("=== Folium launch ===")
        NSSetUncaughtExceptionHandler(foliumUncaughtExceptionHandler)
    }

    static func log(_ message: String) {
        let line = "\(Date().timeIntervalSince1970) \(message)\n"
        queue.sync {
            guard let fileURL, let data = line.data(using: .utf8) else {
                return
            }

            if FileManager.default.fileExists(atPath: fileURL.path) {
                guard let handle = try? FileHandle(forWritingTo: fileURL) else {
                    return
                }
                handle.seekToEndOfFile()
                handle.write(data)
                try? handle.synchronize()
                try? handle.close()
            } else {
                try? data.write(to: fileURL)
            }
        }
    }
}
