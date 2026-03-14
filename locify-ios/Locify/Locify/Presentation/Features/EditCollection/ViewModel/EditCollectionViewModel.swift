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
    enum Mode {
        case create
        case update(Collection)
    }

    let mode: Mode

    private(set) var errorMessage: String = .empty

    var name: String = .empty

    init(mode: Mode) {
        self.mode = mode

        if case let .update(collection) = mode {
            name = collection.name
        }
    }
}

extension EditCollectionViewModel {
    func save(completion: (Collection?) -> Void) {
        guard isValid else {
            completion(nil)
            return
        }

        switch mode {
        case .create:
            let new = Collection(name: name.trimmed)
            completion(new)
        case .update(let existing):
            var updated = existing
            updated.name = name.trimmed
            completion(updated)
        }
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
