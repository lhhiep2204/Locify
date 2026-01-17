//
//  LocationListViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 3/8/25.
//

import Foundation

@MainActor
@Observable
class LocationListViewModel {
    private let locationUseCase: LocationUseCases

    private(set) var locations: [Location] = []
    let collection: Collection

    init(
        collection: Collection,
        locationUseCase: LocationUseCases
    ) {
        self.collection = collection
        self.locationUseCase = locationUseCase
    }
}

extension LocationListViewModel {
    func fetchLocations() async {
        do {
            try await Task.sleep(for: .seconds(0.5))
            locations = try await locationUseCase.fetch.execute(for: collection.id)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func addLocation(_ location: Location) async {
        do {
            _ = try await locationUseCase.add.execute(location)
            locations.append(location)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func updateLocation(_ location: Location) async {
        guard let index = locations.firstIndex(where: { $0.id == location.id }),
              locations[index] != location else { return }

        do {
            _ = try await locationUseCase.update.execute(location)
            locations[index] = location
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func deleteLocation(_ location: Location) async {
        do {
            _ = try await locationUseCase.delete.execute(location)
            locations.removeAll { $0.id == location.id }
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
