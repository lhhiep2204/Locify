//
//  Route.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/7/25.
//

import SwiftUI

typealias SearchCompleter = (Location) -> Void

/// An enum representing all possible navigation routes in the app.
enum Route {
    case home
    case categoryList
    case locationList(category: Category)
    case search(SearchCompleter)
}

extension Route: Equatable, Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .home:
            hasher.combine("home")
        case .categoryList:
            hasher.combine("categoryList")
        case .locationList(let category):
            hasher.combine("locationList")
            hasher.combine(category.id)
        case .search:
            hasher.combine("search")
        }
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
            (.categoryList, .categoryList),
            (.search, .search):
            true
        case (.locationList(let categoryA), .locationList(let categoryB)):
            categoryA == categoryB
        default:
            false
        }
    }
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
        case .search(let searchCompletion):
            SearchView { searchCompletion($0) }
        }
    }
}
