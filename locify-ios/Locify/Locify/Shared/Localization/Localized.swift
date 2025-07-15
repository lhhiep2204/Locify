//
//  Localized.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 15/7/25.
//

import SwiftUI

// MARK: - LocalizedKey Protocol

/// A key for localized strings, backed by a String raw value.
protocol LocalizedKey: RawRepresentable where RawValue == String {}

extension LocalizedKey {
    var identifier: String { rawValue }
}

// MARK: - String Localization

extension String {
    /// Returns the localized string for the given key using a custom bundle.
    static func localized(_ key: some LocalizedKey) -> String {
        NSLocalizedString(key.identifier, comment: "")
    }
}

// MARK: - SwiftUI Helpers

extension Text {
    /// Initializes a Text view using a LocalizedKey.
    init(_ key: some LocalizedKey) {
        self.init(String.localized(key))
    }
}

extension Button where Label == Text {
    /// Initializes a Button using a LocalizedKey as the title.
    init(_ key: some LocalizedKey, action: @escaping () -> Void) {
        self.init(String.localized(key), action: action)
    }
}
