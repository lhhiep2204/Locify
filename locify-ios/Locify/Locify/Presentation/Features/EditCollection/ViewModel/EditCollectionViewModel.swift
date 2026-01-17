//
//  EditCollectionViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 25/8/25.
//

import Foundation

@MainActor
@Observable
class EditCollectionViewModel {
    var name: String = .empty
    private(set) var errorMessage: String = .empty
}

extension EditCollectionViewModel {
    func createCollection(
        collectionToUpdate: Collection?,
        completion: (Collection?) -> Void
    ) {
        var collection: Collection {
            if let collectionToUpdate {
                var collection = collectionToUpdate
                collection.name = name
                return collection
            } else {
                let collection = Collection(name: name)
                return collection
            }
        }

        guard isValid else {
            completion(nil)
            return
        }

        completion(collection)
    }

    func updateCollectionName(_ collectionName: String) {
        name = collectionName
    }

    func clearErrorState() {
        errorMessage = .empty
    }
}

extension EditCollectionViewModel {
    private var isValid: Bool {
        if name.trimmed.isEmpty {
            errorMessage = "Please enter a name."
            return false
        }

        clearErrorState()
        return true
    }
}
