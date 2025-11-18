//
//  Location.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// A domain entity representing a user-saved location, associated with a user and category.
struct Location: Identifiable, Equatable, Hashable {
    let id: UUID
    let categoryId: UUID
    var displayName: String
    var name: String
    var address: String
    var description: String?
    var latitude: Double
    var longitude: Double
    var notes: String?
    var syncStatus: SyncStatus
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        categoryId: UUID,
        displayName: String,
        name: String,
        address: String,
        description: String? = nil,
        latitude: Double,
        longitude: Double,
        notes: String? = nil,
        syncStatus: SyncStatus = .pendingCreate,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.categoryId = categoryId
        self.displayName = displayName
        self.name = name
        self.address = address
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id &&
        lhs.categoryId == rhs.categoryId &&
        lhs.displayName == rhs.displayName &&
        lhs.name == rhs.name &&
        lhs.address == rhs.address &&
        lhs.description == rhs.description &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.notes == rhs.notes &&
        lhs.syncStatus == rhs.syncStatus &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }
}

extension Location {
    var isTemporary: Bool {
        id == Constants.myLocationId || id == Constants.searchedLocationId
    }
}

// swiftlint:disable all
extension Location {
    /// A mock location with real coordinates
    static let mock: Location = .init(
        id: UUID(uuidString: "223e4567-e89b-12d3-a456-426614174000")!,
        categoryId: Category.mock.id,
        displayName: "Shake Shack",
        name: "Shake Shack Madison Square Park",
        address: "Madison Ave & E.23rd St, New York, NY 10010",
        description: "Famous for burgers and shakes",
        latitude: 40.741563,
        longitude: -73.988243,
        notes: "Try the ShackBurger with cheese fries",
        createdAt: Date(timeIntervalSince1970: 1697059200),
        updatedAt: Date(timeIntervalSince1970: 1697059200)
    )

    /// A list of mock locations with real coordinates (Apple Maps compatible), aligned with categories.
    static let mockList: [Location] = {
        let realLocations: [[(displayName: String?, name: String, address: String, description: String?, lat: Double, lon: Double, notes: String?)]] = [
            // Food
            [
                ("Shake Shack", "Shake Shack Madison Square Park", "Madison Ave & E.23rd St, New York, NY 10010", "Famous for burgers and shakes", 40.741563, -73.988243, "Try the ShackBurger"),
                (nil, "Joe's Pizza", "7 Carmine St, New York, NY 10014", "Classic NY pizza", 40.730599, -74.002791, nil),
                ("Din Tai Fung Arcadia", "Din Tai Fung", "400 S Baldwin Ave, Arcadia, CA 91007", "Renowned for xiao long bao", 34.144058, -118.050457, "Must-try soup dumplings"),
                (nil, "Ichiran Ramen", "374 Johnson Ave, Brooklyn, NY 11206", "Authentic Japanese ramen", 40.705077, -73.933747, nil),
                ("Boudin Fisherman's Wharf", "Boudin Bakery", "160 Jefferson St, San Francisco, CA 94133", "Famous for sourdough bread", 37.806053, -122.417743, "Get a clam chowder bread bowl")
            ],
            // Shopping
            [
                ("Apple Fifth Ave", "Apple Store Fifth Avenue", "767 5th Ave, New York, NY 10153", "Iconic Apple flagship store", 40.763641, -73.972969, "Check out the latest iPhone"),
                (nil, "The Grove", "189 The Grove Dr, Los Angeles, CA 90036", "Outdoor shopping and dining", 34.071921, -118.357059, nil),
                ("Magnolia Bleecker", "Magnolia Bakery", "401 Bleecker St, New York, NY 10014", "Famous for cupcakes", 40.735565, -74.004831, "Try the banana pudding"),
                (nil, "Harrods", "87-135 Brompton Rd, London SW1X 7XL, UK", "Luxury department store", 51.499405, -0.163108, nil),
                (nil, "Galeries Lafayette", "40 Bd Haussmann, 75009 Paris, France", "High-end shopping in Paris", 48.872047, 2.332111, "Visit the rooftop terrace")
            ],
            // Travel
            [
                (nil, "Eiffel Tower", "Champ de Mars, 5 Av. Anatole France, 75007 Paris, France", "Iconic Parisian landmark", 48.858373, 2.292292, "Evening light show is a must"),
                (nil, "Golden Gate Bridge", "Golden Gate Bridge, San Francisco, CA", "Famous suspension bridge", 37.819929, -122.478255, nil),
                (nil, "Sydney Opera House", "Bennelong Point, Sydney NSW 2000, Australia", "Iconic performing arts center", -33.856784, 151.215297, "Book a guided tour"),
                (nil, "Big Ben", "London SW1A 0AA, UK", "Historic clock tower", 51.500729, -0.124625, nil),
                (nil, "Colosseum", "Piazza del Colosseo, 1, 00184 Roma RM, Italy", "Ancient Roman amphitheater", 41.890210, 12.492231, "Explore the underground chambers")
            ],
            // Work
            [
                (nil, "Empire State Building", "20 W 34th St, New York, NY 10001", "Iconic skyscraper with offices", 40.748817, -73.985428, "Visit the observation deck"),
                (nil, "Salesforce Tower", "415 Mission St, San Francisco, CA 94105", "Modern corporate headquarters", 37.789654, -122.396439, nil),
                (nil, "Shinjuku Mitsui Building", "2 Chome-1-1 Nishi-Shinjuku, Tokyo 163-0435, Japan", "Prominent office tower", 35.692185, 139.695021, nil),
                (nil, "The Shard", "32 London Bridge St, London SE1 9SG, UK", "Modern office and viewing platform", 51.504500, -0.086500, "Check out the view from the top"),
                (nil, "Marina Bay Sands", "10 Bayfront Ave, Singapore 018956", "Business and hotel complex", 1.283964, 103.860527, nil)
            ]
        ]
        let categories = Category.mockList
        var locations: [Location] = []
        for (catIdx, category) in categories.enumerated() {
            let places = realLocations[safe: catIdx] ?? []
            for place in places {
                locations.append(
                    Location(
                        id: UUID(),
                        categoryId: category.id,
                        displayName: place.displayName ?? place.name,
                        name: place.name,
                        address: place.address,
                        description: place.description,
                        latitude: place.lat,
                        longitude: place.lon,
                        notes: place.notes,
                        syncStatus: .synced,
                        createdAt: category.createdAt,
                        updatedAt: category.updatedAt
                    )
                )
            }
        }
        return locations
    }()
}
// swiftlint:enable all
