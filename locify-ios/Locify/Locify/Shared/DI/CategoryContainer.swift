//
//  CategoryContainer.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 26/10/25.
//

import Foundation

/// Dependency container responsible for Category feature setup.
///
/// Provides repositories, use cases, and ViewModel factories related to Category operations.
final class CategoryContainer {
    // MARK: - Repository
    private let repository: CategoryRepositoryProtocol

    // MARK: - Use Cases
    private(set) lazy var fetchUseCase = FetchCategoriesUseCase(repository: repository)
    private(set) lazy var addUseCase = AddCategoryUseCase(repository: repository)
    private lazy var updateUseCase = UpdateCategoryUseCase(repository: repository)
    private lazy var deleteUseCase = DeleteCategoryUseCase(repository: repository)

    private lazy var useCases = CategoryUseCases(
        fetch: fetchUseCase,
        add: addUseCase,
        update: updateUseCase,
        delete: deleteUseCase
    )

    // MARK: - Initialization
    init(repository: CategoryRepositoryProtocol = CategoryRepository()) {
        self.repository = repository
    }
}

// MARK: - ViewModel Factories
extension CategoryContainer {
    func makeCategoryListViewModel() -> CategoryListViewModel {
        CategoryListViewModel(categoryUseCases: useCases)
    }

    func makeEditCategoryViewModel() -> EditCategoryViewModel {
        EditCategoryViewModel()
    }
}
