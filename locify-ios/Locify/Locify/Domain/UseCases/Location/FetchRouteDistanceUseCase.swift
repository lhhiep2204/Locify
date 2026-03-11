//
//  FetchRouteDistanceUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 10/3/26.
//

import Foundation

protocol FetchRouteDistanceUseCaseProtocol {
    func execute(
        from origin: Location,
        to destination: Location,
        transportType: TransportType
    ) async throws -> Double
}

struct FetchRouteDistanceUseCase: FetchRouteDistanceUseCaseProtocol {
    private let mapService: AppleMapServiceProtocol

    init(mapService: AppleMapServiceProtocol) {
        self.mapService = mapService
    }

    func execute(
        from origin: Location,
        to destination: Location,
        transportType: TransportType = .automobile
    ) async throws -> Double {
        try await mapService.fetchRouteDistance(
            from: origin,
            to: destination,
            transportType: transportType
        )
    }
}
