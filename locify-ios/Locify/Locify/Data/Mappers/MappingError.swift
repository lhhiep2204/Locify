//
//  MappingError.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 23/1/26.
//

import Foundation

/// Errors that can occur during mapping operations between domain entities and data models.
enum MappingError: LocalizedError {
    case invalidUUID(String)
    case invalidSyncStatus(String)
    case invalidDate(String)
    case missingRequiredField(String)

    var errorDescription: String? {
        switch self {
        case .invalidUUID(let value): "Invalid UUID format: \(value)"
        case .invalidSyncStatus(let value): "Invalid sync status: \(value)"
        case .invalidDate(let value): "Invalid date format: \(value)"
        case .missingRequiredField(let field): "Missing required field: \(field)"
        }
    }
}
