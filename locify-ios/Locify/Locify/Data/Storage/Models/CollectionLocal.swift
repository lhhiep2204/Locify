//
//  CollectionLocal.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation
import SwiftData

/// SwiftData model for persisting Collection entities locally.
@Model
final class CollectionLocal {
    @Attribute(.unique) var id: UUID
    var name: String
    var icon: String?
    var isDefault: Bool
    var syncStatus: String // Stored as String to map to SyncStatus enum
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID,
        name: String,
        icon: String? = nil,
        isDefault: Bool = false,
        syncStatus: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
