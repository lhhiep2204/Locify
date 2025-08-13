//
//  Category.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// A domain entity representing a category for grouping locations, owned by a user.
struct Category: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let syncStatus: SyncStatus
    let createdAt: Date
    let updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        syncStatus: SyncStatus = .pendingCreate,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.syncStatus == rhs.syncStatus &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }
}

extension Category {
    /// A mock category for testing, previews, or development.
    static let mock: Category = .init(
        id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
        name: "Food",
        createdAt: Date(timeIntervalSince1970: 1697059200),
        updatedAt: Date(timeIntervalSince1970: 1697059200)
    )

    /// A list of mock categories for testing, previews, or development.
    static let mockList: [Category] = [
        .init(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
            name: "Food",
            createdAt: Date(timeIntervalSince1970: 1697059200),
            updatedAt: Date(timeIntervalSince1970: 1697059200)
        ),
        .init(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174001")!,
            name: "Shopping",
            createdAt: Date(timeIntervalSince1970: 1697145600),
            updatedAt: Date(timeIntervalSince1970: 1697145600)
        ),
        .init(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174002")!,
            name: "Travel",
            createdAt: Date(timeIntervalSince1970: 1697232000),
            updatedAt: Date(timeIntervalSince1970: 1697232000)
        ),
        .init(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174003")!,
            name: "Work",
            createdAt: Date(timeIntervalSince1970: 1697318400),
            updatedAt: Date(timeIntervalSince1970: 1697318400)
        )
    ]
}
