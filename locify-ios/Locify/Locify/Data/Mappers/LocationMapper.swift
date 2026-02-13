//
//  LocationMapper.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation

/// Protocol for mapping between Location domain entities and local data models.
/// Enables dependency injection and testability (e.g. mock mapper in repository tests).
protocol LocationMapping {
    // MARK: - Local (SwiftData ↔ Domain)
    func toDomain(_ item: LocationLocal) -> Location
    func toDomain(_ items: [LocationLocal]) -> [Location]
    func toLocal(_ location: Location, syncStatus: SyncStatus) -> LocationLocal
    func toLocal(_ locations: [Location], syncStatus: SyncStatus) -> [LocationLocal]
    func updateLocal(_ item: LocationLocal, with location: Location, syncStatus: SyncStatus)
}

/// Default implementation of LocationMapping for local storage.
struct LocationMapper: LocationMapping {
    // MARK: - Local (SwiftData ↔ Domain)

    func toDomain(_ item: LocationLocal) -> Location {
        .init(
            id: item.id,
            collectionId: item.collectionId,
            placeId: item.placeId,
            name: item.name,
            displayName: item.displayName,
            address: item.address,
            latitude: item.latitude,
            longitude: item.longitude,
            category: item.category,
            notes: item.notes,
            imageUrls: item.imageUrls,
            tags: item.tags,
            isFavorite: item.isFavorite,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }

    func toDomain(_ items: [LocationLocal]) -> [Location] {
        items.map { toDomain($0) }
    }

    func toLocal(_ location: Location, syncStatus: SyncStatus = .pendingCreate) -> LocationLocal {
        .init(
            id: location.id,
            collectionId: location.collectionId,
            placeId: location.placeId,
            name: location.name,
            displayName: location.displayName,
            address: location.address,
            latitude: location.latitude,
            longitude: location.longitude,
            category: location.category,
            notes: location.notes,
            imageUrls: location.imageUrls,
            tags: location.tags,
            isFavorite: location.isFavorite,
            syncStatus: syncStatus.rawValue,
            createdAt: location.createdAt,
            updatedAt: location.updatedAt
        )
    }

    func toLocal(_ locations: [Location], syncStatus: SyncStatus = .pendingCreate) -> [LocationLocal] {
        locations.map { toLocal($0, syncStatus: syncStatus) }
    }

    func updateLocal(_ item: LocationLocal, with location: Location, syncStatus: SyncStatus = .pendingUpdate) {
        item.collectionId = location.collectionId
        item.placeId = location.placeId
        item.name = location.name
        item.displayName = location.displayName
        item.address = location.address
        item.latitude = location.latitude
        item.longitude = location.longitude
        item.category = location.category
        item.notes = location.notes
        item.imageUrls = location.imageUrls
        item.tags = location.tags
        item.isFavorite = location.isFavorite
        item.syncStatus = syncStatus.rawValue
        item.updatedAt = location.updatedAt
    }
}
