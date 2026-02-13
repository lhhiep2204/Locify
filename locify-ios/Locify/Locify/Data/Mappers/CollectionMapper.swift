//
//  CollectionMapper.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation

/// Protocol for mapping between Collection domain entities and local data models.
/// Enables dependency injection and testability (e.g. mock mapper in repository tests).
protocol CollectionMapping {
    // MARK: - Local (SwiftData ↔ Domain)
    func toDomain(_ item: CollectionLocal) -> Collection
    func toDomain(_ items: [CollectionLocal]) -> [Collection]
    func toLocal(_ collection: Collection, syncStatus: SyncStatus) -> CollectionLocal
    func toLocal(_ collections: [Collection], syncStatus: SyncStatus) -> [CollectionLocal]
    func updateLocal(_ item: CollectionLocal, with collection: Collection, syncStatus: SyncStatus)
}

/// Default implementation of CollectionMapping for local storage.
struct CollectionMapper: CollectionMapping {
    // MARK: - Local (SwiftData ↔ Domain)

    func toDomain(_ item: CollectionLocal) -> Collection {
        .init(
            id: item.id,
            name: item.name,
            icon: item.icon,
            isDefault: item.isDefault,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }

    func toDomain(_ items: [CollectionLocal]) -> [Collection] {
        items.map { toDomain($0) }
    }

    func toLocal(_ collection: Collection, syncStatus: SyncStatus = .pendingCreate) -> CollectionLocal {
        .init(
            id: collection.id,
            name: collection.name,
            icon: collection.icon,
            isDefault: collection.isDefault,
            syncStatus: syncStatus.rawValue,
            createdAt: collection.createdAt,
            updatedAt: collection.updatedAt
        )
    }

    func toLocal(_ collections: [Collection], syncStatus: SyncStatus = .pendingCreate) -> [CollectionLocal] {
        collections.map { toLocal($0, syncStatus: syncStatus) }
    }

    func updateLocal(_ item: CollectionLocal, with collection: Collection, syncStatus: SyncStatus = .pendingUpdate) {
        item.name = collection.name
        item.icon = collection.icon
        item.isDefault = collection.isDefault
        item.syncStatus = syncStatus.rawValue
        item.updatedAt = collection.updatedAt
    }
}
