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
}
