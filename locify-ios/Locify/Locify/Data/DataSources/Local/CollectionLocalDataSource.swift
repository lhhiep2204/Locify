//
//  CollectionLocalDataSource.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation
import SwiftData

/// Protocol for local data source operations on Collection entities.
protocol CollectionLocalDataSourceProtocol {
    func fetchAll() async throws -> [CollectionLocal]
    func fetchById(_ id: UUID) async throws -> CollectionLocal?
    func insert(_ item: CollectionLocal) async throws
    func update(_ item: CollectionLocal) async throws
    func delete(_ item: CollectionLocal) async throws
}

/// SwiftData implementation of CollectionLocalDataSourceProtocol.
final class CollectionLocalDataSource: CollectionLocalDataSourceProtocol {
    private let swiftDataManager: SwiftDataManaging

    init(swiftDataManager: SwiftDataManaging) {
        self.swiftDataManager = swiftDataManager
    }

    func fetchAll() async throws -> [CollectionLocal] {
        let descriptor = FetchDescriptor<CollectionLocal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try swiftDataManager.fetch(descriptor)
    }

    func fetchById(_ id: UUID) async throws -> CollectionLocal? {
        let descriptor = FetchDescriptor<CollectionLocal>(
            predicate: #Predicate { $0.id == id }
        )
        return try swiftDataManager.fetchOne(descriptor)
    }

    func insert(_ item: CollectionLocal) async throws {
        try swiftDataManager.insert(item)
    }

    func update(_ item: CollectionLocal) async throws {
        try swiftDataManager.save()
    }

    func delete(_ item: CollectionLocal) async throws {
        try swiftDataManager.delete(item)
    }
}
