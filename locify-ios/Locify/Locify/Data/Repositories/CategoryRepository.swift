//
//  CategoryRepository.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/7/25.
//

import Foundation

final class CategoryRepository: CategoryRepositoryProtocol {
    func fetchCategories() async throws -> [Category] {
        Category.mockList
    }

    func addCategory(_ category: Category) async throws -> Category {
        category
    }

    func updateCategory(_ category: Category) async throws -> Category {
        category
    }

    func deleteCategory(_ category: Category) async throws -> Category {
        category
    }
}
