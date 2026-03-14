//
//  TimeInterval.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/3/26.
//

import Foundation

extension TimeInterval {
    /// Formats a time interval (seconds) into a human-readable string
    /// using days, hours, and minutes.
    ///
    /// Examples:
    /// - 70          → "1m"
    /// - 3_600       → "1h"
    /// - 3_660       → "1h 1m"
    /// - 86_400      → "1d"
    /// - 90_000      → "1d 1h"
    /// - 172_800+60  → "2d 1m"
    ///
    /// - Returns: A string like "1d 2h 5m". If < 1 minute, returns "0m".
    var formattedETA: String {
        let totalMinutes = Int(self / 60)
        if totalMinutes <= 0 { return "0m" }

        let days = totalMinutes / (24 * 60)
        let hours = (totalMinutes % (24 * 60)) / 60
        let minutes = totalMinutes % 60

        var components: [String] = []

        if days > 0 {
            components.append("\(days)d")
        }
        if hours > 0 {
            components.append("\(hours)h")
        }
        if minutes > 0 {
            components.append("\(minutes)m")
        }

        return components.joined(separator: " ")
    }
}
