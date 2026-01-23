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
        let coordinate = CLLocationCoordinate2D(
            latitude: location.latitude.clamped(to: -90...90),
            longitude: location.longitude.clamped(to: -180...180)
        )

        let zoomLevel = MapZoomLevel.from(addressDepth: location.addressComponents.count)
        let span = MKCoordinateSpan(
            latitudeDelta: zoomLevel.span,
            longitudeDelta: zoomLevel.span
        )

        return .init(center: coordinate, span: span)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        guard isFinite else { return range.lowerBound }

        return min(max(self, range.lowerBound), range.upperBound)
    }
}

private extension Location {
    var addressComponents: [String] {
        address
            .components(separatedBy: CharacterSet(charactersIn: "\n,"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
}

private enum MapZoomLevel {
    case country, state, city, district, place

    /// Latitude / longitude delta (degrees). Chosen empirically for acceptable UX, not geographic precision.
    var span: Double {
        switch self {
        case .country: 8.0 // ~900km
        case .state: 2.0 // ~200km
        case .city: 0.3 // ~30km
        case .district: 0.05 // ~5km
        case .place: 0.003 // ~300m
        }
    }

    /// Heuristic mapping from address depth. Address depth is locale & format dependent.
    static func from(addressDepth: Int) -> MapZoomLevel {
        switch addressDepth {
        case 0, 1: .country
        case 2: .state
        case 3: .city
        case 4: .district
        default: .place
        }
    }
}
