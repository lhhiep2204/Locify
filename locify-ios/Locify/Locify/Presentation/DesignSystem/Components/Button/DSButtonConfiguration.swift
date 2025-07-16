//
//  DSButtonConfiguration.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 16/7/25.
//

import SwiftUI

/// Represents different types of buttons used in the design system.
indirect enum DSButtonType: Equatable {
    /// A filled button with a defined size.
    case filled(DSButtonSize)
    /// A bordered button with a defined size.
    case bordered(DSButtonSize)
    /// An icon-based button with a specific icon type.
    case icon(DSIconButtonType)

    /// Determines the size mode for the button (fit or fill).
    var sizeMode: DSButtonLayoutMode {
        switch self {
        case .bordered(let size), .filled(let size):
            switch size {
            case .small(let sizeMode), .medium(let sizeMode), .large(let sizeMode):
                return sizeMode
            }
        case .icon:
            return .adaptive
        }
    }

    /// Retrieves the appropriate font size for the button.
    var fontSize: Font {
        size.fontSize
    }

    /// Retrieves the padding value for the button.
    var padding: CGFloat {
        size.padding
    }

    /// Retrieves the height value for the button.
    var height: CGFloat {
        size.height
    }

    /// Retrieves the associated button size.
    private var size: DSButtonSize {
        switch self {
        case .bordered(let size), .filled(let size):
            return size
        case .icon(let buttonType):
            return buttonType.type.size
        }
    }
}

/// Defines different types of icon-based buttons.
enum DSIconButtonType: Equatable {
    /// A normal icon button with a specific button type.
    case normal(DSButtonType)
    /// A circular icon button with a specific button type.
    case circular(DSButtonType)

    /// Retrieves the associated button type.
    var type: DSButtonType {
        switch self {
        case .normal(let type), .circular(let type):
            return type
        }
    }
}

/// Defines the different sizes for buttons in the design system.
enum DSButtonSize: Equatable {
    /// A small button with a specific size mode.
    case small(DSButtonLayoutMode)
    /// A medium button with a specific size mode.
    case medium(DSButtonLayoutMode)
    /// A large button with a specific size mode.
    case large(DSButtonLayoutMode)

    /// Retrieves the font size for the button based on its size.
    var fontSize: Font {
        switch self {
        case .small: .appFont(.bold(.custom(12)))
        case .medium: .appFont(.bold(.custom(14)))
        case .large: .appFont(.bold(.custom(16)))
        }
    }

    /// Retrieves the padding value for the button.
    var padding: CGFloat {
        switch self {
        case .small: 12
        case .medium: 14
        case .large: 16
        }
    }

    /// Retrieves the height value for the button.
    var height: CGFloat {
        switch self {
        case .small: 24
        case .medium: 32
        case .large: 40
        }
    }
}

/// Defines the size mode of a button, determining how it should be displayed.
enum DSButtonLayoutMode {
    /// The button adjusts its size to fit its content.
    case adaptive
    /// The button expands to fill its available space.
    case expanded
}
