//
//  CircularGlassEffectModifier.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import SwiftUI

struct CircularGlassEffectModifier: ViewModifier {
    let size: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .contentShape(Circle())
            .glassEffect(.clear.interactive())
    }
}

extension View {
    func circularGlassEffect(size: CGFloat = DSSize.huge) -> some View {
        modifier(CircularGlassEffectModifier(size: size))
    }
}
