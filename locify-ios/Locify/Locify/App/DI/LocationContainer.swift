//
//  LocationContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import Foundation

final class LocationContainer {
    // MARK: - Core Services
    private let appleMapService: AppleMapServiceProtocol
    private let locationManager: LocationManagerProtocol

    // MARK: - Data Source
    private let localDataSource: LocationLocalDataSourceProtocol

    // MARK: - Mapper
    private let locationMapper: LocationMapping

    // MARK: - Repository
    private let repository: LocationRepositoryProtocol

    // MARK: - Use Cases
    private lazy var fetchUseCase = FetchLocationsUseCase(repository: repository)
    private lazy var fetchCountUseCase = FetchLocationCountUseCase(repository: repository)
    private lazy var addUseCase = AddLocationUseCase(repository: repository)
    private lazy var updateUseCase = UpdateLocationUseCase(repository: repository)
    private lazy var deleteUseCase = DeleteLocationUseCase(repository: repository)
    private lazy var fetchRouteDistanceUseCase = FetchRouteDistanceUseCase(mapService: appleMapService)

    private(set) lazy var getUserLocationUseCase = GetUserLocationUseCase(
        appleMapService: appleMapService,
        locationManager: locationManager
    )

    private lazy var useCases = LocationUseCases(
        fetch: fetchUseCase,
        fetchCount: fetchCountUseCase,
        add: addUseCase,
        update: updateUseCase,
        delete: deleteUseCase,
        fetchRouteDistance: fetchRouteDistanceUseCase
    )

    init(
        appleMapService: AppleMapServiceProtocol,
        locationManager: LocationManagerProtocol,
        swiftDataContainer: SwiftDataContainer,
        localDataSource: LocationLocalDataSourceProtocol? = nil,
        locationMapper: LocationMapping = LocationMapper(),
        repository: LocationRepositoryProtocol? = nil
    ) {
        self.appleMapService = appleMapService
        self.locationManager = locationManager

        self.localDataSource = localDataSource ?? LocationLocalDataSource(
            swiftDataManager: swiftDataContainer.makeMainManager()
        )

        self.locationMapper = locationMapper

        self.repository = repository ?? LocationRepository(
            localDataSource: self.localDataSource,
            locationMapper: locationMapper
        )
    }

    // MARK: - ViewModel Factories
    func makeHomeViewModel(fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol) -> HomeViewModel {
        HomeViewModel(
            getUserLocationUseCase: getUserLocationUseCase,
            locationUseCase: useCases,
            fetchCollectionsUseCase: fetchCollectionsUseCase,
            appleMapService: appleMapService,
            locationManager: locationManager
        )
    }

    func makeCollectionListViewModel(collectionUseCases: CollectionUseCases) -> CollectionListViewModel {
        CollectionListViewModel(
            collectionUseCases: collectionUseCases,
            fetchLocationCountUseCase: fetchCountUseCase
        )
    }

    func makeLocationListViewModel(collection: Collection) -> LocationListViewModel {
        LocationListViewModel(collection: collection, locationUseCase: useCases)
    }

    func makeEditLocationViewModel(collectionContainer: CollectionContainer) -> EditLocationViewModel {
        EditLocationViewModel(
            fetchCollectionsUseCase: collectionContainer.fetchUseCase,
            addCollectionUseCase: collectionContainer.addUseCase
        )
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(mapService: appleMapService)
    }
}
