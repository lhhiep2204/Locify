//
//  FetchLocationsUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol FetchLocationsUseCaseProtocol {
    func execute(for category: Category) async throws -> [Location]
}

struct FetchLocationsUseCase: FetchLocationsUseCaseProtocol {
    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for category: Category) async throws -> [Location] {
        try await repository.fetchLocations(for: category.id)
    }
}
