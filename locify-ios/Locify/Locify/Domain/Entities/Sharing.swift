//
//  Sharing.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation

/// Represents the visibility level of a location or collection in the domain.
enum Visibility: String, Codable, Equatable {
    /// Only visible to the owner
    case `private`
    /// Visible to anyone with the link
    case `public`
    /// Shared with specific users
    case shared
}

/// Domain entity representing share information for a location or collection.
struct Share: Equatable, Hashable {
    let role: String
    let permissions: [Permission]?

    init(role: String, permissions: [Permission]? = nil) {
        self.role = role
        self.permissions = permissions
    }
}

/// Domain entity representing a user's permission on a shared location or collection.
struct Permission: Equatable, Hashable {
    let userId: String
    let role: String
    let name: String?
    let email: String?
    let userImageUrl: String?

    init(
        userId: String,
        role: String,
        name: String? = nil,
        email: String? = nil,
        userImageUrl: String? = nil
    ) {
        self.userId = userId
        self.role = role
        self.name = name
        self.email = email
        self.userImageUrl = userImageUrl
    }
}
