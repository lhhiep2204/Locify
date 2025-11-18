//
//  HomeViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Combine
import CoreLocation
import Foundation

@MainActor
@Observable
class HomeViewModel {
    private let getUserLocationUseCase: GetUserLocationUseCaseProtocol
    private let locationManager: LocationManagerProtocol
    private let appleMapService: AppleMapServiceProtocol

    private(set) var selectedLocationId: UUID?
    private(set) var locationList: [Location] = []
    var permissionDenied: Bool = false

    private var cancellables = Set<AnyCancellable>()

    var selectedLocation: Location? {
        locationList.first(where: { $0.id == selectedLocationId })
    }

    var relatedLocations: [Location] {
        locationList.filter { $0.id != selectedLocationId }
    }

    init(
        getUserLocationUseCase: GetUserLocationUseCaseProtocol,
        locationManager: LocationManagerProtocol,
        appleMapService: AppleMapServiceProtocol
    ) {
        self.getUserLocationUseCase = getUserLocationUseCase
        self.locationManager = locationManager
        self.appleMapService = appleMapService

        Task {
            do {
                try await requestAndUpdateUserLocation()
            } catch LocationError.permissionDenied {
                handlePermissionDenied()
            } catch {
                Logger.error(error.localizedDescription)
            }
        }

        locationManager.authorizationUpdates
            .dropFirst()
            .sink { [weak self] status in
                guard let self else { return }

                if case .denied = status {
                    handlePermissionDenied()
                }
            }
            .store(in: &cancellables)
    }
}

extension HomeViewModel {
    func getUserLocation() async {
        do {
            try await requestAndUpdateUserLocation()
        } catch LocationError.permissionDenied {
            handlePermissionDenied()
            permissionDenied = true
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func selectLocation(_ location: Location?) {
        selectedLocationId = location?.id
    }

    func selectLocationFromCategoryList(id: UUID, locations: [Location]) {
        selectedLocationId = id
        locationList = locations
    }

    func selectRelatedLocation(_ locationId: UUID) {
        selectedLocationId = locationId
        locationList.removeAll(where: \.isTemporary)
    }

    func selectLocationFromSearch(_ location: Location) {
        selectedLocationId = location.id
        locationList.removeAll(where: \.isTemporary)
        locationList.insert(location, at: 0)
    }

    func clearSelectedLocation() async {
        let isTemporaryLocation: Bool = {
            selectedLocationId == Constants.myLocationId ||
            selectedLocationId == Constants.searchedLocationId
        }()

        if locationList.count > 2 && isTemporaryLocation {
            locationList.removeAll(where: \.isTemporary)
            selectedLocationId = locationList.first?.id
        } else {
            locationList.removeAll()
            await getUserLocation()
        }
    }
}

extension HomeViewModel {
    private func requestAndUpdateUserLocation() async throws {
        let location = try await getUserLocationUseCase.execute()
        selectedLocationId = location.id
        locationList.removeAll { $0.id == Constants.searchedLocationId }
        locationList.insert(location, at: 0)
    }

    private func handlePermissionDenied() {
        Logger.error("Permission denied")
        selectedLocationId = nil
        locationList.removeAll { $0.id == Constants.myLocationId }
    }
}
