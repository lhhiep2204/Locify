//
//  DSButtonStyle.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 16/7/25.
//

import SwiftUI

/// A custom button style for `DSButton` that defines the appearance based on the button's type.
struct DSButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled  // Access to the button's enabled state

    /// The type of the button
    private let type: DSButtonType

    /// The primary color used for the button
    private let primaryColor: Color

    /// The secondary color used for the button
    private let secondaryColor: Color

    /// Indicates whether the background is translucent.
    private let translucent: Bool

    /// Initializes a new `DSButtonStyle` with a specific type and optional color values.
    /// - Parameters:
    ///   - type: The type of the button (e.g., filled, bordered, icon, etc.)
    ///   - primaryColor: The primary color for the button (default is `.teal`)
    ///   - secondaryColor: The secondary color for the button (default is `.appColor(.bgPrimary)`)
    init(
        type: DSButtonType,
        primaryColor: Color = .appColor(.accent),
        secondaryColor: Color = .appColor(.backgroundPrimary),
        translucent: Bool = true
    ) {
        self.type = type
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.translucent = translucent
    }

    /// Builds the body of the button style, configuring its appearance based on the button's state.
    /// - Parameter configuration: The configuration containing the button's label and state.
    /// - Returns: The view representing the button with its defined style.
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .if(isIcon) {  // Custom modifier to handle icon-specific styling
                $0.frame(width: type.height, height: type.height)
            } else: {
                $0.lineLimit(1)
                    .padding(.horizontal, type.padding)
                    .frame(height: type.height)
                    .if(type.sizeMode == .expanded) {
                        $0.frame(maxWidth: 400)
                    }
            }
            .font(type.fontSize)
            .foregroundStyle(isBordered ? primaryColor : secondaryColor)  // Set text color based on button type
            .if(translucent) { // Set background color based on button type
                $0.background(isBordered ? secondaryColor.opacity(0.6) : primaryColor)
            } else: {
                $0.background(isBordered ? secondaryColor : primaryColor)
            }
            .if(isBordered) {  // Apply border for bordered button types
                $0.overlay(
                    RoundedRectangle(
                        cornerRadius: type.height / 2
                    )
                    .strokeBorder(lineWidth: DSStroke.thin)
                    .foregroundStyle(isBordered ? primaryColor : secondaryColor)  // Border color
                )
            }
            .clipShape(
                RoundedRectangle(
                    cornerRadius: type.height / 2
                )
            )  // Rounded corners
            .opacity(configuration.isPressed || !isEnabled ? 0.6 : 1)  // Dim the button when pressed or disabled
    }
}

private extension DSButtonStyle {
    /// Checks if the button type is a filled button.
    var isFilled: Bool {
        switch type {
        case .filled, .icon(.normal(.filled)), .icon(.circular(.filled)): true
        default: false
        }
    }

    /// Checks if the button type is a bordered button.
    var isBordered: Bool {
        switch type {
        case .bordered, .icon(.normal(.bordered)), .icon(.circular(.bordered)): true
        default: false
        }
    }

    /// Checks if the button type is an icon button.
    var isIcon: Bool {
        switch type {
        case .icon: true
        default: false
        }
    }
}
