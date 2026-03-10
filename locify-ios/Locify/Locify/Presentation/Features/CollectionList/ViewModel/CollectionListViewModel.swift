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
    private let fetchLocationCountUseCase: FetchLocationCountUseCaseProtocol

    private(set) var collections: [Collection] = []
    private(set) var locationCounts: [UUID: Int] = [:]

    init(
        collectionUseCases: CollectionUseCases,
        fetchLocationCountUseCase: FetchLocationCountUseCaseProtocol
    ) {
        self.collectionUseCases = collectionUseCases
        self.fetchLocationCountUseCase = fetchLocationCountUseCase
    }
}

extension CollectionListViewModel {
    func fetchCollections() async {
        do {
            collections = try await collectionUseCases.fetch.execute()
            await fetchLocationCounts()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func addCollection(_ collection: Collection) async {
        do {
            try await collectionUseCases.add.execute(collection)
            collections.append(collection)
            locationCounts[collection.id] = 0
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
            locationCounts.removeValue(forKey: collection.id)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}

extension CollectionListViewModel {
    private func fetchLocationCounts() async {
        await withTaskGroup(of: (UUID, Int).self) { group in
            for collection in collections {
                group.addTask {
                    let count = (try? await self.fetchLocationCountUseCase.execute(for: collection.id)) ?? 0
                    return (collection.id, count)
                }
            }

            for await (id, count) in group {
                locationCounts[id] = count
            }
        }
    }
}
