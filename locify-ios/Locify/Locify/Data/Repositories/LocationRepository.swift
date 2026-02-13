//
//  LocationRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

/// Protocol defining Location repository operations for the domain layer.
protocol LocationRepositoryProtocol {
    func fetchLocations(for collectionId: UUID) async throws -> [Location]
    func fetchAllLocations() async throws -> [Location]
    func fetchLocationById(_ id: UUID) async throws -> Location?
    func fetchFavoriteLocations() async throws -> [Location]
    func addLocation(_ location: Location) async throws
    func updateLocation(_ location: Location) async throws
    func deleteLocation(_ location: Location) async throws
}

/// Implementation of LocationRepositoryProtocol for local-only storage.
/// Orchestrates data flow between domain and local data source using the mapper.
final class LocationRepository: LocationRepositoryProtocol {
    private let localDataSource: LocationLocalDataSourceProtocol
    private let locationMapper: LocationMapping

    init(
        localDataSource: LocationLocalDataSourceProtocol,
        locationMapper: LocationMapping
    ) {
        self.localDataSource = localDataSource
        self.locationMapper = locationMapper
    }

    // MARK: - Fetch Operations

    func fetchLocations(for collectionId: UUID) async throws -> [Location] {
        let localItems = try await localDataSource.fetchByCollectionId(collectionId)
        return locationMapper.toDomain(localItems)
    }

    func fetchAllLocations() async throws -> [Location] {
        let localItems = try await localDataSource.fetchAll()
        return locationMapper.toDomain(localItems)
    }

    func fetchLocationById(_ id: UUID) async throws -> Location? {
        let localItem = try await localDataSource.fetchById(id)
        return localItem.map { locationMapper.toDomain($0) }
    }

    func fetchFavoriteLocations() async throws -> [Location] {
        let localItems = try await localDataSource.fetchFavorites()
        return locationMapper.toDomain(localItems)
    }

    // MARK: - Create Operations

    func addLocation(_ location: Location) async throws {
        // Convert domain to local model
        let localItem = locationMapper.toLocal(location, syncStatus: .synced)

        // Save to local database
        try await localDataSource.insert(localItem)
    }

    // MARK: - Update Operations

    func updateLocation(_ location: Location) async throws {
        // Fetch existing local item
        guard let existingItem = try await localDataSource.fetchById(location.id) else {
            throw RepositoryError.itemNotFound
        }

        // Update the local item with new values
        locationMapper.updateLocal(existingItem, with: location, syncStatus: .synced)

        // Save changes
        try await localDataSource.update(existingItem)
    }

    // MARK: - Delete Operations

    func deleteLocation(_ location: Location) async throws {
        // Fetch local item
        guard let localItem = try await localDataSource.fetchById(location.id) else {
            throw RepositoryError.itemNotFound
        }

        // Delete from local database
        try await localDataSource.delete(localItem)
    }
}
