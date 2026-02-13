//
//  LocationResponse.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation

/// Data Transfer Object for Location API responses.
struct LocationResponse: Decodable, Equatable {
    let id: String
    let userId: String
    let collectionId: String
    let placeId: String?
    let name: String
    let displayName: String
    let address: String?
    let latitude: Double
    let longitude: Double
    let category: String?
    let notes: String?
    let imageUrls: [String]?
    let tags: [String]?
    let isFavorite: Bool?
    let visibility: String?
    let syncStatus: String
    let createdAt: String
    let updatedAt: String
    let share: ShareResponse?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case collectionId = "collection_id"
        case placeId = "place_id"
        case name
        case displayName
        case address
        case latitude
        case longitude
        case category
        case notes
        case imageUrls = "image_urls"
        case tags
        case isFavorite = "is_favorite"
        case visibility
        case syncStatus = "sync_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case share
    }
}

/// Paginated response wrapper for Location API responses.
struct LocationListResponse: Decodable {
    let data: [LocationResponse]
    let meta: PaginationMeta
}
