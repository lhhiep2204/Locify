//
//  LocationRepositoryProtocol.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol LocationRepositoryProtocol: Sendable {
    func fetchLocations() async throws -> [Location]
}
