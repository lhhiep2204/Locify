//
//  EnvironmentValues.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import SwiftUI

/// An `EnvironmentKey` for injecting the `ViewModelFactory` singleton into the SwiftUI environment.
struct ViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: ViewModelFactory = .shared
}

/// An `EnvironmentKey` for injecting a dismiss callback for sheets into the SwiftUI environment.
struct DismissSheetKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

/// An `EnvironmentKey` for injecting a callback that handles location selection events.
struct SelectLocationKey: EnvironmentKey {
    static let defaultValue: (UUID, [Location]) -> Void = { _, _ in }
}

extension EnvironmentValues {
    /// A property to access or set the `ViewModelFactory` instance in the SwiftUI environment.
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }

    /// A closure that, when called, dismisses the current sheet presented in the environment.
    var dismissSheet: () -> Void {
        get { self[DismissSheetKey.self] }
        set { self[DismissSheetKey.self] = newValue }
    }

    /// A closure called when a user selects a location item.
    /// - Parameters:
    ///   - selectedId: The UUID of the selected location.
    ///   - locations: The full list of locations, used to provide context or show related locations.
    var selectLocation: (UUID, [Location]) -> Void {
        get { self[SelectLocationKey.self] }
        set { self[SelectLocationKey.self] = newValue }
    }
}
