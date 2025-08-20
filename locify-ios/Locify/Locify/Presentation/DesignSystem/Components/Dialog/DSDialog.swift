//
//  DSDialog.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/8/25.
//

import SwiftUI

/// A design system dialog component.
struct DSDialog: View {
    /// A binding to the dialog's presentation state.
    /// Toggling this value controls whether the dialog is visible.
    @Binding private var isPresented: Bool

    /// The optional title text displayed at the top of the dialog.
    private let title: String?

    /// The optional subtitle text displayed below the title.
    private let subtitle: String?

    /// An optional image to display above the buttons.
    private let image: Image?

    /// The type of buttons to display in the dialog, determining layout and styles.
    private let buttonType: DSDialogButtonType

    /// Creates a new `DSDialog` instance.
    ///
    /// - Parameters:
    ///   - isPresented: A binding to the Boolean value that determines whether the dialog is shown.
    ///   - title: An optional string for the dialog's title.
    ///   - subtitle: An optional string for the dialog's subtitle.
    ///   - image: An optional `Image` to display within the dialog.
    ///   - buttonType: The button configuration and style for the dialog.
    ///
    /// The dialog uses `isPresented` binding to manage its visibility, toggling it automatically
    /// when any buttons are tapped.
    init(
        _ isPresented: Binding<Bool>,
        title: String?,
        subtitle: String?,
        image: Image?,
        buttonType: DSDialogButtonType
    ) {
        _isPresented = isPresented
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.buttonType = buttonType
    }

    var body: some View {
        VStack(spacing: DSSpacing.small) {
            titleView
            subtitleView
            imageView
            buttonsView
                .padding(.top)
        }
        .frame(maxWidth: 300)
        .padding(DSSpacing.xLarge)
        .background(.backgroundPrimary)
        .cornerRadius(DSRadius.xLarge)
        .shadow(radius: DSRadius.xLarge, y: 3)
    }

    @ViewBuilder
    private var titleView: some View {
        if let title = title {
            DSText(title, font: .bold(.large))
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let subtitle = subtitle {
            DSText(subtitle, font: .medium(.medium))
        }
    }

    @ViewBuilder
    private var imageView: some View {
        if let image = image {
            image
                .resizable()
                .scaledToFit()
                .frame(height: 80)
                .padding(.vertical)
        }
    }

    /// A view that displays the action buttons for the dialog.
    ///
    /// The buttons layout and styles depend on the `buttonType`:
    /// - `.alert`: a single filled large button.
    /// - `.confirmation`: two buttons side-by-side, left is bordered destructive, right is filled.
    /// - `.option`: two buttons side-by-side, left is filled, right is bordered.
    ///
    /// Each button toggles the `isPresented` binding to dismiss the dialog upon tap,
    /// then performs its associated action.
    @ViewBuilder
    private var buttonsView: some View {
        switch buttonType {
        case .alert(let button):
            DSButton(button.title, style: .filledLarge) {
                withAnimation {
                    isPresented.toggle()
                }
                button.action()
            }
        case .confirmation(let leftButton, let rightButton):
            HStack {
                DSButton(leftButton.title, style: .borderedDestructiveLarge) {
                    withAnimation {
                        isPresented.toggle()
                    }
                    leftButton.action()
                }
                DSButton(rightButton.title, style: .filledLarge) {
                    withAnimation {
                        isPresented.toggle()
                    }
                    rightButton.action()
                }
            }
        case .option(let leftButton, let rightButton):
            HStack {
                DSButton(leftButton.title, style: .filledLarge) {
                    withAnimation {
                        isPresented.toggle()
                    }
                    leftButton.action()
                }
                DSButton(rightButton.title, style: .borderedLarge) {
                    withAnimation {
                        isPresented.toggle()
                    }
                    rightButton.action()
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: DSSpacing.large) {
            DSDialog(
                .constant(true),
                title: "Dialog",
                subtitle: "Dialog text goes here",
                image: .appSystemIcon(.delete),
                buttonType: .alert(
                    .init(
                        title: "Call to action",
                        action: {}
                    )
                )
            )
            DSDialog(
                .constant(true),
                title: "Dialog",
                subtitle: "Dialog text goes here",
                image: .appSystemIcon(.delete),
                buttonType: .confirmation(
                    .init(
                        title: "Cancel",
                        action: {}
                    ),
                    .init(
                        title: "Call to action",
                        action: {}
                    )
                )
            )
            DSDialog(
                .constant(true),
                title: "Dialog",
                subtitle: "Dialog text goes here",
                image: .appSystemIcon(.delete),
                buttonType: .option(
                    .init(
                        title: "Call to action",
                        action: {}
                    ),
                    .init(
                        title: "Call to action",
                        action: {}
                    )
                )
            )
        }
    }
}
