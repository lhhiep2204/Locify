//
//  String.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 15/7/25.
//

import Foundation

extension String {
    /// An empty string (`""`). Shortcut for readability.
    static let empty: String = ""

    /// Returns a new string with leading and trailing whitespace and newlines removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Replaces all occurrences of a target substring with a given replacement string.
    ///
    /// - Parameters:
    ///   - target: The substring to search for.
    ///   - replacement: The string to replace each occurrence with.
    /// - Returns: A new string with the replacements applied.
    func replace(_ target: String, with replacement: String) -> String {
        replacingOccurrences(of: target, with: replacement)
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
