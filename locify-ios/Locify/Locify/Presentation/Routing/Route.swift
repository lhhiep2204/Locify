//
//  Route.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/7/25.
//

import SwiftUI

/// An enum representing all possible navigation routes in the app.
enum Route {
    case home
}

/// Makes `Route` conform to `AppRoute` by implementing a `View` body for each case.
extension Route: @MainActor AppRoute {
    var body: some View {
        switch self {
        case .home:
            HomeView(ViewModelFactory.shared.makeHomeViewModel())
        }
    }
}

extension NavigationLink where Destination == Never {
    /// Initializes a `NavigationLink` using a `Route` value as the destination.
    ///
    /// This simplifies creating links when using a navigation system driven by `Route`.
    ///
    /// - Parameters:
    ///   - value: The destination route.
    ///   - label: A closure returning the label view.
    init(_ value: Route, @ViewBuilder label: () -> Label) {
        self.init(value: value, label: label)
    }
}
