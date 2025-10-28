//
//  LocationContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import Foundation

/// Dependency container for Location-related logic.
///
/// Provides location repositories, use cases, and ViewModels.
/// It depends on shared AppleMapService and LocationManager instances.
final class LocationContainer {
    // MARK: - Core Services
    private let appleMapService: AppleMapServiceProtocol
    private let locationManager: LocationManagerProtocol

    // MARK: - Repository
    private let repository: LocationRepositoryProtocol

    // MARK: - Use Cases
    private lazy var fetchUseCase = FetchLocationsUseCase(repository: repository)
    private lazy var addUseCase = AddLocationUseCase(repository: repository)
    private lazy var updateUseCase = UpdateLocationUseCase(repository: repository)
    private lazy var deleteUseCase = DeleteLocationUseCase(repository: repository)

    private(set) lazy var getUserLocationUseCase = GetUserLocationUseCase(
        appleMapService: appleMapService,
        locationManager: locationManager
    )

    private lazy var useCases = LocationUseCases(
        fetch: fetchUseCase,
        add: addUseCase,
        update: updateUseCase,
        delete: deleteUseCase
    )

    // MARK: - Initialization
    init(
        appleMapService: AppleMapServiceProtocol,
        locationManager: LocationManagerProtocol,
        repository: LocationRepositoryProtocol = LocationRepository()
    ) {
        self.appleMapService = appleMapService
        self.locationManager = locationManager
        self.repository = repository
    }
}

// MARK: - ViewModel Factories
extension LocationContainer {
    func makeLocationListViewModel(category: Category) -> LocationListViewModel {
        LocationListViewModel(category: category, locationUseCase: useCases)
    }

    func makeEditLocationViewModel(categoryContainer: CategoryContainer) -> EditLocationViewModel {
        EditLocationViewModel(
            fetchCategoriesUseCase: categoryContainer.fetchUseCase,
            addCategoryUseCase: categoryContainer.addUseCase
        )
    }
}
