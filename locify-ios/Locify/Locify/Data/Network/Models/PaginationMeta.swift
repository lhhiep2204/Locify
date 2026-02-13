//
//  PaginationMeta.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation

/// Pagination metadata for API responses.
struct PaginationMeta: Decodable {
    let totalCount: Int
    let totalPages: Int
    let page: Int
    let size: Int

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case totalPages = "total_pages"
        case page
        case size
    }
}
