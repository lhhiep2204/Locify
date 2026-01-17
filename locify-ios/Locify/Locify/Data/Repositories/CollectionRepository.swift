//
//  CollectionRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

final class CollectionRepository: CollectionRepositoryProtocol {
    func fetchCollections() async throws -> [Collection] {
        Collection.mockList
    }

    func addCollection(_ collection: Collection) async throws -> Collection {
        collection
    }

    func updateCollection(_ collection: Collection) async throws -> Collection {
        collection
    }

    func deleteCollection(_ collection: Collection) async throws -> Collection {
        collection
    }
}
