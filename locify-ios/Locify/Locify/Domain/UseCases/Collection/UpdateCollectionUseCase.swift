//
//  UpdateCollectionUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol UpdateCollectionUseCaseProtocol {
    func execute(_ collection: Collection) async throws
}

struct UpdateCollectionUseCase: UpdateCollectionUseCaseProtocol {
    private let repository: CollectionRepositoryProtocol

    init(repository: CollectionRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ collection: Collection) async throws {
        try await repository.updateCollection(collection)
    }
}
