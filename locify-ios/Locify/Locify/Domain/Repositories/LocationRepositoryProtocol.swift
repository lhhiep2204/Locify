//
//  LocationRepositoryProtocol.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol LocationRepositoryProtocol: Sendable {
    func fetchLocations(for categoryId: UUID) async throws -> [Location]
    func addLocation(_ location: Location) async throws -> Location
    func updateLocation(_ location: Location) async throws -> Location
    func deleteLocation(_ location: Location) async throws -> Location
}
