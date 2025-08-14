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

    private let categoryUseCases: CategoryUseCases

    init(
        categoryUseCases: CategoryUseCases
    ) {
        self.categoryUseCases = categoryUseCases
    }
}

extension CategoryListViewModel {
    func fetchCategories() async {
        do {
            categories = try await categoryUseCases.fetch.execute()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func addCategory(_ category: Category) async {
        do {
            _ = try await categoryUseCases.add.execute(category)
            categories.append(category)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func updateCategory(_ category: Category) async {
        guard let index = categories.firstIndex(where: { $0.id == category.id }),
              categories[index] != category else { return }

        do {
            _ = try await categoryUseCases.update.execute(category)
            categories[index] = category
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func deleteCategory(_ category: Category) async {
        do {
            _ = try await categoryUseCases.delete.execute(category)
            categories.removeAll { $0.id == category.id }
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
