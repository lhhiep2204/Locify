//
//  CollectionListViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 3/8/25.
//

import Foundation

@MainActor
@Observable
class CollectionListViewModel {
    private let collectionUseCases: CollectionUseCases

    private(set) var collections: [Collection] = []

    init(collectionUseCases: CollectionUseCases) {
        self.collectionUseCases = collectionUseCases
    }
}

extension CollectionListViewModel {
    func fetchCollections() async {
        do {
            try await Task.sleep(for: .seconds(0.5))
            collections = try await collectionUseCases.fetch.execute()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func addCollection(_ collection: Collection) async {
        do {
            try await collectionUseCases.add.execute(collection)
            collections.append(collection)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func updateCollection(_ collection: Collection) async {
        guard let index = collections.firstIndex(where: { $0.id == collection.id }),
              collections[index] != collection else { return }

        do {
            try await collectionUseCases.update.execute(collection)
            collections[index] = collection
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func deleteCollection(_ collection: Collection) async {
        do {
            try await collectionUseCases.delete.execute(collection)
            collections.removeAll { $0.id == collection.id }
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
