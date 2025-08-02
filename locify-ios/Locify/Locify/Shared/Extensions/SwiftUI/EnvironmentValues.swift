//
//  EnvironmentValues.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import SwiftUI

typealias Callback = () -> Void

/// An `EnvironmentKey` for injecting the `ViewModelFactory` singleton into the SwiftUI environment.
struct ViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: ViewModelFactory = .shared
}

/// An `EnvironmentKey` for injecting a dismiss callback for sheets into the SwiftUI environment.
struct DismissSheetKey: EnvironmentKey {
    static let defaultValue: Callback = {}
}

extension EnvironmentValues {
    /// A property to access or set the `ViewModelFactory` instance in the SwiftUI environment.
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }

    /// A closure that, when called, dismisses the current sheet presented in the environment.
    var dismissSheet: Callback {
        get { self[DismissSheetKey.self] }
        set { self[DismissSheetKey.self] = newValue }
    }
}
