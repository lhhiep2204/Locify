//
//  FetchCollectionsUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol FetchCollectionsUseCaseProtocol {
    func execute() async throws -> [Collection]
}

struct FetchCollectionsUseCase: FetchCollectionsUseCaseProtocol {
    private let repository: CollectionRepositoryProtocol

    init(repository: CollectionRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Collection] {
        try await repository.fetchCollections()
    }
}
