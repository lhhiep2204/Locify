//
//  DSTextField.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 17/7/25.
//

import SwiftUI

/// An observable class that manages the state and behavior of `DSTextField`.
@Observable
final class DSTextFieldObservable {
    /// The axis of the text field, determining whether it supports multiline input.
    var axis: Axis = .horizontal

    /// A Boolean value that indicates whether the text field is enabled.
    var enabled: Bool = true

    /// An optional image displayed inside the text field, typically used as an icon.
    var image: Image?

    /// An optional image displayed at the trailing end inside the text field.
    var trailingImage: Image?

    /// The label text displayed above the text field.
    var label: String = ""

    /// The description text displayed below the text field.
    var description: String = ""

    /// The maximum length of input allowed in the text field. A value of `0` means no limit.
    var maxLength: Int = 0
}

/// A customizable text field component with styling and behavior options.
struct DSTextField: View {
    @Environment(\.colorScheme) var colorScheme

    private var object = DSTextFieldObservable()

    @Binding private var placeholder: String
    @Binding private var text: String
    @FocusState private var editing
    @State private var showPassword: Bool = false

    private let isSecure: Bool
    private let state: DSTextFieldState
    private let translucent: Bool

    /// Initializes a `DSTextField` with a placeholder and text binding.
    /// - Parameters:
    ///   - placeholder: A binding to the placeholder text.
    ///   - text: A binding to the user-inputted text.
    ///   - isSecure: A Boolean indicating if the text field is for secure input (e.g., passwords).
    ///   - state: The state of the text field, affecting its appearance.
    ///   - translucent: Whether the background is translucent (opacity = 0.6).
    init(
        _ placeholder: Binding<String>,
        text: Binding<String>,
        isSecure: Bool = false,
        state: DSTextFieldState = .normal,
        translucent: Bool = true
    ) {
        _placeholder = placeholder
        _text = text
        self.isSecure = isSecure
        self.state = state
        self.translucent = translucent
    }

    /// Initializes a `DSTextField` without a placeholder.
    /// - Parameters:
    ///   - text: A binding to the user-inputted text.
    ///   - isSecure: A Boolean indicating if the text field is for secure input.
    ///   - state: The state of the text field.
    ///   - translucent: Whether the background is translucent (opacity = 0.6).
    init(
        text: Binding<String>,
        isSecure: Bool = false,
        state: DSTextFieldState = .normal,
        translucent: Bool = true
    ) {
        _placeholder = .constant("")
        _text = text
        self.isSecure = isSecure
        self.state = state
        self.translucent = translucent
    }

    /// Computes the border color based on the state of the text field.
    private var borderColor: Color {
        if !object.enabled {
            return .appColor(.gray20)
        }

        return editing ? .appColor(.accent) : state.borderColor
    }

    /// Computes the border width based on the enabled state.
    private var borderWidth: CGFloat {
        object.enabled ? DSStroke.thin : 0
    }

    /// Computes the background color when the text field is disabled.
    private var disabledBackground: Color {
        .appColor(colorScheme == .light ? .gray20 : .gray80).opacity(0.5)
    }

    var body: some View {
        VStack(
            alignment: .leading,
            spacing: DSSpacing.xSmall
        ) {
            if !object.label.isEmpty {
                DSText(
                    object.label,
                    font: .medium(.small)
                )
            }

            inputView

            if !object.description.isEmpty {
                DSText(
                    object.description,
                    font: .medium(.small),
                    color: state.textColor
                )
            }
        }
        .if(object.maxLength > 0) {
            $0.onChange(of: text) {
                text = String($1.prefix(object.maxLength))
            }
        }
        .onTapGesture {
            editing = true
        }
    }
}

// MARK: - Private Methods
extension DSTextField {
    private var inputView: some View {
        HStack(spacing: DSSpacing.small) {
            object.image

            textFieldView

            if object.axis == .horizontal && editing && !text.isEmpty {
                clearButtonView
            }

            if isSecure {
                showPasswordButtonView
            }

            object.trailingImage
        }
        .padding(.horizontal, DSSpacing.medium)
        .if(translucent) {
            $0.background(Color.appColor(.backgroundSecondary).opacity(0.6))
        } else: {
            $0.background(Color.appColor(.backgroundSecondary))
        }
        .glassEffect(
            .clear.interactive(),
            in: RoundedRectangle(cornerRadius: DSRadius.xxLarge)
        )
        .cornerRadius(DSRadius.xxLarge)
        .overlay {
            RoundedRectangle(cornerRadius: DSRadius.xxLarge)
                .stroke(borderColor, lineWidth: borderWidth)
                .if(!object.enabled) {
                    $0.background(disabledBackground)
                        .cornerRadius(DSRadius.xxLarge)
                }
        }
    }

