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
    // MARK: - Core Services
    private let appleMapService: AppleMapServiceProtocol
    private let locationManager: LocationManagerProtocol
    private let swiftDataContainer = SwiftDataContainer()

    // MARK: - Feature Containers
    private lazy var collectionContainer = CollectionContainer(
        swiftDataContainer: swiftDataContainer
    )
    private lazy var locationContainer = LocationContainer(
        appleMapService: appleMapService,
        locationManager: locationManager,
        swiftDataContainer: swiftDataContainer
    )

    init(
        appleMapService: AppleMapServiceProtocol = AppleMapService(),
        locationManager: LocationManagerProtocol = LocationManager()
    ) {
        self.appleMapService = appleMapService
        self.locationManager = locationManager
    }
}

// MARK: - ViewModel Builders
extension AppContainer {
    func makeHomeViewModel() -> HomeViewModel {
        locationContainer.makeHomeViewModel(fetchCollectionsUseCase: collectionContainer.fetchUseCase)
    }

    func makeCollectionListViewModel() -> CollectionListViewModel {
        collectionContainer.makeCollectionListViewModel(locationContainer: locationContainer)
    }

    func makeLocationListViewModel(collection: Collection) -> LocationListViewModel {
        locationContainer.makeLocationListViewModel(collection: collection)
    }

    func makeEditCollectionViewModel() -> EditCollectionViewModel {
        collectionContainer.makeEditCollectionViewModel()
    }

    func makeEditLocationViewModel() -> EditLocationViewModel {
        locationContainer.makeEditLocationViewModel(collectionContainer: collectionContainer)
    }

    func makeSearchViewModel() -> SearchViewModel {
        locationContainer.makeSearchViewModel()
    }
}
