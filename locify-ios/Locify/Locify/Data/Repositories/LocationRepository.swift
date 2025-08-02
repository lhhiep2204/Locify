//
//  LocationRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

final class LocationRepository: LocationRepositoryProtocol {
    func fetchLocations() async throws -> [Location] {
        Location.mockList
    }
}
