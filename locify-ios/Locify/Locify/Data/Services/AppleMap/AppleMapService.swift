//
//  AppleMapService.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/9/25.
//

@preconcurrency import MapKit

final class AppleMapService {
    /// Reverse-geocodes the given Core Location coordinate into a `Location` value.
    ///
    /// This method performs an async reverse-geocoding request using MapKit and maps the
    /// first resulting `MKMapItem` into your app's `Location` model. If no address can be
    /// resolved, it throws a `LocationError.geocodingFailed` with a descriptive message.
    ///
    /// - Parameter location: The `CLLocation` to reverse-geocode.
    /// - Returns: A populated `Location` describing the provided coordinates.
    /// - Throws: `LocationError.geocodingFailed` if no address is found or address data is invalid.
    func getLocationInfo(for location: CLLocation) async throws -> Location {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw LocationError.geocodingFailed("No address found.")
        }

        let mapItems = try await request.mapItems

        guard let item = mapItems.first else {
            throw LocationError.geocodingFailed("No address found.")
        }

        guard let address = item.address?.fullAddress else {
            throw LocationError.geocodingFailed("Invalid address data.")
        }

        let name = item.name ?? "My location"

        return .init(
            id: Constants.myLocationId,
            categoryId: UUID(),
            displayName: "My location",
            name: name,
            address: address,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
