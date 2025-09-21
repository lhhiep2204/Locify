//
//  PresentationDetent.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 19/9/25.
//

import SwiftUI

extension PresentationDetent {
    /// A custom small detent that takes up **25% of the available screen height**.
    ///
    /// Use this detent when you want to display a small portion of content
    /// while keeping most of the main screen visible.
    static let small = PresentationDetent.fraction(0.25)
}
