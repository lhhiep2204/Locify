//
//  ViewModelFactory.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

/// A singleton responsible for creating and providing `ViewModel` instances with all their dependencies.
///
/// This factory follows Clean Architecture principles:
/// - Each `ViewModel` receives only the required `UseCases`
/// - Each `UseCase` is injected with its corresponding `Repository`
/// - `Repositories` handle both local and remote data sources
final class ViewModelFactory {
    /// Shared singleton instance.
    static let shared = ViewModelFactory()

    // MARK: - Repositories
    private let categoryRepository = CategoryRepository()
    private let locationRepository = LocationRepository()

    // MARK: - UseCases (lazily initialized)
    private lazy var fetchCategoriesUseCase = FetchCategoriesUseCase(repository: categoryRepository)
    private lazy var fetchLocationsUseCase = FetchLocationsUseCase(repository: locationRepository)

    /// Private initializer to enforce the singleton pattern.
    private init() {}
}

// MARK: - Factory Methods
extension ViewModelFactory {
    /// Creates a fully configured `HomeViewModel` for the Home screen.
    ///
    /// The view model will be injected with:
    /// - `FetchCategoriesUseCase` for loading category data
    /// - `FetchLocationsUseCase` for loading location data
    ///
    /// - Returns: A new `HomeViewModel` instance ready to be used in SwiftUI views.
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchCategoriesUseCase: fetchCategoriesUseCase,
            fetchLocationsUseCase: fetchLocationsUseCase
        )
    }
}
