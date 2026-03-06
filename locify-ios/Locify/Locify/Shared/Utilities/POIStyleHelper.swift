//
//  POIStyleHelper.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 1/3/26.
//

import MapKit
import SwiftUI

// MARK: - POIStyleHelper

/// Maps `MKPointOfInterestCategory` to a storage key and resolves its SF Symbol icon and tint color.
enum POIStyleHelper {
    // MARK: - POI Style

    /// The SF Symbol icon name and tint color for a point of interest.
    struct POIStyle {
        let icon: String
        let color: Color
    }

    // MARK: - Encode (Search → Storage)

    /// Strips the `MKPOICategory` prefix from the raw value and lowercases it for storage.
    ///
    /// - Parameter category: The `MKPointOfInterestCategory` from an `MKMapItem` search result.
    /// - Returns: Lowercase category key with `MKPOICategory` prefix removed, or empty string if `nil`.
    static func categoryString(from category: MKPointOfInterestCategory?) -> String {
        guard let rawValue = category?.rawValue else { return .empty }

        return rawValue
            .replacingOccurrences(of: "MKPOICategory", with: "")
            .lowercased()
    }

    // MARK: - Decode (Storage → Display)

    // swiftlint:disable cyclomatic_complexity function_body_length
    /// Resolves the SF Symbol icon and tint color for a stored category string. Returns a default pin style if unknown.
    ///
    /// - Parameter category: A lowercase category string previously encoded by `categoryString(from:)`.
    /// - Returns: A `POIStyle` with SF Symbol name and tint color, or a gray `"mappin"` fallback if unrecognized.
    static func style(for category: String?) -> POIStyle {
        switch category {
        case "animalservice": .init(icon: "pawprint.fill", color: .brown)
        case "airport": .init(icon: "airplane.departure", color: .blue)
        case "amusementpark": .init(icon: "ferriswheel", color: .pink)
        case "aquarium": .init(icon: "fish.fill", color: .cyan)
        case "atm": .init(icon: "banknote.fill", color: .green)
        case "automotiverepair": .init(icon: "wrench.and.screwdriver.fill", color: .gray)
        case "bakery": .init(icon: "birthday.cake.fill", color: .pink)
        case "bank": .init(icon: "building.columns.fill", color: .green)
        case "baseball": .init(icon: "baseball.fill", color: .red)
        case "basketball": .init(icon: "basketball.fill", color: .orange)
        case "beach": .init(icon: "beach.umbrella.fill", color: .cyan)
        case "beauty": .init(icon: "scissors", color: .pink)
        case "bowling": .init(icon: "figure.bowling", color: .blue)
        case "brewery": .init(icon: "mug.fill", color: .brown)
        case "cafe": .init(icon: "cup.and.saucer.fill", color: .brown)
        case "campground": .init(icon: "tent.fill", color: .green)
        case "carrental": .init(icon: "car.fill", color: .blue)
        case "castle": .init(icon: "crown.fill", color: .yellow)
        case "conventioncenter": .init(icon: "building.2.fill", color: .blue)
        case "distillery": .init(icon: "drop.fill", color: .indigo)
        case "evcharger": .init(icon: "bolt.car.fill", color: .green)
        case "fairground": .init(icon: "star.circle.fill", color: .yellow)
        case "firestation": .init(icon: "flame.fill", color: .red)
        case "fishing": .init(icon: "figure.fishing", color: .teal)
        case "fitnesscenter": .init(icon: "dumbbell.fill", color: .orange)
        case "foodmarket": .init(icon: "cart.fill", color: .orange)
        case "fortress": .init(icon: "building.fill", color: .brown)
        case "gasstation": .init(icon: "fuelpump.fill", color: .yellow)
        case "golf": .init(icon: "figure.golf", color: .green)
        case "gokart": .init(icon: "car.fill", color: .red)
        case "hiking": .init(icon: "figure.hiking", color: .green)
        case "hospital": .init(icon: "cross.fill", color: .red)
        case "hotel": .init(icon: "bed.double.fill", color: .indigo)
        case "kayaking": .init(icon: "water.waves", color: .cyan)
        case "landmark": .init(icon: "camera.fill", color: .blue)
        case "laundry": .init(icon: "washer.fill", color: .blue)
        case "library": .init(icon: "books.vertical.fill", color: .brown)
        case "mailbox": .init(icon: "mailbox.fill", color: .blue)
        case "marina": .init(icon: "sailboat.fill", color: .blue)
        case "minigolf": .init(icon: "figure.golf", color: .mint)
        case "movietheater": .init(icon: "film.fill", color: .purple)
        case "museum": .init(icon: "building.columns.fill", color: .purple)
        case "musicvenue": .init(icon: "music.mic", color: .pink)
        case "nationalmonument": .init(icon: "flag.fill", color: .blue)
        case "nationalpark": .init(icon: "mountain.2.fill", color: .green)
        case "nightlife": .init(icon: "party.popper.fill", color: .purple)
        case "park": .init(icon: "tree.fill", color: .green)
        case "parking": .init(icon: "parkingsign", color: .blue)
        case "pharmacy": .init(icon: "pills.fill", color: .red)
        case "planetarium": .init(icon: "moon.stars.fill", color: .indigo)
        case "police": .init(icon: "shield.fill", color: .blue)
        case "postoffice": .init(icon: "envelope.fill", color: .blue)
        case "publictransport": .init(icon: "tram.fill", color: .blue)
        case "restaurant": .init(icon: "fork.knife", color: .orange)
        case "restroom": .init(icon: "toilet.fill", color: .gray)
        case "rockclimbing": .init(icon: "mountain.2.fill", color: .brown)
        case "rvpark": .init(icon: "car.rear.fill", color: .green)
        case "school": .init(icon: "graduationcap.fill", color: .blue)
        case "skatepark": .init(icon: "figure.skating", color: .orange)
        case "skating": .init(icon: "figure.skating", color: .blue)
        case "skiing": .init(icon: "figure.skiing.downhill", color: .cyan)
        case "soccer": .init(icon: "soccerball", color: .green)
        case "spa": .init(icon: "sparkles", color: .pink)
        case "stadium": .init(icon: "sportscourt.fill", color: .green)
        case "store": .init(icon: "bag.fill", color: .teal)
        case "surfing": .init(icon: "water.waves", color: .teal)
        case "swimming": .init(icon: "figure.pool.swim", color: .cyan)
        case "tennis": .init(icon: "figure.tennis", color: .yellow)
        case "theater": .init(icon: "theatermasks.fill", color: .purple)
        case "university": .init(icon: "graduationcap.fill", color: .indigo)
        case "winery": .init(icon: "wineglass.fill", color: .purple)
        case "volleyball": .init(icon: "volleyball.fill", color: .orange)
        case "zoo": .init(icon: "pawprint.fill", color: .brown)
        default: .init(icon: "mappin", color: .gray)
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
