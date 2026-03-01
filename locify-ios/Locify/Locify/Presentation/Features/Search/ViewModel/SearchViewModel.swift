//
//  SearchViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 28/2/26.
//

import Foundation

@MainActor
@Observable
class SearchViewModel {
    private(set) var searchResults: [Location] = []
    private let mapService: AppleMapServiceProtocol

    init(mapService: AppleMapServiceProtocol) {
        self.mapService = mapService
    }

    func search(query: String) async {
        searchResults = await mapService.suggestions(for: query)
    }

    func selectLocation(_ location: Location) async -> Location? {
        await mapService.search(for: location)
    }
}
