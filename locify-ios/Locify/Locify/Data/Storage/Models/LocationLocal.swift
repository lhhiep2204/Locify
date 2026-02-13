//
//  LocationLocal.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation
import SwiftData

/// SwiftData model for persisting Location entities locally.
@Model
final class LocationLocal {
    @Attribute(.unique) var id: UUID
    var collectionId: UUID
    var placeId: String?
    var name: String
    var displayName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var category: String?
    var notes: String?
    var imageUrls: [String]?
    var tags: [String]?
    var isFavorite: Bool
    var syncStatus: String // Stored as String to map to SyncStatus enum
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        collectionId: UUID,
        placeId: String? = nil,
        name: String,
        displayName: String,
        address: String,
        latitude: Double,
        longitude: Double,
        category: String? = nil,
        notes: String? = nil,
        imageUrls: [String]? = nil,
        tags: [String]? = nil,
        isFavorite: Bool = false,
        syncStatus: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.collectionId = collectionId
        self.placeId = placeId
        self.name = name
        self.displayName = displayName
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.category = category
        self.notes = notes
        self.imageUrls = imageUrls
        self.tags = tags
        self.isFavorite = isFavorite
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
