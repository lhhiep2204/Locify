//
//  TransportType.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/3/26.
//

import MapKit

enum TransportType {
    case automobile
    case walking
    case transit
    case auto

    var mkTransportType: MKDirectionsTransportType {
        switch self {
        case .auto, .automobile: .automobile
        case .walking: .walking
        case .transit: .transit
        }
    }

    var systemImageName: String {
        switch self {
        case .auto, .automobile: "car"
        case .walking: "figure.walk"
        case .transit: "tram"
        }
    }

    /// Infers the most appropriate transport type from a straight-line
    /// distance in meters, mirroring Apple Maps' proximity-based heuristic.
    ///
    /// - `<= 1 km`  → `.walking`
    /// - `> 1 km`   → `.automobile`
    ///
    /// - Parameter straightLineDistance: The direct distance in meters between two points.
    /// - Returns: The suggested `TransportType` for that distance.
    static func suggested(for straightLineDistance: Double) -> TransportType {
        straightLineDistance <= 1000 ? .walking : .automobile
    }
}
