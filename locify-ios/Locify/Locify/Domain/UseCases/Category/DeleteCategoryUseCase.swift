//
//  DeleteCategoryUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol DeleteCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws -> Category
}

struct DeleteCategoryUseCase: DeleteCategoryUseCaseProtocol {
    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ category: Category) async throws -> Category {
        try await repository.deleteCategory(category)
    }
}
