//
//  LocationListViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 3/8/25.
//

import Foundation

@Observable
class LocationListViewModel {
    var locations: [Location] = []

    private let categoryId: UUID
    private let fetchLocationsUseCase: FetchLocationsUseCaseProtocol

    init(
        categoryId: UUID,
        fetchLocationsUseCase: FetchLocationsUseCaseProtocol
    ) {
        self.categoryId = categoryId
        self.fetchLocationsUseCase = fetchLocationsUseCase
    }
}

extension LocationListViewModel {
    func fetchLocations() async {
        do {
            locations = try await fetchLocationsUseCase.execute(for: categoryId)
        } catch {
            Logger.error(error.localizedDescription)
        }
    }
}
