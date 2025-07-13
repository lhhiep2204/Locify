//
//  DeviceInfoProvider.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/7/25.
//

import UIKit

/// Provides information about the current device and system environment.
enum DeviceInfoProvider {
    /// The operating system name (e.g., "iOS", "visionOS", "watchOS").
    static var systemName: String {
        UIDevice.current.systemName
    }

    /// The OS version string (e.g., "18.0", "1.0").
    static var osVersion: String {
        UIDevice.current.systemVersion
    }

    /// Whether the app is running in a simulator.
    static var isSimulator: Bool {
#if targetEnvironment(simulator)
        true
#else
        false
#endif
    }

    /// The generic device model (e.g., "iPhone", "iPad", "Apple Watch").
    static var deviceModel: String {
        UIDevice.current.model
    }

    /// The user-defined device name (e.g., "User’s iPhone").
    static var deviceName: String {
        UIDevice.current.name
    }

    /// The low-level model identifier (e.g., "iPhone16,1", "AppleVision1,1").
    static var modelIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingCString: $0) ?? "unknown"
            }
        }
    }

    /// The current locale identifier (e.g., "en_US").
    static var localeIdentifier: String {
        Locale.current.identifier
    }

    /// The current language identifier (e.g., "ja-JP", "en-US", "vi-VN").
    static var languageIdentifier: String {
        let language = Locale.current.language.languageCode?.identifier ?? "und"
        let region = Locale.current.region?.identifier ?? "ZZ"
        return "\(language)-\(region)"
    }

    /// The current time zone identifier (e.g., "Asia/Ho_Chi_Minh").
    static var timeZoneIdentifier: String {
        TimeZone.current.identifier
    }

    /// A multi-line summary of device and system info, useful for logs and reports.
    static var summary: String {
        """
        Device: \(deviceModel) (\(deviceName))
        Model ID: \(modelIdentifier)
        OS: \(systemName) \(osVersion)
        Language: \(languageIdentifier)
        Locale: \(localeIdentifier)
        Timezone: \(timeZoneIdentifier)
        Simulator: \(isSimulator ? "Yes" : "No")
        """
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
