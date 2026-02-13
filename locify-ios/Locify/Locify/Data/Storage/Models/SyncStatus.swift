//
//  SyncStatus.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// Represents the synchronization state of an entity for offline/online data management.
enum SyncStatus: String, Codable, Equatable {
    /// The entity is fully synchronized with the server.
    case synced
    /// The entity was created locally and awaits server synchronization.
    case pendingCreate
    /// The entity was updated locally and awaits server synchronization.
    case pendingUpdate
    /// The entity was deleted locally and awaits server synchronization.
    case pendingDelete
}