    private var textFieldView: some View {
        Group {
            if isSecure && !showPassword {
                SecureField(
                    placeholder,
                    text: $text
                )
            } else {
                TextField(
                    placeholder,
                    text: $text,
                    axis: object.axis
                )
            }
        }
        .textFieldStyle(
            DSTextFieldStyle()
        )
        .if(object.axis == .horizontal) {
            $0.frame(height: DSSize.huge)
        } else: {
            $0.padding(.vertical, DSSpacing.medium)
        }
        .focused($editing)
        .disabled(!object.enabled)
    }

    private var clearButtonView: some View {
        Button(action: {
            text = ""
        }, label: {
            Image
                .appSystemIcon(.clearText)
                .foregroundStyle(.textSecondary)
        })
    }

    private var showPasswordButtonView: some View {
        Button(action: {
            showPassword.toggle()
        }, label: {
            Image
                .appSystemIcon(showPassword ? .passwordShown : .passwordHidden)
                .foregroundStyle(.textSecondary)
                .font(.appFont(.regular(.medium)))
        })
    }
}

// MARK: - Methods
extension DSTextField {
    /// Sets the enabled state of the text field.
    /// - Parameter enabled: A Boolean value indicating whether the text field is enabled.
    /// - Returns: The updated DSTextField.
    func enabled(_ enabled: Bool) -> Self {
        object.enabled = enabled
        return self
    }

    /// Sets the image to be displayed in the text field.
    /// - Parameter image: The image to be displayed.
    /// - Returns: The updated DSTextField.
    func image(_ image: Image) -> Self {
        object.image = image
        return self
    }

    /// Sets the trailing image to be displayed at the end inside the text field.
    /// - Parameter image: The trailing image.
    /// - Returns: The updated DSTextField.
    func trailingImage(_ image: Image) -> Self {
        object.trailingImage = image
        return self
    }

    /// Sets the label text to be displayed above the text field.
    /// - Parameter label: The label text.
    /// - Returns: The updated DSTextField.
    func label(_ label: String) -> Self {
        object.label = label
        return self
    }

    /// Sets the description text to be displayed below the text field.
    /// - Parameter description: The description text.
    /// - Returns: The updated DSTextField.
    func description(_ description: String) -> Self {
        object.description = description
        return self
    }

    /// Sets the maximum length of text that can be entered in the text field.
    /// - Parameter maxLength: The maximum number of characters.
    /// - Returns: The updated DSTextField.
    func maxLength(_ maxLength: Int) -> Self {
        object.maxLength = maxLength
        return self
    }

    /// Configures the text field to support multiline input.
    /// - Parameter multiline: A Boolean value indicating whether multiline input is enabled.
    /// - Returns: The updated DSTextField.
    func multiline(_ multiline: Bool = true) -> Self {
        object.axis = multiline ? .vertical : .horizontal
        return self
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DSSpacing.large) {
            // 1. Standard with placeholder and label
            DSTextField(
                .constant("Username"),
                text: .constant("")
            )
            .label("Username")
#if os(iOS)
            .keyboardType(.emailAddress)
#endif

            // 2. Secure field (password)
            DSTextField(
                .constant("Password"),
                text: .constant(""),
                isSecure: true
            )
            .label("Password")
#if os(iOS)
            .keyboardType(.numberPad)
#endif

            // 3. With icon
            DSTextField(
                .constant("Text placeholder"),
                text: .constant("")
            )
            .image(.appSystemIcon(.location))

            // 4. Disabled
            DSTextField(
                text: .constant("Disabled")
            )
            .image(.appSystemIcon(.location))
            .enabled(false)

            // 5. Success state
            DSTextField(
                text: .constant("Success"),
                state: .success
            )
            .description("Description success text")

            // 6. Error state
            DSTextField(
                text: .constant("Error"),
                state: .error
            )
            .description("Description error text")

            // 7. Multiline
            DSTextField(
                text: .constant("Multiline\nLine 2\nLine 3"),
                state: .normal
            )
            .description("Description text")
            .multiline()

            // 8. Max Length (set to 3)
            DSTextField(
                .constant("Limited"),
                text: .constant("12345")
            )
            .label("Max Length 3")
            .maxLength(3)

            // 9. Non-translucent field
            DSTextField(
                .constant("Opaque"),
                text: .constant("Text"),
                translucent: false
            )
            .label("Opaque Background")

            // 10. With trailing image
            DSTextField(
                .constant("Trailing Image"),
                text: .constant("")
            )
            .label("Trailing Image Example")
            .trailingImage(.appSystemIcon(.location))
        }
        .padding()
    }
}
