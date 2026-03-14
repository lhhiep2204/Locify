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
    private let fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol
    private let appleMapService: AppleMapServiceProtocol
    private let locationManager: LocationManagerProtocol

    private(set) var selectedCollection: Collection?
    private(set) var selectedLocationId: UUID?
    private(set) var locationList: [Location] = []
    private(set) var userLocation: Location?

    var permissionDenied: Bool = false

    private var cancellables = Set<AnyCancellable>()

    var selectedLocation: Location? {
        locationList.first(where: { $0.id == selectedLocationId })
    }

    var relatedLocations: [Location] {
        locationList.filter { $0.id != selectedLocationId }
    }

    var mapLocations: [Location] {
        locationList.filter {
            $0.id != Constants.myLocationId && $0.id != Constants.mapSelectionId
        }
    }

    init(
        getUserLocationUseCase: GetUserLocationUseCaseProtocol,
        locationUseCase: LocationUseCases,
        fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol,
        appleMapService: AppleMapServiceProtocol,
        locationManager: LocationManagerProtocol
    ) {
        self.getUserLocationUseCase = getUserLocationUseCase
        self.locationUseCase = locationUseCase
        self.fetchCollectionsUseCase = fetchCollectionsUseCase
        self.appleMapService = appleMapService
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
            .receive(on: DispatchQueue.main)
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
        guard let location else { return }

        selectedLocationId = location.id
        locationList.removeAll(where: \.isTemporary)
        if !locationList.contains(location) {
            locationList.insert(location, at: 0)
        }
    }

    func selectLocationFromCollectionList(collection: Collection, id: UUID, locations: [Location]) {
        selectedCollection = collection
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

    func handleMapFeatureSelected(name: String?, coordinate: CLLocationCoordinate2D) {
        Task {
            do {
                let location = try await appleMapService.getSelectedMapLocationInfo(
                    name: name,
                    for: coordinate
                )
                selectLocation(location)
            } catch {
                Logger.error(error.localizedDescription)
            }
        }
    }

    func clearSelectedLocation() async {
        let isTemporaryLocation: Bool = {
            selectedLocationId == Constants.myLocationId ||
            selectedLocationId == Constants.searchedLocationId ||
            selectedLocationId == Constants.mapSelectionId
        }()

        if locationList.count > 2 && isTemporaryLocation {
            locationList.removeAll(where: \.isTemporary)
            selectedLocationId = locationList.first?.id
        } else {
            locationList.removeAll()
            selectedCollection = nil
            await getUserLocation()
        }
    }

    func fetchRouteInfo(
        from origin: Location,
        to destination: Location,
        transportType: TransportType = .auto
    ) async -> RouteInfo? {
        let resolvedType: TransportType

        if case .auto = transportType {
            let straightLine = origin.straightLineDistance(to: destination)
            resolvedType = .suggested(for: straightLine)
        } else {
            resolvedType = transportType
        }

        do {
            return try await locationUseCase.fetchRouteInfo.execute(
                from: origin,
                to: destination,
                transportType: resolvedType
            )
        } catch {
            Logger.error(error.localizedDescription)
            return nil
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

    func refreshFromCollectionListDismissed() async {
        guard let collection = selectedCollection else { return }

        do {
            let collections = try await fetchCollectionsUseCase.execute()

            guard collections.contains(where: { $0.id == collection.id }) else {
                await resetToDefault()
                return
            }

            let locations = try await locationUseCase.fetch.execute(for: collection.id)

            guard !locations.isEmpty else {
                await resetToDefault()
                return
            }

            locationList = locations

            let selectionStillValid = locations.contains(where: { $0.id == selectedLocationId })
            if !selectionStillValid {
                selectedLocationId = locations.first?.id
            }
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}

extension HomeViewModel {
    private func requestAndUpdateUserLocation() async throws {
        userLocation = try await getUserLocationUseCase.execute()

        guard let userLocation else { return }

        selectedLocationId = userLocation.id
        locationList.removeAll(where: \.isTemporary)
        locationList.insert(userLocation, at: 0)
    }

    private func handlePermissionDenied() {
        Logger.error("Permission denied")
        selectedLocationId = nil
        locationList.removeAll(where: \.isTemporary)
    }

    private func resetToDefault() async {
        selectedCollection = nil
        selectedLocationId = nil
        locationList.removeAll()

        do {
            try await requestAndUpdateUserLocation()
        } catch LocationError.permissionDenied {
            handlePermissionDenied()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
