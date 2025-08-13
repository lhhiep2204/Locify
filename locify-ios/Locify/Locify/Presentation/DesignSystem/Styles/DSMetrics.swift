//
//  DSMetrics.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 9/7/25.
//

import Foundation

/// Common spacing constants for layout and padding.
enum DSSpacing {
    /// zero: 0 - No spacing
    static let zero: CGFloat = 0
    /// xSmall: 4 - For fine details or tight layouts
    static let xSmall: CGFloat = 4
    /// small: 8 - Standard spacing between small UI elements
    static let small: CGFloat = 8
    /// medium: 12 - Spacing between grouped elements
    static let medium: CGFloat = 12
    /// large: 16 - Common container padding (Apple recommended)
    static let large: CGFloat = 16
    /// xLarge: 24 - For wide separation or section spacing
    static let xLarge: CGFloat = 24
    /// xxLarge: 32 - For extra spacious layouts
    static let xxLarge: CGFloat = 32
    /// huge: 40 - Hero sections or large vertical gaps
    static let huge: CGFloat = 40
}

/// Corner radius constants for rounded UI components.
enum DSRadius {
    /// zero: 0 - No corner radius
    static let zero: CGFloat = 0
    /// small: 4 - Subtle rounding for controls
    static let small: CGFloat = 4
    /// medium: 8 - Standard for buttons and fields
    static let medium: CGFloat = 8
    /// large: 12 - Cards or accent panels
    static let large: CGFloat = 12
    /// xLarge: 16 - Extra large, prominent elements
    static let xLarge: CGFloat = 16
    /// huge: 28 - Very large, pill-shaped buttons or containers
    static let huge: CGFloat = 28
}

/// Size constants for consistent component dimensions.
enum DSSize {
    /// zero: 0 - No size
    static let zero: CGFloat = 0
    /// xSmall: 4 - Tiny icons or details
    static let xSmall: CGFloat = 4
    /// small: 8 - Small icons or tap targets
    static let small: CGFloat = 8
    /// medium: 16 - Standard icon/button size
    static let medium: CGFloat = 16
    /// large: 24 - Container or image size
    static let large: CGFloat = 24
    /// xLarge: 32 - Large icons or controls
    static let xLarge: CGFloat = 32
    /// huge: 40 - Prominent UI elements
    static let huge: CGFloat = 40
}

/// Border stroke thickness constants.
enum DSStroke {
    /// zero: 0 - No border
    static let zero: CGFloat = 0
    /// thin: 1 - Standard hairline border
    static let thin: CGFloat = 1
    /// thick: 2 - Emphasized border
    static let thick: CGFloat = 2
    /// thicker: 4 - Highlight or separation
    static let thicker: CGFloat = 4
    /// thickest: 6 - Strong visual emphasis
    static let thickest: CGFloat = 6
}
