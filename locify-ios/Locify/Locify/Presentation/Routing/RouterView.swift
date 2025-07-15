//
//  RouterView.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/7/25.
//

import SwiftUI

/// A SwiftUI view that displays content using a `Router` for navigation management.
///
/// `RouterView` is designed to be used when you want a full-screen container view
/// that handles navigation via a shared `Router` instance.
struct RouterView<Route: AppRoute>: View {
    /// The router managing the navigation stack.
    @Bindable private var manager: Router<Route>

    /// Creates a `RouterView` that observes and manages navigation paths using the provided router.
    ///
    /// - Parameter manager: The router responsible for handling navigation paths.
    init(_ manager: Router<Route>) {
        self.manager = manager
    }

    var body: some View {
        NavigationStack(path: $manager.paths) {
            manager.root
                .navigationDestination(for: Route.self) { $0 }
        }
        .environment(manager)
    }
}

/// A view modifier that wraps the content in a `NavigationStack` managed by a `Router`.
///
/// Use this when you want to embed routing behavior inside an existing view hierarchy,
/// rather than using a dedicated `RouterView`.
struct RouterModifier<Route: AppRoute>: ViewModifier {
    /// The router managing the navigation stack.
    @Bindable private var manager: Router<Route>

    /// Creates a `RouterModifier` that manages navigation paths using the provided router.
    ///
    /// - Parameter manager: The router responsible for handling navigation paths.
    init(_ manager: Router<Route>) {
        self.manager = manager
    }

    func body(content: Content) -> some View {
        NavigationStack(path: $manager.paths) {
            content
                .navigationDestination(for: Route.self) { $0 }
        }
        .environment(manager)
    }
}

extension View {
    /// Applies the `RouterModifier` to the view, enabling navigation support using the given router.
    ///
    /// - Parameter manager: The router managing the navigation paths.
    /// - Returns: A view with navigation behavior powered by the provided router.
    func applyRouter<Route: AppRoute>(_ manager: Router<Route>) -> some View {
        modifier(RouterModifier(manager))
    }
}
