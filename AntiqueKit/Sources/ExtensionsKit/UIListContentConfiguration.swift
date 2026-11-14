//
//  UIListContentConfiguration.swift
//  ExtensionsKit
//

import UIKit

@available(iOS 14.0, *)
public extension UIListContentConfiguration {
    /// The prominent inset-grouped header used by Folium's list screens.
    /// `extraProminentInsetGroupedHeader()` is iOS 15+, so fall back to a
    /// manually styled grouped header on iOS 14.
    static func foliumExtraProminentInsetGroupedHeader() -> UIListContentConfiguration {
        if #available(iOS 15.0, *) {
            return .extraProminentInsetGroupedHeader()
        }

        var configuration = UIListContentConfiguration.groupedHeader()
        configuration.textProperties.font = .boldSystemFont(ofSize: 22.0)
        return configuration
    }
}
