//
//  RouteInfo.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 13/3/26.
//

import Foundation

struct RouteInfo {
    /// Transport mode used to compute this route.
    let transportType: TransportType

    /// Total route distance in meters.
    let distance: Double

    /// Expected travel time in seconds.
    let expectedTravelTime: TimeInterval
}
