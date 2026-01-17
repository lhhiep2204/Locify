//
//  EnvironmentValues.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import SwiftUI

/// An `EnvironmentKey` for injecting the `AppContainer` singleton into the SwiftUI environment.
struct AppContainerKey: EnvironmentKey {
    static let defaultValue: AppContainer = .shared
}

/// An `EnvironmentKey` for injecting a dismiss callback for sheets into the SwiftUI environment.
struct DismissSheetKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

/// An `EnvironmentKey` for injecting a callback that handles location selection events.
struct SelectLocationKey: EnvironmentKey {
    static let defaultValue: (Collection, UUID, [Location]) -> Void = { _, _, _ in }
}

extension EnvironmentValues {
    /// A property to access or set the `AppContainer` instance in the SwiftUI environment.
    var appContainer: AppContainer {
        get { self[AppContainerKey.self] }
        set { self[AppContainerKey.self] = newValue }
    }

    /// A closure that, when called, dismisses the current sheet presented in the environment.
    var dismissSheet: () -> Void {
        get { self[DismissSheetKey.self] }
        set { self[DismissSheetKey.self] = newValue }
    }

    /// A closure called when a user selects a location item within a specific collection.
    /// - Parameters:
    ///   - collection: The `Collection` in which the selection occurred.
    ///   - selectedId: The UUID of the selected location.
    ///   - locations: The full list of locations, used to provide context or show related locations.
    var selectLocation: (Collection, UUID, [Location]) -> Void {
        get { self[SelectLocationKey.self] }
        set { self[SelectLocationKey.self] = newValue }
    }
}
