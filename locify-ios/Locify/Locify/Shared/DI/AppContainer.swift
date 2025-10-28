//
//  AppContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

/// The root dependency container (Composition Root).
///
/// `AppContainer` wires together the feature-level containers and shared services.
/// It follows Clean Architecture principles and acts as the single source of truth
/// for constructing ViewModels and use cases throughout the app.
final class AppContainer {
    /// Shared singleton instance.
    static let shared = AppContainer()

    // MARK: - Core Services
    private lazy var appleMapService: AppleMapServiceProtocol = AppleMapService.shared
    private lazy var locationManager: LocationManagerProtocol = LocationManager.shared

    // MARK: - Feature Containers
    private lazy var categoryContainer = CategoryContainer()
    private lazy var locationContainer = LocationContainer(
        appleMapService: appleMapService,
        locationManager: locationManager
    )

    /// Private initializer to enforce singleton usage.
    private init() {}
}

// MARK: - ViewModel Builders
extension AppContainer {
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getUserLocationUseCase: locationContainer.getUserLocationUseCase,
            locationManager: locationManager,
            appleMapService: appleMapService
        )
    }

    func makeCategoryListViewModel() -> CategoryListViewModel {
        categoryContainer.makeCategoryListViewModel()
    }

    func makeLocationListViewModel(category: Category) -> LocationListViewModel {
        locationContainer.makeLocationListViewModel(category: category)
    }

    func makeEditCategoryViewModel() -> EditCategoryViewModel {
        categoryContainer.makeEditCategoryViewModel()
    }

    func makeEditLocationViewModel() -> EditLocationViewModel {
        locationContainer.makeEditLocationViewModel(categoryContainer: categoryContainer)
    }
}
