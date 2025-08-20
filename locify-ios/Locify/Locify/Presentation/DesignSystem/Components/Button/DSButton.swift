//
//  DSButton.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 16/7/25.
//

import SwiftUI

/// A customizable button component supporting various styles, loading states, and images.
struct DSButton<Style: ButtonStyle>: View {
    /// The button text.
    private let title: String?

    /// The button image (optional).
    private let image: Image?

    /// The button style.
    private let style: Style

    /// Indicates whether the button is in a loading state.
    private let loading: Bool

    /// The action executed when the button is tapped.
    private let action: () -> Void

    /// Creates a `DSButton` with the specified properties.
    ///
    /// - Parameters:
    ///   - title: The button text (optional).
    ///   - image: An optional image displayed alongside the text.
    ///   - style: The button style.
    ///   - loading: Whether the button shows a loading indicator. Defaults to `false`.
    ///   - action: The closure executed when the button is tapped.
    init(
        _ title: String? = nil,
        image: Image? = nil,
        style: Style,
        loading: Bool = false,
        _ action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.style = style
        self.loading = loading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                HStack {
                    image
                    title.map { Text($0) }
                }
                if loading {
                    ProgressView()
                        .tint(.appColor(.textPrimary))
                }
            }
        }
        .buttonStyle(style)
        .disabled(loading)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DSSpacing.large) {
            // Filled Buttons
            DSButton(
                "Filled Small",
                style: .filledSmall
            ) {}
            DSButton(
                "Filled Small Fit",
                style: .filledSmallFit
            ) {}
            DSButton(
                "Filled Medium",
                style: .filled
            ) {}
            DSButton(
                "Filled Large",
                style: .filledLarge
            ) {}
                .disabled(true)
            DSButton(
                "Filled Large Fit",
                style: .filledLargeFit
            ) {}
            DSButton(
                "Filled Destructive",
                style: .filledDestructive,
                loading: true
            ) {}
            DSButton(
                "Filled Destructive Large Fit",
                style: .filledDestructiveLargeFit
            ) {}

            // Bordered Buttons
            DSButton(
                "Bordered Small",
                style: .borderedSmall
            ) {}
            DSButton(
                "Bordered Small Fit",
                style: .borderedSmallFit
            ) {}
            DSButton(
                "Bordered Medium",
                style: .bordered
            ) {}
            DSButton(
                "Bordered Medium Fit",
                style: .borderedFit
            ) {}
            DSButton(
                "Bordered Large",
                style: .borderedLarge
            ) {}
                .disabled(true)
            DSButton(
                "Bordered Large Fit",
                style: .borderedLargeFit
            ) {}
            DSButton(
                "Bordered Destructive",
                style: .borderedDestructiveLarge,
                loading: true
            ) {}
            DSButton(
                "Bordered Destructive Fit",
                style: .borderedDestructiveFit
            ) {}

            // Icon Buttons
            HStack(spacing: DSSpacing.xLarge) {
                DSButton(
                    image: .appSystemIcon(.location),
                    style: .borderedCircularIcon
                ) {}
                DSButton(
                    image: .appSystemIcon(.location),
                    style: .filledCircularIcon
                ) {}
                DSButton(
                    image: .appSystemIcon(.location),
                    style: .filledIcon
                ) {}
                DSButton(
                    image: .appSystemIcon(.location),
                    style: .borderedIcon
                ) {}
                DSButton(
                    image: .appSystemIcon(.location),
                    style: .borderedDestructiveIcon
                ) {}
            }
        }
        .padding()
    }
}
