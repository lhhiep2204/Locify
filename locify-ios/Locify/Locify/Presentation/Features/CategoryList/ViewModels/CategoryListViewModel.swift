//
//  CategoryListViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 3/8/25.
//

import Foundation

@Observable
class CategoryListViewModel {
    var categories: [Category] = []

    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol

    init(
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
    }
}

extension CategoryListViewModel {
    func fetchCategories() async {
        do {
            categories = try await fetchCategoriesUseCase.execute()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
