//
//  GameDetails.swift
//  Folium
//
//  Created by Jarrod Norwell on 17/6/2026.
//

import Foundation.NSURL

nonisolated final class Details {
    let fileExtension: String
    var fileName, fileSize: String
    var fileURL: URL
    
    init(_ url: URL) {
        let formatter: ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        fileExtension = url.lowercasedPathExtension
        fileName = url.deletingPathExtension().lastPathComponent
            .replacingOccurrences(of: #"\s*\([^)]*\)"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
            fileSize = if let fileSize = resourceValues.fileSize {
                formatter.string(fromByteCount: Int64(fileSize))
            } else {
                formatter.string(fromByteCount: 0)
            }
        } catch {
            fileSize = formatter.string(fromByteCount: 0)
        }
        
        fileURL = url
    }
    
    /// Creates details for a 3DS game streamed from a console running Artic Base.
    init(articBaseAddress address: String) {
        fileExtension = "articbase"
        fileName = "Artic Base (\(address))"
        fileSize = "Streamed"
        fileURL = ArticBase.url(for: address) ?? URL(fileURLWithPath: "/")
    }
    
    var fileNameWithoutSpaces: String {
        fileName.replacingOccurrences(of: " ", with: "_").trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func updateSize(_ byteCount: Int) {
        let formatter: ByteCountFormatter = ByteCountFormatter()
        formatter.countStyle = .file
        
        fileSize = formatter.string(fromByteCount: Int64(byteCount))
    }
}
