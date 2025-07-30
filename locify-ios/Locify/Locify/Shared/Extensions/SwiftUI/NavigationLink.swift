//
//  NavigationLink.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import SwiftUI

extension NavigationLink where Destination == Never {
    /// Initializes a `NavigationLink` using a `Route` value as the destination.
    ///
    /// This simplifies creating links when using a navigation system driven by `Route`.
    ///
    /// - Parameters:
    ///   - value: The destination route.
    ///   - label: A closure returning the label view.
    init(_ value: Route, @ViewBuilder label: () -> Label) {
        self.init(value: value, label: label)
    }
}
