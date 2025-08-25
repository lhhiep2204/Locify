//
//  EditCategoryViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/8/25.
//

import Foundation

@Observable
class EditCategoryViewModel {
    var name: String = .empty

    var errorMessage: String?
}

extension EditCategoryViewModel {
    func createCategory(categoryToUpdate: Category?, completion: (Category) -> Void) {
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

        guard isValid else { return }

        completion(category)
    }
}

extension EditCategoryViewModel {
    private var isValid: Bool {
        if name.isEmpty {
            errorMessage = "Please enter a name."
            return false
        }

        errorMessage = nil
        return true
    }
}
