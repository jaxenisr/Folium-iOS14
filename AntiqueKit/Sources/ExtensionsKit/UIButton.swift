//
//  UIButton.swift
//  AntiqueKit
//
//  Created by Jarrod Norwell on 7/6/2026.
//

import ColourKit
import UIKit

public typealias Actions = (touchDown: (UIAction) async -> Void, touchUpInsideOutside: (UIAction) async -> Void)

/// A button style that works on iOS 14 as well as the iOS 15+ `UIButton.Configuration` API.
/// The iOS 15+ path still builds a real `UIButton.Configuration` so modern devices keep the
/// system look; on iOS 14 the same values are applied with the legacy UIButton properties.
public struct FoliumButtonConfiguration {
    public enum Size {
        case medium, large
    }

    public enum CornerStyle {
        case capsule, fixed, small, medium, large
    }

    public var title: String?
    public var image: UIImage?
    public var buttonSize: Size
    public var cornerStyle: CornerStyle
    public var baseForegroundColor: UIColor?
    public var baseBackgroundColor: UIColor?

    var isGlass: Bool = false

    public init(title: String? = nil, image: UIImage? = nil,
                buttonSize: Size = .medium, cornerStyle: CornerStyle = .capsule,
                baseForegroundColor: UIColor? = nil, baseBackgroundColor: UIColor? = nil) {
        self.title = title
        self.image = image
        self.buttonSize = buttonSize
        self.cornerStyle = cornerStyle
        self.baseForegroundColor = baseForegroundColor
        self.baseBackgroundColor = baseBackgroundColor
    }

    static func glassConfiguration(_ size: Size, _ cornerStyle: CornerStyle,
                                   _ image: UIImage? = nil, _ text: String? = nil, _ scale: UIImage.SymbolScale = .large,
                                   _ tintColor: UIColour? = nil, inverseColor: Bool = false) -> FoliumButtonConfiguration {
        var configuration: FoliumButtonConfiguration = .init(
            title: text,
            image: image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: scale)),
            buttonSize: size,
            cornerStyle: cornerStyle
        )
        configuration.isGlass = true

        if let tintColor {
            configuration.baseBackgroundColor = inverseColor ? tintColor : .clear
            configuration.baseForegroundColor = inverseColor ? .white : tintColor
        }

        return configuration
    }

    static func filledConfiguration(_ size: Size, _ cornerStyle: CornerStyle,
                                    _ image: UIImage? = nil, _ text: String? = nil, _ scale: UIImage.SymbolScale = .large) -> FoliumButtonConfiguration {
        .init(title: text,
              image: image?.applyingSymbolConfiguration(UIImage.SymbolConfiguration(scale: scale)),
              buttonSize: size,
              cornerStyle: cornerStyle,
              baseForegroundColor: .systemBackground,
              baseBackgroundColor: .label)
    }

    public static func filled() -> FoliumButtonConfiguration {
        filledConfiguration(.medium, .capsule)
    }

    public static func glass() -> FoliumButtonConfiguration {
        glassConfiguration(.medium, .capsule)
    }

    public static func configuration(_ size: Size, _ cornerStyle: CornerStyle,
                                     _ image: UIImage? = nil, _ text: String? = nil, _ scale: UIImage.SymbolScale? = .large,
                                     _ tintColor: UIColour? = nil, inverseColor: Bool = false) -> FoliumButtonConfiguration {
        if #available(iOS 26, *) {
            glassConfiguration(size, cornerStyle, image, text, scale ?? .large, tintColor, inverseColor: inverseColor)
        } else {
            filledConfiguration(size, cornerStyle, image, text, scale ?? .large)
        }
    }

    @available(iOS 15, *)
    var uiConfiguration: UIButton.Configuration {
        var configuration: UIButton.Configuration = if #available(iOS 26, *), isGlass {
            .glass()
        } else {
            .filled()
        }

        configuration.title = title
        configuration.image = image
        configuration.buttonSize = buttonSize == .large ? .large : .medium
        configuration.cornerStyle = cornerStyle == .capsule ? .capsule : .fixed

        if let baseBackgroundColor {
            configuration.baseBackgroundColor = baseBackgroundColor
        }

        if let baseForegroundColor {
            configuration.baseForegroundColor = baseForegroundColor
        }

        return configuration
    }

    /// iOS 14 fallback: apply the same values with the pre-configuration UIButton API.
    func apply(to button: UIButton) {
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        button.tintColor = baseForegroundColor ?? .label
        button.setTitleColor(baseForegroundColor ?? .systemBackground, for: .normal)
        button.backgroundColor = baseBackgroundColor ?? .label
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -6, bottom: 0, right: 6)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: -6)
        button.layer.cornerRadius = cornerStyle == .capsule ? 22 : 12
        button.clipsToBounds = true
    }
}

public extension UIButton {
    convenience init(buttonConfiguration configuration: FoliumButtonConfiguration) {
        if #available(iOS 15, *) {
            self.init(configuration: configuration.uiConfiguration)
        } else {
            self.init(type: .system)
            configuration.apply(to: self)
        }
    }

    static func button(with configuration: FoliumButtonConfiguration, actions: Actions, _ menu: UIMenu? = nil) -> UIButton {
        let button: UIButton = .init(buttonConfiguration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false

        if let menu {
            button.menu = menu
            button.showsMenuAsPrimaryAction = true
        } else {
            button.addAction(UIAction { action in
                Task {
                    await actions.touchDown(action)
                }
            }, for: .touchDown)

            button.addAction(UIAction { action in
                Task {
                    await actions.touchUpInsideOutside(action)
                }
            }, for: .touchUpInside)

            button.addAction(UIAction { action in
                Task {
                    await actions.touchUpInsideOutside(action)
                }
            }, for: .touchUpOutside)
        }

        if #unavailable(iOS 26) {
            button.layer.shadowColor = UIColour.black.cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 10)
            button.layer.shadowOpacity = 1 / 5
            button.layer.shadowRadius = 20
        }

        return button
    }
}
