//
//  AddCategoryUseCase.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 14/8/25.
//

import Foundation

protocol AddCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws -> Category
}

struct AddCategoryUseCase: AddCategoryUseCaseProtocol {
    private let repository: CategoryRepositoryProtocol

    init(repository: CategoryRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ category: Category) async throws -> Category {
        try await repository.addCategory(category)
    }
}
