//
//  DSContainerStyle.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/8/25.
//

import SwiftUI

/// A design system view modifier that styles a container with padding, background color,
/// and rounded corners.
///
/// This modifier applies consistent spacing and corner radii based on design system tokens,
/// making it ideal for reusable container-like UI components such as cards, panels, or list items.
struct DSContainerStyleModifier: ViewModifier {
    /// The background color of the container.
    let background: Color
    /// The corner radius applied to the container's shape.
    let cornerRadius: CGFloat
    /// The padding applied inside the container.
    let padding: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    /// Styles the view as a design system container with padding, background color and rounded corners.
    ///
    /// - Parameters:
    ///   - background: The background color of the container. Defaults to `.appColor(.backgroundSecondary)`.
    ///   - cornerRadius: The corner radius of the container shape. Defaults to `DSRadius.huge`.
    ///   - padding: The padding inside the container. Defaults to `DSSpacing.large`.
    ///
    /// - Returns: A view styled as a design system container.
    func dsContainerStyle(
        background: Color = .appColor(.backgroundSecondary),
        cornerRadius: CGFloat = DSRadius.huge,
        padding: CGFloat = DSSpacing.large
    ) -> some View {
        modifier(
            DSContainerStyleModifier(
                background: background,
                cornerRadius: cornerRadius,
                padding: padding
            )
        )
    }
}
