//
//  LocationRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

final class LocationRepository: LocationRepositoryProtocol {
    func fetchLocations(for collectionId: UUID) async throws -> [Location] {
        Location.mockList.filter { $0.collectionId == collectionId }
    }

    func addLocation(_ location: Location) async throws -> Location {
        location
    }

    func updateLocation(_ location: Location) async throws -> Location {
        location
    }

    func deleteLocation(_ location: Location) async throws -> Location {
        location
    }
}
