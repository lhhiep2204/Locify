//
//  Collection.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// A domain entity representing a collection for grouping locations, owned by a user.
struct Collection: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var icon: String?
    var isDefault: Bool
    var visibility: Visibility
    var share: Share?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        icon: String? = nil,
        isDefault: Bool = false,
        visibility: Visibility = .private,
        share: Share? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
        self.visibility = visibility
        self.share = share
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Collection {
    /// A mock collection for testing, previews, or development.
    static let mock: Collection = .init(
        id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174000")!,
        name: "Food",
        createdAt: Date(timeIntervalSince1970: 1697059200),
        updatedAt: Date(timeIntervalSince1970: 1697059200)
    )

    /// A list of mock collections for testing, previews, or development.
    static let mockList: [Collection] = [
        .init(
            id: UUID(uuidString: "123e4567-e89b-12d3-a456-426614174004")!,
            name: "Football Stadium",
            createdAt: Date(timeIntervalSince1970: 1697404800),
            updatedAt: Date(timeIntervalSince1970: 1697404800)
        ),
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
