//
//  DSIcon.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 9/7/25.
//

import SwiftUI

/// A design system enum that defines custom icons used in the app.
enum DSIcon: String {
    case marker = "ic.marker"
}

/// A design system enum that defines system-provided SF Symbols used in the app.
enum DSSystemIcon: String {
    case clearText = "multiply.circle.fill"
    case location = "location"
    case passwordShown = "eye"
    case passwordHidden = "eye.slash"
}

extension Image {
    /// Retrieves a custom app image icon.
    ///
    /// - Parameter icon: The `DSIcon` case representing the custom icon name.
    /// - Returns: An `Image` instance initialized with the specified custom icon name.
    static func appIcon(_ icon: DSIcon) -> Self {
        .init(icon.rawValue)
    }

    /// Retrieves a system SF Symbol icon.
    ///
    /// - Parameter icon: The `DSSystemIcon` case representing the SF Symbol name.
    /// - Returns: An `Image` instance initialized with the specified system icon name.
    static func appSystemIcon(_ icon: DSSystemIcon) -> Self {
        .init(systemName: icon.rawValue)
    }
}
