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

    init(
        appleMapService: AppleMapServiceProtocol,
        locationManager: LocationManagerProtocol,
        localDataSource: LocationLocalDataSourceProtocol? = nil,
        locationMapper: LocationMapping = LocationMapper(),
        repository: LocationRepositoryProtocol? = nil
    ) {
        self.appleMapService = appleMapService
        self.locationManager = locationManager

        let swiftDataManager = SwiftDataContainer.shared.makeMainManager()

        self.localDataSource = localDataSource ?? LocationLocalDataSource(
            swiftDataManager: swiftDataManager
        )

        self.locationMapper = locationMapper

        self.repository = repository ?? LocationRepository(
            localDataSource: self.localDataSource,
            locationMapper: locationMapper
        )
    }

    // MARK: - ViewModel Factories
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(
            getUserLocationUseCase: getUserLocationUseCase,
            locationUseCase: useCases,
            locationManager: locationManager
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
}
