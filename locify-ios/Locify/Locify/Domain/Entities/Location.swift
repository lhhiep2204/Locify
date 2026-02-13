//
//  Location.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// A domain entity representing a user-saved location, associated with a user and collection.
struct Location: Identifiable, Equatable, Hashable {
    let id: UUID
    var collectionId: UUID
    var placeId: String?
    var name: String
    var displayName: String
    var address: String
    var latitude: Double
    var longitude: Double
    var category: String?
    var notes: String?
    var imageUrls: [String]?
    var tags: [String]?
    var isFavorite: Bool
    var visibility: Visibility
    var share: Share?
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        collectionId: UUID,
        placeId: String? = nil,
        name: String,
        displayName: String,
        address: String,
        latitude: Double,
        longitude: Double,
        category: String? = nil,
        notes: String? = nil,
        imageUrls: [String]? = nil,
        tags: [String]? = nil,
        isFavorite: Bool = false,
        visibility: Visibility = .private,
        share: Share? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.collectionId = collectionId
        self.placeId = placeId
        self.name = name
        self.displayName = displayName
        self.address = address
        self.latitude = latitude.rounded(toDecimalPlaces: 8)
        self.longitude = longitude.rounded(toDecimalPlaces: 8)
        self.category = category
        self.notes = notes
        self.imageUrls = imageUrls
        self.tags = tags
        self.isFavorite = isFavorite
        self.visibility = visibility
        self.share = share
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Location {
    var isTemporary: Bool {
        id == Constants.myLocationId || id == Constants.searchedLocationId || id == Constants.mapSelectionId
    }
}

// swiftlint:disable all
extension Location {
    /// A mock location with real coordinates
    static let mock: Location = .init(
        id: UUID(uuidString: "223e4567-e89b-12d3-a456-426614174000")!,
        collectionId: Collection.mock.id,
        placeId: .empty,
        name: "Shake Shack Madison Square Park",
        displayName: "Shake Shack",
        address: "Madison Ave & E.23rd St, New York, NY 10010",
        latitude: 40.741563,
        longitude: -73.988243,
        notes: "Try the ShackBurger with cheese fries",
        createdAt: Date(timeIntervalSince1970: 1697059200),
        updatedAt: Date(timeIntervalSince1970: 1697059200)
    )

