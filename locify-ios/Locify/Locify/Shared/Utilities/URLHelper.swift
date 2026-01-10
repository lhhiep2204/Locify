//
//  URLHelper.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 10/1/26.
//

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum URLHelper {
    /// Opens a URL string in the default browser or app
    static func open(_ urlString: String) {
        guard let url = Foundation.URL(string: urlString) else { return }

#if canImport(UIKit)
        UIApplication.shared.open(url)
#elseif canImport(AppKit)
        NSWorkspace.shared.open(url)
#endif
    }

    /// Checks if a URL can be opened
    static func canOpen(_ urlString: String) -> Bool {
        guard let url = Foundation.URL(string: urlString) else { return false }

#if canImport(UIKit)
        return UIApplication.shared.canOpenURL(url)
#else
        return true
#endif
    }

    /// Opens app settings
    static func openAppSettings() {
#if canImport(UIKit)
        if let url = Foundation.URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
#endif
    }
}
