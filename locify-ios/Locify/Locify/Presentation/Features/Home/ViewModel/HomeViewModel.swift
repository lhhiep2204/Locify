//
//  HomeViewModel.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

@Observable
class HomeViewModel {
    var selectedLocationId: UUID?
    var locations: [Location] = []

    var selectedLocation: Location? {
        guard let selectedLocationId else { return nil }
        return locations.first(where: { $0.id == selectedLocationId })
    }

    var relatedLocations: [Location] {
        guard let selectedLocationId else { return [] }
        return locations.filter { $0.id != selectedLocationId }
    }
}
