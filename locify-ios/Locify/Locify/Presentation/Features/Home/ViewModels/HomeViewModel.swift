//
//  HomeViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

@Observable
class HomeViewModel {
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
    func fetchLocations() async {
        guard let selectedCategory else { return }

        do {
            locations = try await fetchLocationsUseCase.execute(for: selectedCategory)
            selectedLocation = locations.first
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
