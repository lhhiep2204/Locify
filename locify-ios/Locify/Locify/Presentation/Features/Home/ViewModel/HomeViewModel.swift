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
    private let locationUseCase: LocationUseCases
    private let locationManager: LocationManagerProtocol

    private(set) var selectedCategory: Category?
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
        locationUseCase: LocationUseCases,
        locationManager: LocationManagerProtocol
    ) {
        self.getUserLocationUseCase = getUserLocationUseCase
        self.locationUseCase = locationUseCase
        self.locationManager = locationManager

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

    func selectLocationFromCategoryList(category: Category, id: UUID, locations: [Location]) {
        selectedCategory = category
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
            selectedCategory = nil
            await getUserLocation()
        }
    }

    func addLocation(_ location: Location) async {
        do {
            _ = try await locationUseCase.add.execute(location)
            selectedLocationId = location.id
            locationList.removeAll(where: \.isTemporary)
            locationList.append(location)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func updateLocation(_ location: Location) async {
        do {
            guard let index = locationList.firstIndex(where: { $0.id == location.id }) else { return }

            _ = try await locationUseCase.update.execute(location)
            locationList[index] = location
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func deleteLocation() async {
        guard let locationToDelete = locationList.first(where: { $0.id == selectedLocationId }) else { return }

        do {
            _ = try await locationUseCase.delete.execute(locationToDelete)

            if let id = locationList.filter({ $0 != locationToDelete }).first?.id {
                selectedLocationId = id
            } else {
                selectedLocationId = nil
            }

            locationList.removeAll(where: { $0.id == locationToDelete.id })
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}

extension HomeViewModel {
    private func requestAndUpdateUserLocation() async throws {
        let location = try await getUserLocationUseCase.execute()
        selectedLocationId = location.id
        locationList.removeAll(where: \.isTemporary)
        locationList.insert(location, at: 0)
    }

    private func handlePermissionDenied() {
        Logger.error("Permission denied")
        selectedLocationId = nil
        locationList.removeAll(where: \.isTemporary)
    }
}
