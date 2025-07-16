//
//  DSColor.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 9/7/25.
//

import SwiftUI

/// A design system enum that defines color names used in the app.
/// These values should match the color names defined in the asset catalog.
enum DSColor: String {
    /// Accent Colors
    case accent = "AccentColor"

    /// Background Colors
    case backgroundPrimary = "background.primary"
    case backgroundSecondary = "background.secondary"
    case backgroundPrimaryInverted = "background.primary.inverted"
    case backgroundSecondaryInverted = "background.secondary.inverted"

    /// Text Colors
    case textPrimary = "text.primary"
    case textSecondary = "text.secondary"
    case textPrimaryInverted = "text.primary.inverted"
    case textSecondaryInverted = "text.secondary.inverted"
}

extension Color {
    /// Retrieves a color from the asset catalog using `DSColor`.
    ///
    /// - Parameter color: The `DSColor` enum case representing the desired color.
    /// - Returns: A `Color` instance corresponding to the specified `DSColor`.
    static func appColor(_ color: DSColor) -> Self {
        .init(color.rawValue)
    }
}
