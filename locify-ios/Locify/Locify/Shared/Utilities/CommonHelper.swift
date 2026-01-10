//
//  CommonHelper.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 10/1/26.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Clipboard
enum CommonHelper {
    enum Clipboard {
        /// Copies text to the system clipboard
        static func copy(_ text: String) {
#if canImport(UIKit)
            UIPasteboard.general.string = text
#elseif canImport(AppKit)
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(text, forType: .string)
#endif
        }

        /// Retrieves text from the system clipboard
        static func paste() -> String? {
#if canImport(UIKit)
            return UIPasteboard.general.string
#elseif canImport(AppKit)
            return NSPasteboard.general.string(forType: .string)
#endif
        }

        /// Checks if clipboard contains text
        static var hasText: Bool {
#if canImport(UIKit)
            return UIPasteboard.general.hasStrings
#elseif canImport(AppKit)
            return NSPasteboard.general.string(forType: .string) != nil
#endif
        }
    }
}
