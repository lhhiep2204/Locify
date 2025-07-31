//
//  MKCoordinateRegion.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 31/7/25.
//

import MapKit

extension MKCoordinateRegion {
    /// Calculate a dynamic map region for a single location
    /// based on its address depth (number of components)
    static func region(for location: Location) -> MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude,
            longitude: location.longitude
        )
        let span = calculateMapRegionSpan(for: location)

        return .init(center: coordinate, span: span)
    }

    /// Compute a dynamic span based on address components
    static func calculateMapRegionSpan(for location: Location) -> MKCoordinateSpan {
        // Safely split the address into components
        let addressParts = location.address
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        let count = addressParts.count
        let spanValue: Double

        switch count {
        case 0...2:   // Country or large area → zoom out
            spanValue = 0.1
        case 3...4:   // City or neighborhood → medium zoom
            spanValue = 0.01
        default:      // Street / building → zoom in
            spanValue = 0.005
        }

        return .init(latitudeDelta: spanValue, longitudeDelta: spanValue)
    }
}
