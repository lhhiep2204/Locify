//
//  FetchRouteInfoUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 10/3/26.
//

import Foundation

protocol FetchRouteInfoUseCaseProtocol {
    func execute(
        from origin: Location,
        to destination: Location,
        transportType: TransportType
    ) async throws -> RouteInfo
}

struct FetchRouteInfoUseCase: FetchRouteInfoUseCaseProtocol {
    private let mapService: AppleMapServiceProtocol

    init(mapService: AppleMapServiceProtocol) {
        self.mapService = mapService
    }

    func execute(
        from origin: Location,
        to destination: Location,
        transportType: TransportType = .automobile
    ) async throws -> RouteInfo {
        try await mapService.fetchRouteInfo(
            from: origin,
            to: destination,
            transportType: transportType
        )
    }
}
