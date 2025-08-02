//
//  HomeViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

@Observable
class HomeViewModel {
    var categories: [Category] = []
    var locations: [Location] = []
    var selectedCategory: Category?
    var selectedLocation: Location?

    var relatedLocations: [Location] {
        guard let selectedLocation else { return [] }
        return locations.filter { $0.id != selectedLocation.id }
    }

    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    private let fetchLocationsUseCase: FetchLocationsUseCaseProtocol

    init(
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol,
        fetchLocationsUseCase: FetchLocationsUseCaseProtocol
    ) {
        self.selectedCategory = Category.mockList.first

        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }
}

extension HomeViewModel {
    func fetchCategories() async {
        do {
            categories = try await fetchCategoriesUseCase.execute()
        } catch {
            Logger.error(error.localizedDescription)
        }
    }

    func fetchLocations() async {
        do {
            locations = try await fetchLocationsUseCase.execute()
            selectedLocation = locations.first
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
