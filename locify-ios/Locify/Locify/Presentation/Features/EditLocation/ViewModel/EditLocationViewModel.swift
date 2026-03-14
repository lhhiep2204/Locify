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
    enum Mode {
        case create
        case update(Location)
    }

    private let fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol
    private let addCollectionUseCase: AddCollectionUseCaseProtocol

    let mode: Mode

    private(set) var collections: [Collection] = []
    private(set) var errorMessage: String = .empty

    var collection: Collection?

    var placeId: String?
    var displayName: String = .empty
    var name: String = .empty
    var address: String = .empty
    var latitude: String = .empty
    var longitude: String = .empty
    var category: String = .empty
    var notes: String = .empty

    init(
        mode: Mode,
        collection: Collection?,
        fetchCollectionsUseCase: FetchCollectionsUseCaseProtocol,
        addCollectionUseCase: AddCollectionUseCaseProtocol
    ) {
        self.mode = mode
        self.collection = collection
        self.fetchCollectionsUseCase = fetchCollectionsUseCase
        self.addCollectionUseCase = addCollectionUseCase

        if case let .update(location) = mode {
            placeId = location.placeId
            displayName = location.displayName
            name = location.name
            address = location.address
            latitude = String(location.latitude)
            longitude = String(location.longitude)
            category = location.category
            notes = location.notes ?? .empty
        }
    }
}

extension EditLocationViewModel {
    func fetchCollections() async {
        do {
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
        category = location.category
    }

    func save(completion: (Location?) -> Void) {
        guard isValid, let collection else {
            completion(nil)
            return
        }

        switch mode {
        case .create:
            let new = Location(
                collectionId: collection.id,
                placeId: placeId,
                name: name,
                displayName: displayName.trimmed,
                address: address,
                latitude: latitude.asDouble,
                longitude: longitude.asDouble,
                category: category,
                notes: notes.trimmed.isEmpty ? nil : notes.trimmed
            )
            completion(new)
        case .update(let existing):
            var updated = existing
            updated.collectionId = collection.id
            updated.displayName = displayName.trimmed
            updated.notes = notes.trimmed.isEmpty ? nil : notes.trimmed
            updated.updatedAt = Date()
            completion(updated)
        }
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
