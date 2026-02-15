//
//  LocationMetadata.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/2/26.
//

import Foundation

/// Metadata extracted from geocoding services without coordinate information.
///
/// This type is used internally to pass location metadata (name, address, place ID) separately from coordinates,
/// ensuring coordinates are never accidentally replaced by geocoding service results.
struct LocationMetadata {
    /// The place name
    let name: String
    /// The full formatted address
    let address: String
    /// Unique place identifier, if available
    let placeId: String?
}
