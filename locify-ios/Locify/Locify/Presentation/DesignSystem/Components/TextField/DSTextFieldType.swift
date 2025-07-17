//
//  DSTextFieldType.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 17/7/25.
//

import SwiftUI

// MARK: - DSTextFieldState Enum
/// Represents the state of the `DSTextField`, affecting its appearance.
enum DSTextFieldState {
    /// Default state with neutral styling.
    case normal

    /// Success state with a green color theme.
    case success

    /// Error state with a red color theme.
    case error

    /// Returns the border color corresponding to the text field's state.
    var borderColor: Color {
        switch self {
        case .normal: .appColor(.gray40)
        case .success: .green
        case .error: .red
        }
    }

    /// Returns the text color corresponding to the text field's state.
    var textColor: Color {
        switch self {
        case .normal: .appColor(.gray60)
        case .success: .green
        case .error: .red
        }
    }
}

// MARK: - TextField Style
struct DSTextFieldStyle: TextFieldStyle {
    // swiftlint:disable identifier_name
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.appFont(.regular(.custom(14))))
    }
    // swiftlint:enable identifier_name
}
