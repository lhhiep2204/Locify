//
//  HomeViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Combine
import Foundation

@Observable
class HomeViewModel {
    var selectedLocationId: UUID?
    var locations: [Location] = []
    var permissionDenied: Bool = false

    private let locationManager = LocationManager.shared
    private let appleMapService = AppleMapService()

    var selectedLocation: Location? {
        guard let selectedLocationId else { return nil }
        return locations.first(where: { $0.id == selectedLocationId })
    }

    var relatedLocations: [Location] {
        guard let selectedLocationId else { return [] }
        return locations.filter { $0.id != selectedLocationId }
    }

    init() {
        Task {
            do {
                try await requestAndUpdateUserLocation()
            } catch {
                if let error = error as? LocationError {
                    switch error {
                    case .permissionDenied:
                        Logger.error("Permission denied")
                    default:
                        Logger.error(error.localizedDescription)
                    }
                }
            }
        }
    }
}

extension HomeViewModel {
    func getUserLocation() async {
        do {
            try await requestAndUpdateUserLocation()
        } catch {
            if let error = error as? LocationError {
                switch error {
                case .permissionDenied:
                    Logger.error("Permission denied")
                    permissionDenied = true
                default:
                    Logger.error(error.localizedDescription)
                }
            }
        }
    }

    func clearSelectedLocation() {
        Task {
            await getUserLocation()
        }
        locations = []
    }
}

extension HomeViewModel {
    private func requestAndUpdateUserLocation() async throws {
        let isGranted = try await locationManager.requestPermission(type: .whenInUse)

        if isGranted {
            try await locationManager.startUpdatingLocation()

            let locationInfo = try await appleMapService.getLocationInfo(
                for: locationManager.getLastKnownLocation()
            )
            locations.insert(locationInfo, at: 0)
            selectedLocationId = locationInfo.id
        } else {
            Logger.warning("Permission not granted")
        }
    }
}
