//
//  UpdateCategoryUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol UpdateCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws -> Category
}

struct UpdateCategoryUseCase: UpdateCategoryUseCaseProtocol {
    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ category: Category) async throws -> Category {
        try await repository.updateCategory(category)
    }
}
