//
//  EditLocationViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 24/8/25.
//

import Foundation

@MainActor
@Observable
class EditLocationViewModel {
    private let fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol
    private let addCollectionUseCase: AddCollectionUseCaseProtocol

    private(set) var collections: [Collection] = []

    var collection: Collection?

    var placeId: String?
    var displayName: String = .empty
    var name: String = .empty
    var address: String = .empty
    var latitude: String = .empty
    var longitude: String = .empty
    var notes: String = .empty

    private(set) var errorMessage: String = .empty

    init(
        fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol,
        addCollectionUseCase: AddCollectionUseCaseProtocol
    ) {
        self.fetchCollectionsUseCase = fetchCollectionsUseCase
        self.addCollectionUseCase = addCollectionUseCase
    }
}

extension EditLocationViewModel {
    func fetchCollections() async {
        do {
            try await Task.sleep(for: .seconds(0.5))
            collections = try await fetchCollectionsUseCase.execute()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func addCollection(_ collection: Collection) async {
        do {
            _ = try await addCollectionUseCase.execute(collection)
            collections.append(collection)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func selectSearchedLocation(_ location: Location) {
        placeId = location.placeId
        name = location.name
        address = location.address
        latitude = String(location.latitude)
        longitude = String(location.longitude)
    }

    func createLocation(completion: (Location?) -> Void) {
        let location: Location = .init(
            collectionId: collection?.id ?? UUID(),
            placeId: placeId,
            name: name,
            displayName: displayName,
            address: address,
            latitude: latitude.asDouble,
            longitude: longitude.asDouble,
            notes: notes.trimmed.isEmpty ? nil : notes
        )

        guard isValid else {
            completion(nil)
            return
        }

        completion(location)
    }

    func updateLocation(locationToUpdate: Location?, completion: (Location?) -> Void) {
        guard let locationToUpdate, let collection else {
            completion(nil)
            return
        }

        var location = locationToUpdate
        location.collectionId = collection.id
        location.displayName = displayName
        location.notes = notes.trimmed.isEmpty ? nil : notes
        location.updatedAt = Date()

        guard isValid else {
            completion(nil)
            return
        }

        completion(location)
    }

    func clearErrorState() {
        errorMessage = .empty
    }
}

extension EditLocationViewModel {
    private var isValid: Bool {
        if collection == nil {
            errorMessage = "Please select a list."
            return false
        }

        if address.trimmed.isEmpty {
            errorMessage = "Please select a location."
            return false
        }

        clearErrorState()
        return true
    }
}
