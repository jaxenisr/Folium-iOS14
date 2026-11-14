//
//  UIAction.swift
//  Folium
//
//  Created by Jarrod Norwell on 25/6/2026.
//

import Foundation
import UIKit

typealias AsyncUIActionHandler = (UIAction) async -> Void
typealias AsyncThrowingUIActionHandler = (UIAction) async throws -> Void
typealias ThrowingUIActionHandler = (UIAction) throws -> Void

extension UIAction {
    /// `UIAction`'s subtitle-bearing initializer is iOS 15+, so use a plain action on iOS 14.
    static func compat(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                       identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                       attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off,
                       handler: @escaping UIActionHandler) -> UIAction {
        if #available(iOS 15, *) {
            return UIAction(title: title, subtitle: subtitle, image: image,
                            identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                            attributes: attributes, state: state, handler: handler)
        }

        return UIAction(title: title, image: image,
                        identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                        attributes: attributes, state: state, handler: handler)
    }

    static func async(title: String = "", image: UIImage? = nil,
                      identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                      attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncUIActionHandler) -> UIAction {
        UIAction(title: title, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            Task {
                await handler(action)
            }
        }
    }

    static func async(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                      identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                      attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncUIActionHandler) -> UIAction {
        if #available(iOS 15, *) {
            return UIAction(title: title, subtitle: subtitle, image: image,
                            identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                            attributes: attributes, state: state) { action in
                Task {
                    await handler(action)
                }
            }
        }

        return UIAction(title: title, image: image,
                        identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                        attributes: attributes, state: state) { action in
            Task {
                await handler(action)
            }
        }
    }

    @available(iOS 17, *)
    static func async(title: String = "", subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil,
                      identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                      attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image, selectedImage: selectedImage,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            Task {
                await handler(action)
            }
        }
    }

    static func asyncThrowing(title: String = "", image: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try await handler(action)
            }
        }
    }

    static func asyncThrowing(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncThrowingUIActionHandler) -> UIAction {
        if #available(iOS 15, *) {
            return UIAction(title: title, subtitle: subtitle, image: image,
                            identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                            attributes: attributes, state: state) { action in
                _ = Task {
                    try await handler(action)
                }
            }
        }

        return UIAction(title: title, image: image,
                        identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                        attributes: attributes, state: state) { action in
            _ = Task {
                try await handler(action)
            }
        }
    }

    @available(iOS 17, *)
    static func asyncThrowing(title: String = "", subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil,
                              identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                              attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping AsyncThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image, selectedImage: selectedImage,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try await handler(action)
            }
        }
    }

    static func throwing(title: String = "", image: UIImage? = nil,
                         identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                         attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping ThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, image: image,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try handler(action)
            }
        }
    }

    static func throwing(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                         identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                         attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping ThrowingUIActionHandler) -> UIAction {
        if #available(iOS 15, *) {
            return UIAction(title: title, subtitle: subtitle, image: image,
                            identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                            attributes: attributes, state: state) { action in
                _ = Task {
                    try handler(action)
                }
            }
        }

        return UIAction(title: title, image: image,
                        identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                        attributes: attributes, state: state) { action in
            _ = Task {
                try handler(action)
            }
        }
    }

    @available(iOS 17, *)
    static func throwing(title: String = "", subtitle: String? = nil, image: UIImage? = nil, selectedImage: UIImage? = nil,
                         identifier: UIAction.Identifier? = nil, discoverabilityTitle: String? = nil,
                         attributes: UIMenuElement.Attributes = [], state: UIMenuElement.State = .off, handler: @escaping ThrowingUIActionHandler) -> UIAction {
        UIAction(title: title, subtitle: subtitle, image: image, selectedImage: selectedImage,
                 identifier: identifier, discoverabilityTitle: discoverabilityTitle,
                 attributes: attributes, state: state) { action in
            _ = Task {
                try handler(action)
            }
        }
    }
}


extension UIMenu {
    /// The subtitle initializer is iOS 15+, so use a plain menu on iOS 14.
    static func compat(title: String = "", subtitle: String? = nil, image: UIImage? = nil,
                       identifier: UIMenu.Identifier? = nil, options: UIMenu.Options = [],
                       children: [UIMenuElement] = []) -> UIMenu {
        if #available(iOS 15.0, *), let subtitle {
            return UIMenu(title: title, subtitle: subtitle, image: image,
                          identifier: identifier, options: options, children: children)
        }

        return UIMenu(title: title, image: image, identifier: identifier,
                      options: options, children: children)
    }
}
