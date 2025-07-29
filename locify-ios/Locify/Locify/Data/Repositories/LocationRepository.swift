//
//  LocationRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

final class LocationRepository: LocationRepositoryProtocol {
    func fetchLocations(for categoryId: UUID) async throws -> [Location] {
        Location.mockList.filter { $0.categoryId == categoryId }
    }
}
