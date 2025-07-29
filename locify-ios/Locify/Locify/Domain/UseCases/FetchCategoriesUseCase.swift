//
//  FetchCategoriesUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

protocol FetchCategoriesUseCaseProtocol {
    func execute() async throws -> [Category]
}

struct FetchCategoriesUseCase: FetchCategoriesUseCaseProtocol {
    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Category] {
        try await repository.fetchCategories()
    }
}
