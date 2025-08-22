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
    case accent = "app.primary"

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

    /// Shade
    case gray20 = "gray.20"
    case gray40 = "gray.40"
    case gray60 = "gray.60"
    case gray80 = "gray.80"
    case gray100 = "gray.100"
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
