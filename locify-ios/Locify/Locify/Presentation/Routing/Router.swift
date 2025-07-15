//
//  Router.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/7/25.
//

import Combine
import SwiftUI

/// A protocol that represents a route in the navigation stack.
///
/// Any conforming type must be both a `View` and `Hashable` to support
/// SwiftUI navigation and identity tracking.
typealias RouterHandler = View & Hashable
protocol AppRoute: RouterHandler {}

/// A navigation manager for SwiftUI views, handling a stack-based navigation model.
///
/// `Router` maintains the current path stack and root view, and provides methods
/// for navigation actions such as push, pop, and resetting the stack.
@Observable @MainActor
final class Router<Route: AppRoute> {
    /// The stack of navigation paths, excluding the root.
    var paths: [Route]

    /// The root view of the navigation hierarchy.
    var root: Route

    /// Initializes the router with an optional path stack and a required root view.
    ///
    /// - Parameters:
    ///   - paths: The initial navigation stack. Defaults to an empty stack.
    ///   - root: The root view of the navigation hierarchy.
    init(
        paths: [Route] = [],
        root: Route
    ) {
        self.paths = paths
        self.root = root
    }
}

extension Router {
    /// Pushes a new view onto the navigation stack.
    ///
    /// - Parameter route: The route to push onto the stack.
    func push(_ route: Route) {
        paths.append(route)
    }

    /// Pops the top view from the navigation stack, if the stack is not empty.
    func pop() {
        guard !paths.isEmpty else { return }
        paths.removeLast()
    }

    /// Pops all views, leaving only the root view in the navigation hierarchy.
    func popToRoot() {
        paths.removeAll()
    }

    /// Pops views until the specified route is the top of the stack.
    ///
    /// - Parameter route: The route to pop to. If not found, logs an error.
    func popTo(_ route: Route) {
        guard let index = paths.firstIndex(of: route) else {
            Logger.error("Error: Specified route not found in the navigation stack.")
            return
        }
        paths = Array(paths.prefix(upTo: index + 1))
    }

    /// Replaces the root view and clears all pushed routes.
    ///
    /// - Parameter route: The new root route.
    func updateRoot(_ route: Route) {
        root = route
        popToRoot()
    }
}
