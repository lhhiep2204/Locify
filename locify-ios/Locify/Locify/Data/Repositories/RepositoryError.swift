//
//  RepositoryError.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/2/26.
//

import Foundation

enum RepositoryError: LocalizedError {
    case itemNotFound
    case invalidData

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            return "Item not found in local storage"
        case .invalidData:
            return "Invalid data format"
        }
    }
}
