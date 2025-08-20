//
//  DSText.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 16/7/25.
//

import SwiftUI

/// A customizable text component that supports dynamic styling.
struct DSText: View {
    /// The text content to be displayed.
    private let title: String

    /// The font style used for displaying text.
    private let font: DSFont

    /// The text color.
    private let color: Color

    /// Creates a `DSText` instance with the specified content and styling.
    ///
    /// - Parameters:
    ///   - title: The text content to be displayed.
    ///   - font: The font style. Defaults to `.regular(.medium)`.
    ///   - color: The text color. Defaults to `.appColor(.textPrimary)`.
    init(
        _ title: String,
        font: DSFont = .regular(.medium),
        color: Color = .appColor(.textPrimary)
    ) {
        self.title = title
        self.font = font
        self.color = color
    }

    var body: some View {
        Text(title)
            .font(.appFont(font))
            .foregroundStyle(color)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DSSpacing.large) {
            // Regular Font Weight
            DSText(
                "Regular - Small",
                font: .regular(.small),
                color: .appColor(.textPrimary)
            )

            DSText(
                "Regular - Medium",
                font: .regular(.medium),
                color: .appColor(.textSecondary)
            )

            DSText(
                "Regular - Large",
                font: .regular(.large),
                color: .appColor(.accent)
            )

            DSText(
                "Regular - Custom (18pt) with long content that spans multiple lines",
                font: .regular(.custom(18)),
                color: .red
            )
            .multilineTextAlignment(.center)

            // Medium Font Weight
            DSText(
                "Medium - Small",
                font: .medium(.small),
                color: .appColor(.textPrimary)
            )

            DSText(
                "Medium - Medium",
                font: .medium(.medium),
                color: .appColor(.textSecondary)
            )

            DSText(
                "Medium - Large",
                font: .medium(.large),
                color: .appColor(.accent)
            )

            DSText(
                "Medium - Custom (22pt) with long content that is truncated",
                font: .medium(.custom(22)),
                color: .red
            )
            .lineLimit(1)

            // Bold Font Weight
            DSText(
                "Bold - Small",
                font: .bold(.small),
                color: .appColor(.textPrimary)
            )

            DSText(
                "Bold - Medium",
                font: .bold(.medium),
                color: .appColor(.textSecondary)
            )

            DSText(
                "Bold - Large",
                font: .bold(.large),
                color: .appColor(.accent)
            )

            DSText(
                "Bold - Custom (24pt) with very long content that wraps across multiple lines",
                font: .bold(.custom(24)),
                color: .red
            )
            .multilineTextAlignment(.leading)
        }
        .padding()
    }
}
