//
//  MKCoordinateRegion.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 31/7/25.
//

import MapKit

extension MKCoordinateRegion {
    /// Calculate a dynamic map region for a single location based on its address depth (number of components)
    static func region(for location: Location) -> MKCoordinateRegion {
        // Clamp latitude to [-90, 90] and longitude to [-180, 180], ignoring NaN/infinite
        let lat = location.latitude.isFinite ? min(max(location.latitude, -90), 90) : 0
        let lon = location.longitude.isFinite ? min(max(location.longitude, -180), 180) : 0

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
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

        let spanValue: Double = {
            switch count {
            case 0...2: 0.1 // Country or large area → zoom out
            case 3...4: 0.01 // City or neighborhood → medium zoom
            default: 0.005 // Street / building → zoom in
            }
        }()

        return .init(latitudeDelta: spanValue, longitudeDelta: spanValue)
    }
}
