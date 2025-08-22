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

    @Environment(\.viewModelFactory) private var factory

    var body: some View {
        switch route {
        case .home:
            HomeView(factory.makeHomeViewModel())
        case .categoryList:
            CategoryListView(factory.makeCategoryListViewModel())
        case .locationList(let category):
            LocationListView(factory.makeLocationListViewModel(category: category))
        }
    }
}
