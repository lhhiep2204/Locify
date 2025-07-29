//
//  HomeViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import SwiftUI

@Observable
class HomeViewModel {
    var categories: [Category] = []
    var selectedCategory: Category?
    var selectedLocation: Location?
    var showCategorySheet: Bool = false
    var showSearchSheet: Bool = false
    var showSettingsSheet: Bool = false
    var showAlert: Bool = false
    var searchText: String = ""

    private let fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol
    private let fetchLocationsUseCase: FetchLocationsUseCaseProtocol

    init(
        fetchCategoriesUseCase: FetchCategoriesUseCaseProtocol,
        fetchLocationsUseCase: FetchLocationsUseCaseProtocol
    ) {
        self.fetchCategoriesUseCase = fetchCategoriesUseCase
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }

    func loadCategories() async {
        do {
            let categories = try await fetchCategoriesUseCase.execute()
            await MainActor.run {
                self.categories = categories
            }
        } catch {
            await MainActor.run {
                self.showAlert = true
            }
        }
    }
}
