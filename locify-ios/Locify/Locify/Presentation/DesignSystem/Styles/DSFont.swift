//
//  DSFont.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 9/7/25.
//

import SwiftUI

/// A design system enum that defines font styles used in the app.
/// Each case represents a font weight with an associated `DSFontSize`.
enum DSFont {
    case regular(DSFontSize), medium(DSFontSize), bold(DSFontSize)

    /// Retrieves the corresponding `Font.Weight` for each font style.
    var weight: Font.Weight {
        switch self {
        case .regular: .regular
        case .medium: .medium
        case .bold: .bold
        }
    }

    /// Retrieves the font size based on the associated `DSFontSize` case.
    var size: CGFloat {
        switch self {
        case .regular(let size), .medium(let size), .bold(let size): size.size
        }
    }
}

enum DSFontSize {
    case small, medium, large, custom(CGFloat)

    /// Retrieves the corresponding font size in points.
    var size: CGFloat {
        switch self {
        case .small: 13
        case .medium: 16
        case .large: 20
        case .custom(let size): size
        }
    }
}

extension Font {
    /// Retrieves a system font with the specified `DSFont` configuration.
    ///
    /// - Parameter font: The `DSFont` case defining the size and weight.
    /// - Returns: A `Font` instance with the specified weight and size.
    static func appFont(_ font: DSFont) -> Self {
        .system(size: font.size, weight: font.weight)
    }
}
