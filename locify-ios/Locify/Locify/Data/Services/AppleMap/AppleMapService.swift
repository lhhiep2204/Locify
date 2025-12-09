//
//  AppleMapService.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 20/9/25.
//

import Combine
@preconcurrency import MapKit

/// Protocol defining the interface for map and location-related services,
/// such as reverse geocoding, place search, and autocomplete suggestions.
protocol AppleMapServiceProtocol: AnyObject {
    /// Reverse-geocodes the given Core Location coordinate into a `Location` value.
    /// - Parameter location: The `CLLocation` to reverse-geocode.
    /// - Returns: A populated `Location` describing the provided coordinates.
    /// - Throws: `LocationError.geocodingFailed` if no address is found or data is invalid.
    func getLocationInfo(for location: CLLocation) async throws -> Location

    /// Returns debounced autocomplete suggestions for a user-entered query.
    /// - Parameter query: The text to search for.
    /// - Returns: A list of `Location` suggestions (coordinates are zero for suggestions).
    func suggestions(for query: String) async -> [Location]

    /// Performs a detailed place search to resolve a suggested location to a precise coordinate.
    /// - Parameter location: A `Location` previously returned from `suggestions(for:)`.
    /// - Returns: A more precise `Location` with coordinates, or `nil` if none found.
    func search(for location: Location) async -> Location?
}

@MainActor
final class AppleMapService: NSObject, AppleMapServiceProtocol {
    static let shared = AppleMapService()

    private let completer: MKLocalSearchCompleter
    private var search: MKLocalSearch?
    private var completionByLocationID: [String: MKLocalSearchCompletion] = [:]

    private let querySubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var suggestions: CheckedContinuation<[Location], Never>?

    var locationId = [String]()

    override init() {
        completer = MKLocalSearchCompleter()
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .physicalFeature]

        querySubject
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self else { return }
                completer.queryFragment = text
            }
            .store(in: &cancellables)
    }
}

extension AppleMapService {
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
            placeId: item.identifier?.rawValue,
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

extension AppleMapService {
    /// Returns debounced autocomplete suggestions for a natural-language query.
    ///
    /// This function routes the query through a Combine-based debounce pipeline to
    /// avoid spamming MapKit as the user types. It then awaits the next results from
    /// `MKLocalSearchCompleter` and maps them to your `Location` model.
    /// - Parameter query: The user-entered search text.
    /// - Returns: A list of `Location` suggestions (coordinates are zero for suggestions).
    func suggestions(for query: String) async -> [Location] {
        suggestions?.resume(returning: [])
        suggestions = nil

        querySubject.send(query)

        return await withCheckedContinuation { (continuation: CheckedContinuation<[Location], Never>) in
            suggestions = continuation
        }
    }

    /// Resolves a previously suggested `Location` into a precise place using `MKLocalSearch`.
    ///
    /// If the `Location` originated from this service's suggestions, the underlying
    /// `MKLocalSearchCompletion` is used for improved accuracy. The first matching
    /// map item is returned as a `Location` with coordinates.
    /// - Parameter location: A suggestion `Location` previously returned by this service.
    /// - Returns: The first resolved `Location` with coordinates, or `nil` if none found.
    func search(for location: Location) async -> Location? {
        do {
            guard let completion = completionByLocationID[location.id.uuidString] else {
                return nil
            }

            let request = MKLocalSearch.Request(completion: completion)
            let search = MKLocalSearch(request: request)
            let response = try await search.start()

            return response.mapItems.first.map {
                .init(
                    id: Constants.searchedLocationId,
                    categoryId: UUID(),
                    placeId: $0.identifier?.rawValue,
                    displayName: .empty,
                    name: $0.name ?? .empty,
                    address: $0.addressRepresentations?.fullAddress(includingRegion: true, singleLine: true) ?? .empty,
                    latitude: $0.location.coordinate.latitude,
                    longitude: $0.location.coordinate.longitude
                )
            }
        } catch {
            Logger.error(error.localizedDescription)
            return nil
        }
    }
}

extension AppleMapService: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        var locations = [Location]()
        completionByLocationID = [:]
        locationId = []

        for completion in completer.results {
            let id = UUID()

            locations.append(
                .init(
                    id: id,
                    categoryId: UUID(),
                    displayName: .empty,
                    name: completion.title,
                    address: completion.subtitle,
                    latitude: .zero,
                    longitude: .zero
                )
            )
            locationId.append(id.uuidString)
            completionByLocationID[id.uuidString] = completion
        }

        if let continuation = suggestions {
            suggestions = nil
            continuation.resume(returning: locations)
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        if let continuation = suggestions {
            suggestions = nil
            continuation.resume(returning: [])
        }
    }
}
