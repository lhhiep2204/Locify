//
//  DeleteCollectionUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol DeleteCollectionUseCaseProtocol {
    func execute(_ collection: Collection) async throws -> Collection
}

struct DeleteCollectionUseCase: DeleteCollectionUseCaseProtocol {
    private let repository: CollectionRepositoryProtocol

    init(repository: CollectionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ collection: Collection) async throws -> Collection {
        try await repository.deleteCollection(collection)
    }
}
