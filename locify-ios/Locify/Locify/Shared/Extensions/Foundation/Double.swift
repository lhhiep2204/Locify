//
//  Double.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 10/1/26.
//

import Foundation

extension Double {
    /// Rounds the value to a specified number of decimal places
    /// - Parameter places: Number of decimal places
    /// - Returns: Rounded value
    func rounded(toDecimalPlaces places: Int) -> Self {
        guard places >= 0 else { return self }

        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }

    /// Formats a distance in meters into a human-readable string.
    ///
    /// Displays kilometers (1 decimal place) when the distance is 1000 m or more,
    /// and meters (rounded to nearest integer) when below 1000 m.
    /// Trailing `.0` decimals are stripped in both cases.
    ///
    /// Examples:
    /// - `500`    → `"500 m"`
    /// - `999`    → `"999 m"`
    /// - `1000`   → `"1 km"`
    /// - `1500`   → `"1.5 km"`
    /// - `12000`  → `"12 km"`
    /// - `23400`  → `"23.4 km"`
    ///
    /// - Returns: A formatted distance string with the appropriate unit.
    var formattedDistance: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1

        if self >= 1000 {
            let kilometer = self / 1000
            let formatted = formatter.string(from: NSNumber(value: kilometer)) ?? "\(kilometer)"
            return "\(formatted) km"
        } else {
            let meter = self.rounded(.toNearestOrAwayFromZero)
            let formatted = formatter.string(from: NSNumber(value: meter)) ?? "\(Int(meter))"
            return "\(formatted) m"
        }
    }
}
