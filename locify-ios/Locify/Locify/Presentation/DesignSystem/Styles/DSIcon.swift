//
//  DSIcon.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 9/7/25.
//

import SwiftUI

/// A design system enum that defines custom icons used in the app.
enum DSIcon: String {
    // MARK: - M
    case marker = "ic.marker"
}

/// A design system enum that defines system-provided SF Symbols used in the app.
enum DSSystemIcon: String {
    // MARK: - C
    case clearText = "multiply.circle.fill"
    case close = "xmark"

    // MARK: - D
    case delete = "trash"

    // MARK: - E
    case edit = "square.and.pencil"

    // MARK: - L
    case list = "list.bullet"
    case location = "location"

    // MARK: - P
    case passwordShown = "eye"
    case passwordHidden = "eye.slash"

    // MARK: - S
    case search = "magnifyingglass"
    case settings = "gear"
    case share = "square.and.arrow.up"
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
