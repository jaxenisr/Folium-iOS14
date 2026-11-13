//
//  ArticBase.swift
//  Folium
//

import Foundation

/// Helpers for launching a 3DS game straight from a physical console running Artic Base.
///
/// Cytrus accepts the pseudo-URL `articbase://host[:port]` in place of a game file. The core
/// connects to the Artic Base server on the console, which streams the already-running title
/// (and its save data) to the emulator over the local network.
nonisolated enum ArticBase {
    /// The port Artic Base uses when the address does not specify one.
    static let defaultPort: UInt16 = 5543

    /// UserDefaults key remembering the last address entered by the user.
    static let addressKey: String = "cytrus.articBaseAddress"

    /// Validates a user supplied address (`host` or `host:port`) and returns it in the form
    /// Cytrus expects. Returns `nil` when the address cannot be used.
    static func address(from rawValue: String) -> String? {
        let trimmed: String = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              !trimmed.contains(where: { $0.isWhitespace || $0 == "/" }) else {
            return nil
        }

        let host: String
        var port: UInt16 = defaultPort

        if let separator = trimmed.lastIndex(of: ":") {
            host = String(trimmed[trimmed.startIndex..<separator])

            guard let parsedPort = UInt16(String(trimmed[trimmed.index(after: separator)...])),
                  parsedPort > 0 else {
                return nil
            }

            port = parsedPort
        } else {
            host = trimmed
        }

        guard !host.isEmpty else {
            return nil
        }

        return port == defaultPort ? host : "\(host):\(port)"
    }

    /// Builds the pseudo-URL the Cytrus loader recognises.
    static func url(for rawValue: String) -> URL? {
        guard let address: String = address(from: rawValue) else {
            return nil
        }

        return URL(string: "articbase://\(address)")
    }
}
