//
//  OBControllerWithListConfiguration.swift
//  AntiqueKit
//
//  Created by Jarrod Norwell on 13/5/2026.
//

import ExtensionsKit
import UIKit

public struct OBControllerWithListConfiguration {
    public var image: UIImage? = nil
    public let textConfiguration, secondaryConfiguration: LabelConfiguration
    public var tertiaryConfiguration: LabelConfiguration? = nil
    
    public let buttons: [(configuration: FoliumButtonConfiguration, action: @MainActor (UIViewController) async -> Void)]
    public let cells: [String : [CellConfiguration]]
    
    public init(image: UIImage? = nil,
                textConfiguration: LabelConfiguration, secondaryConfiguration: LabelConfiguration, tertiaryConfiguration: LabelConfiguration? = nil,
                buttons: [(configuration: FoliumButtonConfiguration, action: @MainActor (UIViewController) async -> Void)],
                cells: [String : [CellConfiguration]]) {
        self.image = image
        self.textConfiguration = textConfiguration
        self.secondaryConfiguration = secondaryConfiguration
        self.tertiaryConfiguration = tertiaryConfiguration
        self.buttons = buttons
        self.cells = cells
    }
}
