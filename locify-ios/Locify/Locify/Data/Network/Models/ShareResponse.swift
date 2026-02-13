//
//  ShareResponse.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation

/// Data Transfer Object for Share information in API responses.
struct ShareResponse: Decodable, Equatable {
    let role: String
    let permissions: [PermissionResponse]?
}

/// Data Transfer Object for Permission information in API responses.
struct PermissionResponse: Decodable, Equatable {
    let userId: String
    let role: String
    let name: String?
    let email: String?
    let userImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case role
        case name
        case email
        case userImageUrl = "user_image_url"
    }
}
