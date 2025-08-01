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
/// - Each `ViewModel` receives only the required `UseCases` or `UseCase` containers
/// - Each `UseCase` is injected with its corresponding `Repository`
/// - `Repositories` currently use mock data but are designed to handle local and remote data sources
/// - Use case containers group related operations by domain
final class ViewModelFactory {
    /// Shared singleton instance.
    static let shared = ViewModelFactory()

    // MARK: - Repositories
    private lazy var categoryRepository = CategoryRepository()
    private lazy var locationRepository = LocationRepository()

    // MARK: - Individual UseCases
    private lazy var fetchCategoriesUseCase = FetchCategoriesUseCase(repository: categoryRepository)
    private lazy var fetchLocationsUseCase = FetchLocationsUseCase(repository: locationRepository)

    // MARK: - Use Case Containers
    private lazy var categoryUseCases = CategoryUseCases(
        fetch: fetchCategoriesUseCase
    )

    private lazy var locationUseCases = LocationUseCases(
        fetch: fetchLocationsUseCase
    )

    /// Private initializer to enforce the singleton pattern.
    private init() {}
}

// MARK: - Factory Methods
extension ViewModelFactory {
    /// Creates a fully configured `HomeViewModel` for the Home screen.
    ///
    /// - Returns: A new `HomeViewModel` instance ready to be used in SwiftUI views.
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            fetchCategoriesUseCase: categoryUseCases.fetch,
            fetchLocationsUseCase: locationUseCases.fetch
        )
    }
}
