//
//  LocationLocalDataSource.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation
import SwiftData

/// Protocol for local data source operations on Location entities.
protocol LocationLocalDataSourceProtocol {
    func fetchAll() async throws -> [LocationLocal]
    func fetchById(_ id: UUID) async throws -> LocationLocal?
    func fetchByCollectionId(_ collectionId: UUID) async throws -> [LocationLocal]
    func insert(_ item: LocationLocal) async throws
    func update(_ item: LocationLocal) async throws
    func delete(_ item: LocationLocal) async throws
    func fetchFavorites() async throws -> [LocationLocal]
}

/// SwiftData implementation of LocationLocalDataSourceProtocol.
final class LocationLocalDataSource: LocationLocalDataSourceProtocol {
    private let swiftDataManager: SwiftDataManaging

    init(swiftDataManager: SwiftDataManaging) {
        self.swiftDataManager = swiftDataManager
    }

    func fetchAll() async throws -> [LocationLocal] {
        let descriptor = FetchDescriptor<LocationLocal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try swiftDataManager.fetch(descriptor)
    }

    func fetchById(_ id: UUID) async throws -> LocationLocal? {
        let descriptor = FetchDescriptor<LocationLocal>(
            predicate: #Predicate { $0.id == id }
        )
        return try swiftDataManager.fetchOne(descriptor)
    }

    func fetchByCollectionId(_ collectionId: UUID) async throws -> [LocationLocal] {
        let descriptor = FetchDescriptor<LocationLocal>(
            predicate: #Predicate { $0.collectionId == collectionId },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try swiftDataManager.fetch(descriptor)
    }

    func insert(_ item: LocationLocal) async throws {
        try swiftDataManager.insert(item)
    }

    func update(_ item: LocationLocal) async throws {
        try swiftDataManager.save()
    }

    func delete(_ item: LocationLocal) async throws {
        try swiftDataManager.delete(item)
    }

    func fetchFavorites() async throws -> [LocationLocal] {
        let descriptor = FetchDescriptor<LocationLocal>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try swiftDataManager.fetch(descriptor)
    }
}
