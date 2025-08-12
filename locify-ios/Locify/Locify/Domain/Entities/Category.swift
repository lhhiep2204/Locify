//
//  Category.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// A domain entity representing a category for grouping locations, owned by a user.
struct Category: Identifiable, Equatable, Hashable {
    /// Unique identifier for the category.
    let id: UUID
    /// Identifier of the user who owns this category.
    let userId: String
    /// Name of the category.
    let name: String
    /// Optional URL for the category icon.
    let icon: String?
    /// Synchronization status with the server.
    let syncStatus: SyncStatus
    /// Creation timestamp.
    let createdAt: Date
    /// Last update timestamp
    let updatedAt: Date

    /// Initializes a Category with default or provided values.
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID).
    ///   - userId: User identifier (required).
    ///   - name: Category name (required).
    ///   - icon: Optional icon URL.
    ///   - syncStatus: Synchronization status (defaults to `.pendingCreate`).
    ///   - createdAt: Creation timestamp (defaults to current date).
    ///   - updatedAt: Last update timestamp (defaults to current date).
    init(
        id: UUID = UUID(),
        userId: String,
        name: String,
        icon: String? = nil,
        syncStatus: SyncStatus = .pendingCreate,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.icon = icon
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Compares two Category instances for equality.
    static func == (lhs: Category, rhs: Category) -> Bool {
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.name == rhs.name &&
        lhs.icon == rhs.icon &&
        lhs.syncStatus == rhs.syncStatus &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }
}

extension Category {
    /// A mock category for testing, previews, or development.
    static let mock: Category = .init(
        userId: "user1",
        name: "Food",
        icon: "fork.knife"
    )

    /// A list of mock categories for testing, previews, or development.
    static let mockList: [Category] = [
        .init(
            userId: "user1",
            name: "Food",
            icon: "fork.knife"
        ),
        .init(
            userId: "user1",
            name: "Shopping",
            icon: "cart"
        ),
        .init(
            userId: "user1",
            name: "Travel",
            icon: "airplane"
        ),
        .init(
            userId: "user1",
            name: "Work",
            icon: "briefcase"
        )
    ]
}
