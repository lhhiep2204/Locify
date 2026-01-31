//
//  Location+Extensions.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 10/1/26.
//

extension Location {
    var shareMessage: String {
        var lines: [String] = []

        if !displayName.trimmed.isEmpty {
            lines.append("Title: \(displayName)")
        }

        lines.append("Name: \(name)")
        lines.append("Address: \(address)")
        lines.append("Coordinates: \(latitude), \(longitude)")

        if let notes, !notes.trimmed.isEmpty {
            lines.append("Notes: \(notes)")
        }

        lines.append("View in Apple Maps: \(appleMapsURL)")

        return lines.joined(separator: "\n")
    }

    var appleMapsURL: String {
        let encodedName = name.urlEncoded
        let encodedAddress = address.urlEncoded

        var parts: [String] = []

        if let placeId, !placeId.isEmpty {
            parts.append("place-id=\(placeId)")
        }

        parts.append("address=\(encodedAddress)")
        parts.append("coordinate=\(latitude),\(longitude)")
        parts.append("q=\(encodedName)")

        let query = parts.joined(separator: "&")

        return "http://maps.apple.com/place?\(query.trimmed)"
    }
}
