//
//  UIImage.swift
//  Folium
//
//  Created by Jarrod Norwell on 22/6/2026.
//

import UIKit

extension UIImage {
    var valid: Bool { !cgImage.isNil || !ciImage.isNil && size != .zero }
}


extension UIColor {
    static var foliumTint: UIColor {
        if #available(iOS 15.0, *) {
            return .tintColor
        }

        return .systemBlue
    }
}

extension UIImage.SymbolConfiguration {
    static func palette(_ colors: [UIColor]) -> UIImage.SymbolConfiguration {
        if #available(iOS 15.0, *) {
            return UIImage.SymbolConfiguration(paletteColors: colors)
        }

        return UIImage.SymbolConfiguration(pointSize: 17.0, weight: .regular)
    }
}
