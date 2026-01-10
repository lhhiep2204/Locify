//
//  AppInfoProvider.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/7/25.
//

import Foundation

/// Provides information about the app from Info.plist.
enum AppInfoHelper {
    /// The display name of the app.
    static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ??
        "UnknownApp"
    }

    /// The bundle identifier (e.g., "com.example.myapp").
    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "UnknownBundle"
    }

    /// The marketing version (e.g., "1.0").
    static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0"
    }

    /// The internal build number (e.g., "42").
    static var buildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
    }

    /// Combined version string (e.g., "1.0 (42)").
    static var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}