    /// A list of mock locations with real coordinates (Apple Maps compatible), aligned with collections.
    static let mockList: [Location] = {
        let realLocations: [[(name: String, displayName: String?, address: String, lat: Double, lon: Double, notes: String?)]] = [
            // Football Stadium
            [
                ("Stamford Bridge", "Chelsea FC – Stamford Bridge", "Fulham Rd, London SW6 1HS, United Kingdom", 51.481664, -0.191033, "Tour the museum and stadium"),
                ("Emirates Stadium", "Arsenal – Emirates Stadium", "Hornsey Rd, London N7 7AJ, United Kingdom", 51.555924, -0.108422, "Book the Emirates Stadium Tour"),
                ("Santiago Bernabéu Stadium", "Real Madrid – Santiago Bernabéu", "Av. de Concha Espina, 1, 28036 Madrid, Spain", 40.453054, -3.688344, "Newly renovated; check tour availability"),
                ("Spotify Camp Nou", "FC Barcelona – Spotify Camp Nou", "Carrer d'Arístides Maillol, 12, 08028 Barcelona, Spain", 41.380898, 2.122820, "Barça Museum is a highlight"),
                ("Allianz Arena", "FC Bayern – Allianz Arena", "Werner-Heisenberg-Allee 25, 80939 München, Germany", 48.218800, 11.624707, "Illuminated exterior looks best at night")
            ],
            // Food
            [
                ("Shake Shack – Madison Square Park", "Shake Shack", "Madison Ave & E 23rd St, New York, NY 10010, United States", 40.741563, -73.988243, "Try the ShackBurger"),
                ("Joe's Pizza", nil, "7 Carmine St, New York, NY 10014, United States", 40.730599, -74.002791, nil),
                ("Din Tai Fung", "Din Tai Fung – Arcadia", "400 S Baldwin Ave, Arcadia, CA 91007, United States", 34.144058, -118.050457, "Must-try soup dumplings"),
                ("ICHIRAN Ramen – Brooklyn", nil, "374 Johnson Ave, Brooklyn, NY 11206, United States", 40.705077, -73.933747, nil),
                ("Boudin Bakery", "Boudin Bakery – Fisherman's Wharf", "160 Jefferson St, San Francisco, CA 94133, United States", 37.806053, -122.417743, "Get a clam chowder bread bowl")
            ],
            // Shopping
            [
                ("Apple Fifth Avenue", "Apple Fifth Avenue", "767 5th Ave, New York, NY 10153, United States", 40.763641, -73.972969, "Check out the latest iPhone"),
                ("The Grove", nil, "189 The Grove Dr, Los Angeles, CA 90036, United States", 34.071921, -118.357059, nil),
                ("Magnolia Bakery", "Magnolia Bakery – Bleecker St", "401 Bleecker St, New York, NY 10014, United States", 40.735565, -74.004831, "Try the banana pudding"),
                ("Harrods", nil, "87-135 Brompton Rd, London SW1X 7XL, United Kingdom", 51.499405, -0.163108, nil),
                ("Galeries Lafayette Haussmann", nil, "40 Bd Haussmann, 75009 Paris, France", 48.872047, 2.332111, "Visit the rooftop terrace")
            ],
            // Travel
            [
                ("Eiffel Tower", nil, "Champ de Mars, 5 Av. Anatole France, 75007 Paris, France", 48.858373, 2.292292, "Evening light show is a must"),
                ("Golden Gate Bridge", nil, "Golden Gate Bridge, San Francisco, CA, United States", 37.819929, -122.478255, nil),
                ("Sydney Opera House", nil, "Bennelong Point, Sydney NSW 2000, Australia", -33.856784, 151.215297, "Book a guided tour"),
                ("Big Ben", nil, "Westminster, London SW1A 0AA, United Kingdom", 51.500729, -0.124625, nil),
                ("Colosseum", nil, "Piazza del Colosseo, 1, 00184 Roma RM, Italy", 41.890210, 12.492231, "Explore the underground chambers")
            ],
            // Work
            [
                ("Empire State Building", nil, "20 W 34th St, New York, NY 10001, United States", 40.748817, -73.985428, "Visit the observation deck"),
                ("Salesforce Tower", nil, "415 Mission St, San Francisco, CA 94105, United States", 37.789654, -122.396439, nil),
                ("Shinjuku Mitsui Building", nil, "2 Chome-1-1 Nishi-Shinjuku, Shinjuku City, Tokyo 163-0435, Japan", 35.692185, 139.695021, nil),
                ("The Shard", nil, "32 London Bridge St, London SE1 9SG, United Kingdom", 51.504500, -0.086500, "Check out the view from the top"),
                ("Marina Bay Sands", nil, "10 Bayfront Ave, Singapore 018956", 1.283964, 103.860527, nil)
            ]
        ]
        let collections = Collection.mockList
        var locations: [Location] = []
        for (catIdx, collection) in collections.enumerated() {
            let places = realLocations[safe: catIdx] ?? []
            for place in places {
                locations.append(
                    Location(
                        id: UUID(),
                        collectionId: collection.id,
                        placeId: .empty,
                        name: place.name,
                        displayName: place.displayName ?? place.name,
                        address: place.address,
                        latitude: place.lat,
                        longitude: place.lon,
                        notes: place.notes,
                        createdAt: collection.createdAt,
                        updatedAt: collection.updatedAt
                    )
                )
            }
        }
        return locations
    }()
}
// swiftlint:enable all
