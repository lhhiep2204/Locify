//
//  FetchLocationCountUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/3/26.
//

import Foundation

protocol FetchLocationCountUseCaseProtocol: Sendable {
    func execute(for collectionId: UUID) async throws -> Int
}

final class FetchLocationCountUseCase: FetchLocationCountUseCaseProtocol {
    private let repository: LocationRepositoryProtocol

    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    func execute(for collectionId: UUID) async throws -> Int {
        try await repository.fetchLocationCount(for: collectionId)
    }
}
