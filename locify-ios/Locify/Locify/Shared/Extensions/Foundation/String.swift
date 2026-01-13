//
//  String.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 15/7/25.
//

import Foundation

extension String {
    /// An empty string (`""`). Shortcut for readability.
    static let empty: Self = ""

    /// Returns a new string with leading and trailing whitespace and newlines removed.
    var trimmed: Self {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Replaces all occurrences of a target substring with a given replacement string.
    ///
    /// - Parameters:
    ///   - target: The substring to search for.
    ///   - replacement: The string to replace each occurrence with.
    /// - Returns: A new string with the replacements applied.
    func replace(_ target: String, with replacement: String) -> Self {
        replacingOccurrences(of: target, with: replacement)
    }
}

extension String? {
    /// Checks if the string is nil or empty.
    var isNilOrEmpty: Bool {
        self == nil || (self ?? .empty).isEmpty
    }
}

extension String {
    /// Parses a date string intended for user-facing display.
    ///
    /// - Parameter style: The expected format style (e.g. `.dayMonthYear`).
    /// - Returns: A `Date` object if the string is valid; otherwise, `nil`.
    func toDate(style: DateFormatStyle) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = style.rawValue
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter.date(from: self)
    }

    /// Parses a machine-formatted date string (e.g., from API or logs).
    ///
    /// - Parameter style: The expected format style (e.g. `.isoDateTime`).
    /// - Returns: A `Date` object if the string is valid; otherwise, `nil`.
    func toAPIDate(style: DateFormatStyle) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = style.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: self)
    }
}

extension String {
    /// Converts the string to a `Double`.
    ///
    /// Returns `0.0` if the conversion fails.
    var asDouble: Double {
        Double(self) ?? 0.0
    }
}

extension String {
    /// Returns a percent-encoded string for safe use in URLs.
    ///
    /// - Returns: A new string that is URL-safe, or the original string if encoding fails.
    var urlEncoded: Self {
        addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
