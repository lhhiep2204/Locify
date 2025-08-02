//
//  Location.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 22/7/25.
//

import Foundation

/// A domain entity representing a user-saved location, associated with a user and category.
struct Location: Identifiable, Equatable, Hashable {
    /// Unique identifier for the location.
    let id: UUID
    /// Identifier of the user who owns this location.
    let userId: String
    /// Identifier of the category this location belongs to.
    let categoryId: UUID
    /// Name of the location.
    let name: String
    /// Address of the location.
    let address: String
    /// Optional description of the location.
    let description: String?
    /// Latitude coordinate.
    let latitude: Double
    /// Longitude coordinate.
    let longitude: Double
    /// Whether the location is marked as a favorite.
    let isFavorite: Bool
    /// Array of image URLs for the location.
    let imageUrls: [String]
    /// Synchronization status with the server.
    let syncStatus: SyncStatus
    /// Creation timestamp.
    let createdAt: Date
    /// Last update timestamp.
    let updatedAt: Date

    /// Initializes a Location with default or provided values.
    /// - Parameters:
    ///   - id: Unique identifier (defaults to new UUID).
    ///   - userId: User identifier (required).
    ///   - categoryId: Category identifier (required).
    ///   - name: Location name (required).
    ///   - address: Location address (required).
    ///   - description: Optional description.
    ///   - latitude: Latitude coordinate (required).
    ///   - longitude: Longitude coordinate (required).
    ///   - isFavorite: Favorite status (defaults to false).
    ///   - imageUrls: Array of image URLs (defaults to empty).
    ///   - syncStatus: Synchronization status (defaults to `.pendingCreate`).
    ///   - createdAt: Creation timestamp (defaults to current date).
    ///   - updatedAt: Last update timestamp (defaults to current date).
    init(
        id: UUID = UUID(),
        userId: String,
        categoryId: UUID,
        name: String,
        address: String,
        description: String? = nil,
        latitude: Double,
        longitude: Double,
        isFavorite: Bool = false,
        imageUrls: [String] = [],
        syncStatus: SyncStatus = .pendingCreate,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.categoryId = categoryId
        self.name = name
        self.address = address
        self.description = description
        self.latitude = latitude
        self.longitude = longitude
        self.isFavorite = isFavorite
        self.imageUrls = imageUrls
        self.syncStatus = syncStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Compares two Location instances for equality.
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id &&
        lhs.userId == rhs.userId &&
        lhs.categoryId == rhs.categoryId &&
        lhs.name == rhs.name &&
        lhs.address == rhs.address &&
        lhs.description == rhs.description &&
        lhs.latitude == rhs.latitude &&
        lhs.longitude == rhs.longitude &&
        lhs.isFavorite == rhs.isFavorite &&
        lhs.imageUrls == rhs.imageUrls &&
        lhs.syncStatus == rhs.syncStatus &&
        lhs.createdAt == rhs.createdAt &&
        lhs.updatedAt == rhs.updatedAt
    }
}

// swiftlint:disable all
extension Location {
    /// A list of mock locations with real coordinates (Apple Maps compatible), 5 per category.
    static let mockList: [Location] = {
        let realLocations: [[(name: String, address: String, lat: Double, lon: Double)]] = [
            // Food
            [
                ("Shake Shack Madison Square Park", "Madison Ave & E.23rd St, New York, NY 10010", 40.741563, -73.988243),
                ("Joe's Pizza", "7 Carmine St, New York, NY 10014", 40.730599, -74.002791),
                ("Din Tai Fung", "400 S Baldwin Ave, Arcadia, CA 91007", 34.144058, -118.050457),
                ("Ichiran Ramen", "374 Johnson Ave, Brooklyn, NY 11206", 40.705077, -73.933747),
                ("Boudin Bakery", "160 Jefferson St, San Francisco, CA 94133", 37.806053, -122.417743),
                ("Pizzeria Bianco", "623 E Adams St, Phoenix, AZ 85004", 33.449347, -112.066153)
            ],
            // Shopping
            [
                ("Apple Store Fifth Avenue", "767 5th Ave, New York, NY 10153", 40.763641, -73.972969),
                ("The Grove", "189 The Grove Dr, Los Angeles, CA 90036", 34.071921, -118.357059),
                ("Magnolia Bakery", "401 Bleecker St, New York, NY 10014", 40.735565, -74.004831),
                ("Harrods", "87-135 Brompton Rd, London SW1X 7XL, UK", 51.499405, -0.163108),
                ("Galeries Lafayette", "40 Bd Haussmann, 75009 Paris, France", 48.872047, 2.332111),
                ("Isetan Shinjuku", "3 Chome-14-1 Shinjuku, Tokyo 160-0022, Japan", 35.693793, 139.703478)
            ],
            // Travel
            [
                ("Eiffel Tower", "Champ de Mars, 5 Av. Anatole France, 75007 Paris, France", 48.858373, 2.292292),
                ("Golden Gate Bridge", "Golden Gate Bridge, San Francisco, CA", 37.819929, -122.478255),
                ("Sydney Opera House", "Bennelong Point, Sydney NSW 2000, Australia", -33.856784, 151.215297),
                ("Big Ben", "London SW1A 0AA, UK", 51.500729, -0.124625),
                ("Great Wall at Mutianyu", "Huairou, China", 40.431908, 116.570374),
                ("Colosseum", "Piazza del Colosseo, 1, 00184 Roma RM, Italy", 41.890210, 12.492231)
            ],
            // Work
            [
                ("Empire State Building", "20 W 34th St, New York, NY 10001", 40.748817, -73.985428),
                ("Salesforce Tower", "415 Mission St, San Francisco, CA 94105", 37.789654, -122.396439),
                ("Shinjuku Mitsui Building", "2 Chome-1-1 Nishi-Shinjuku, Tokyo 163-0435, Japan", 35.692185, 139.695021),
                ("The Shard", "32 London Bridge St, London SE1 9SG, UK", 51.504500, -0.086500),
                ("Marina Bay Sands", "10 Bayfront Ave, Singapore 018956", 1.283964, 103.860527),
                ("Petronas Towers", "Kuala Lumpur City Centre, 50088 Kuala Lumpur, Malaysia", 3.157856, 101.711430)
            ]
        ]
        let categories = Category.mockList
        var locations: [Location] = []
        for (catIdx, category) in categories.enumerated() {
            let places = realLocations[safe: catIdx] ?? []
            for i in 0..<6 {
                let place = places[i]
                locations.append(
                    Location(
                        userId: category.userId,
                        categoryId: category.id,
                        name: place.name,
                        address: place.address,
                        description: "Sample description for \(place.name)",
                        latitude: place.lat,
                        longitude: place.lon,
                        isFavorite: i == 0,
                        imageUrls: [],
                        syncStatus: .pendingCreate
                    )
                )
            }
        }
        return locations
    }()
}
// swiftlint:enable all
