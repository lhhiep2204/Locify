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
    case categoryList
    case locationList(category: Category)
    case search
}

/// Makes `Route` conform to `AppRoute` by implementing a `View` body for each case.
extension Route: @MainActor AppRoute {
    var body: some View {
        RouteContentView(route: self)
    }
}

/// Internal view responsible for resolving routes to their corresponding views with proper dependency injection.
private struct RouteContentView: View {
    let route: Route

    @Environment(\.appContainer) private var container

    var body: some View {
        switch route {
        case .home:
            HomeView(container.makeHomeViewModel())
        case .categoryList:
            CategoryListView(container.makeCategoryListViewModel())
        case .locationList(let category):
            LocationListView(container.makeLocationListViewModel(category: category))
        case .search:
            SearchView()
        }
    }
}
