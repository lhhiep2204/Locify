//
//  CollectionResponse.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation

/// Data Transfer Object for Collection API responses.
struct CollectionResponse: Decodable, Equatable {
    let id: String
    let userId: String
    let name: String
    let icon: String?
    let isDefault: Bool?
    let visibility: String?
    let syncStatus: String
    let createdAt: String
    let updatedAt: String
    let share: ShareResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case icon
        case isDefault = "is_default"
        case visibility
        case syncStatus = "sync_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case share
    }
}

/// Paginated response wrapper for Collection API responses.
struct CollectionListResponse: Decodable {
    let data: [CollectionResponse]
    let meta: PaginationMeta
}
