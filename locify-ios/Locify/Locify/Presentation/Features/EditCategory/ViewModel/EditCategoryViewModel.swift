//
//  EditCategoryViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/8/25.
//

import Foundation

@MainActor
@Observable
class EditCategoryViewModel {
    var name: String = .empty
    private(set) var errorMessage: String = .empty
}

extension EditCategoryViewModel {
    func createCategory(
        categoryToUpdate: Category?,
        completion: (Category?) -> Void
    ) {
        var category: Category {
            if let categoryToUpdate {
                var category = categoryToUpdate
                category.name = name
                return category
            } else {
                let category = Category(name: name)
                return category
            }
        }

        guard isValid else {
            completion(nil)
            return
        }

        completion(category)
    }

    func updateCategoryName(_ categoryName: String) {
        name = categoryName
    }

    func clearErrorState() {
        errorMessage = .empty
    }
}

extension EditCategoryViewModel {
    private var isValid: Bool {
        if name.trimmed.isEmpty {
            errorMessage = "Please enter a name."
            return false
        }

        clearErrorState()
        return true
    }
}
