//
//  GetUserLocationUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import Foundation

protocol GetUserLocationUseCaseProtocol {
    func execute() async throws -> Location
}

struct GetUserLocationUseCase: GetUserLocationUseCaseProtocol {
    private let appleMapService: AppleMapServiceProtocol
    private let locationManager: LocationManagerProtocol

    init(
        appleMapService: AppleMapServiceProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.appleMapService = appleMapService
        self.locationManager = locationManager
    }

    func execute() async throws -> Location {
        let granted = try await locationManager.requestPermission(type: .whenInUse)
        guard granted else { throw LocationError.permissionNotGranted }

        try await locationManager.startUpdatingLocation()
        return try await appleMapService.getUserLocationInfo(for: locationManager.getLastKnownLocation())
    }
}
