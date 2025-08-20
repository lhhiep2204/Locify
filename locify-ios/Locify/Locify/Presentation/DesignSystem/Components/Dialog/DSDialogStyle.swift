//
//  DSDialogStyle.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

/// Represents a button used in the design system dialog, encapsulating its title and action.
/// Use this to configure buttons within dialogs for alerts, confirmations, or options.
/// - Parameters:
///   - title: The text displayed on the button.
///   - action: The closure executed when the button is tapped.
struct DSDialogButton {
    let title: String
    let action: () -> Void

    /// Creates a new dialog button with a title and action.
    /// - Parameters:
    ///   - title: The button's display text.
    ///   - action: The closure to run when tapped.
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

/// Defines the type of dialog buttons presented in the design system dialog.
/// Use this enum to specify whether the dialog shows a single alert button,
/// a confirmation with two buttons, or an option selection with two buttons.
enum DSDialogButtonType {
    /// Single alert button dialog.
    case alert(DSDialogButton)
    /// Confirmation dialog with left and right buttons.
    case confirmation(DSDialogButton, DSDialogButton)
    /// Option dialog with left and right buttons.
    case option(DSDialogButton, DSDialogButton)
}

/// A view modifier that presents a design system dialog overlay.
/// This modifier manages the dialog's visibility and content including title, subtitle, image, and buttons.
/// Apply this modifier to any view to present a modal dialog consistent with the design system.
/// - Parameters:
///   - isPresented: Binding controlling the dialog's presentation state.
///   - title: Optional title text displayed at the top of the dialog.
///   - subtitle: Optional subtitle or message text below the title.
///   - image: Optional image displayed in the dialog.
///   - buttonType: Specifies the button configuration for the dialog.
struct DSDialogModifier: ViewModifier {
    @Binding var isPresented: Bool

    let title: String?
    let subtitle: String?
    let image: Image?
    let buttonType: DSDialogButtonType

    /// Constructs the view hierarchy with an overlay dialog when `isPresented` is true.
    /// The dialog dims the background content and presents the dialog view on top.
    /// - Parameter content: The base view to overlay the dialog on.
    /// - Returns: A view that conditionally overlays the dialog.
    func body(content: Content) -> some View {
        ZStack {
            content
            ZStack {
                Rectangle()
                    .foregroundColor(.gray.opacity(0.2))
                    .ignoresSafeArea()
                DSDialog($isPresented,
                         title: title,
                         subtitle: subtitle,
                         image: image,
                         buttonType: buttonType)
            }
            .opacity(isPresented ? 1 : 0)
        }
    }
}

extension View {
    /// Presents a simple alert-style dialog with a single button.
    /// - Parameters:
    ///   - isPresented: Binding that controls whether the dialog is shown.
    ///   - title: Optional title displayed in the dialog.
    ///   - subtitle: Optional subtitle or message.
    ///   - image: Optional image shown in the dialog.
    ///   - button: The button configuration for the alert dialog.
    /// - Returns: A view that presents the alert dialog when `isPresented` is true.
    func dialog(_ isPresented: Binding<Bool>,
                title: String? = nil,
                subtitle: String? = nil,
                image: Image? = nil,
                button: DSDialogButton) -> some View {
        modifier(DSDialogModifier(isPresented: isPresented,
                                  title: title,
                                  subtitle: subtitle,
                                  image: image,
                                  buttonType: .alert(button)))
    }

    /// Presents a confirmation dialog with two buttons (left and right).
    /// - Parameters:
    ///   - isPresented: Binding that controls whether the dialog is shown.
    ///   - title: Optional dialog title.
    ///   - subtitle: Optional subtitle or message.
    ///   - image: Optional image displayed in the dialog.
    ///   - leftButton: The button shown on the left side.
    ///   - rightButton: The button shown on the right side.
    /// - Returns: A view that presents the confirmation dialog when `isPresented` is true.
    func confirmationDialog(_ isPresented: Binding<Bool>,
                            title: String? = nil,
                            subtitle: String? = nil,
                            image: Image? = nil,
                            leftButton: DSDialogButton,
                            rightButton: DSDialogButton) -> some View {
        modifier(DSDialogModifier(isPresented: isPresented,
                                  title: title,
                                  subtitle: subtitle,
                                  image: image,
                                  buttonType: .confirmation(leftButton, rightButton)))
    }

    /// Presents an option dialog with two buttons, typically to choose between alternatives.
    /// - Parameters:
    ///   - isPresented: Binding controlling dialog visibility.
    ///   - title: Optional title text.
    ///   - subtitle: Optional subtitle or message.
    ///   - image: Optional image displayed in the dialog.
    ///   - leftButton: The button on the left side.
    ///   - rightButton: The button on the right side.
    /// - Returns: A view that presents the option dialog when `isPresented` is true.
    func optionDialog(_ isPresented: Binding<Bool>,
                      title: String? = nil,
                      subtitle: String? = nil,
                      image: Image? = nil,
                      leftButton: DSDialogButton,
                      rightButton: DSDialogButton) -> some View {
        modifier(DSDialogModifier(isPresented: isPresented,
                                  title: title,
                                  subtitle: subtitle,
                                  image: image,
                                  buttonType: .option(leftButton, rightButton)))
    }
}
