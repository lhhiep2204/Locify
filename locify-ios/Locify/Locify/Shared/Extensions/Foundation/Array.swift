//
//  Array.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/7/25.
//

import Foundation

extension Array {
    /// Safely accesses an element at the specified index, returning `nil` if the index is out of bounds.
    ///
    /// - Parameter index: The index of the element to access.
    /// - Returns: The element at the specified index if it exists, or `nil` if the index is out of bounds.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
