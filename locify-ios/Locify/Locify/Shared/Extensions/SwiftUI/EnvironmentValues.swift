//
//  EnvironmentValues.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 30/7/25.
//

import SwiftUI

/// `EnvironmentKey` for injecting the `ViewModelFactory` singleton into the SwiftUI environment.
struct ViewModelFactoryKey: EnvironmentKey {
    static let defaultValue: ViewModelFactory = .shared
}

extension EnvironmentValues {
    /// A property to access or set the `ViewModelFactory` instance in the SwiftUI environment.
    var viewModelFactory: ViewModelFactory {
        get { self[ViewModelFactoryKey.self] }
        set { self[ViewModelFactoryKey.self] = newValue }
    }
}
