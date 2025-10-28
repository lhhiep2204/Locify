//
//  EditLocationViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 24/8/25.
//

import Foundation

@MainActor
@Observable
class EditLocationViewModel {
    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    private let addCategoryUseCase: AddCategoryUseCaseProtocol

    private(set) var categories: [Category] = []

    var category: Category?

    var displayName: String = .empty
    var name: String = .empty
    var address: String = .empty
    var latitude: String = .empty
    var longitude: String = .empty
    var notes: String = .empty

    private(set) var errorMessage: String = .empty

    init(
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol,
        addCategoryUseCase: AddCategoryUseCaseProtocol
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.addCategoryUseCase = addCategoryUseCase
    }
}

extension EditLocationViewModel {
    func fetchCategories() async {
        do {
            try await Task.sleep(for: .seconds(0.5))
            categories = try await fetchCategoriesUseCase.execute()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func addCategory(_ category: Category) async {
        do {
            _ = try await addCategoryUseCase.execute(category)
            categories.append(category)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func createLocation(locationToUpdate: Location?, completion: (Location?) -> Void) {
        var location: Location {
            if let locationToUpdate {
                var location = locationToUpdate
                location.displayName = displayName
                location.name = name
                location.address = address
                location.latitude = latitude.asDouble
                location.longitude = longitude.asDouble
                location.notes = notes.trimmed.isEmpty ? nil : notes
                return location
            } else {
                let location = Location(
                    categoryId: category?.id ?? UUID(),
                    displayName: displayName,
                    name: name,
                    address: address,
                    latitude: latitude.asDouble,
                    longitude: longitude.asDouble,
                    notes: notes.trimmed.isEmpty ? nil : notes
                )
                return location
            }
        }

        guard isValid else {
            completion(nil)
            return
        }

        completion(location)
    }

    func clearErrorState() {
        errorMessage = .empty
    }
}

extension EditLocationViewModel {
    private var isValid: Bool {
        if category == nil {
            errorMessage = "Please select a category."
            return false
        }

        if address.trimmed.isEmpty {
            errorMessage = "Please select a location."
            return false
        }

        clearErrorState()
        return true
    }
}
