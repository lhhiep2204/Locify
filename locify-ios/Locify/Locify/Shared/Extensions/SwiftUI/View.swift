//
//  View.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 15/7/25.
//

import SwiftUI

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Applies the given transform if the given condition evaluates to `true`, otherwise applies the `elseTransform`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: A closure that modifies the `View` if the condition is met.
    ///   - elseTransform: A closure that modifies the `View` if the condition is not met.
    /// - Returns: Either the transformed `View` based on the `condition`.
    @ViewBuilder
    func `if`<IfContent: View, ElseContent: View>(
        _ condition: Bool,
        transform: (Self) -> IfContent,
        else elseTransform: (Self) -> ElseContent
    ) -> some View {
        if condition {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
}
