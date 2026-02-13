//
//  CollectionRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

/// Protocol defining Collection repository operations for the domain layer.
protocol CollectionRepositoryProtocol {
    func fetchCollections() async throws -> [Collection]
    func fetchCollectionById(_ id: UUID) async throws -> Collection?
    func addCollection(_ collection: Collection) async throws
    func updateCollection(_ collection: Collection) async throws
    func deleteCollection(_ collection: Collection) async throws
}

/// Implementation of CollectionRepositoryProtocol for local-only storage.
/// Orchestrates data flow between domain and local data source using the mapper.
final class CollectionRepository: CollectionRepositoryProtocol {
    private let localDataSource: CollectionLocalDataSourceProtocol
    private let collectionMapper: CollectionMapping

    init(
        localDataSource: CollectionLocalDataSourceProtocol,
        collectionMapper: CollectionMapping
    ) {
        self.localDataSource = localDataSource
        self.collectionMapper = collectionMapper
    }

    // MARK: - Fetch Operations

    func fetchCollections() async throws -> [Collection] {
        let localItems = try await localDataSource.fetchAll()
        return collectionMapper.toDomain(localItems)
    }

    func fetchCollectionById(_ id: UUID) async throws -> Collection? {
        let localItem = try await localDataSource.fetchById(id)
        return localItem.map { collectionMapper.toDomain($0) }
    }

    // MARK: - Create Operations

    func addCollection(_ collection: Collection) async throws {
        // Convert domain to local model
        let localItem = collectionMapper.toLocal(collection, syncStatus: .synced)

        // Save to local database
        try await localDataSource.insert(localItem)
    }

    // MARK: - Update Operations

    func updateCollection(_ collection: Collection) async throws {
        // Fetch existing local item
        guard let existingItem = try await localDataSource.fetchById(collection.id) else {
            throw RepositoryError.itemNotFound
        }

        // Update the local item with new values
        collectionMapper.updateLocal(existingItem, with: collection, syncStatus: .synced)

        // Save changes
        try await localDataSource.update(existingItem)
    }

    // MARK: - Delete Operations

    func deleteCollection(_ collection: Collection) async throws {
        // Fetch local item
        guard let localItem = try await localDataSource.fetchById(collection.id) else {
            throw RepositoryError.itemNotFound
        }

        // Delete from local database
        try await localDataSource.delete(localItem)
    }
}
