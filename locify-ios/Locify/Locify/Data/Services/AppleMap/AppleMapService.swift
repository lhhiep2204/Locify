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
    /// Reverse-geocodes the user's current Core Location into a `Location` value.
    /// - Parameter location: The user's `CLLocation`.
    /// - Returns: A populated `Location` describing the user's location.
    /// - Throws: `LocationError.geocodingFailed` if no address is found or data is invalid.
    func getUserLocationInfo(for location: CLLocation) async throws -> Location

    /// Reverse-geocodes a coordinate selected directly on the map into a `Location`.
    /// - Parameters:
    ///   - name: An optional display name to prefer over the reverse-geocoded name.
    ///   - coordinate: The coordinate selected on the map.
    /// - Returns: A populated `Location` representing the selected map position.
    /// - Throws: `LocationError.geocodingFailed` if no address is found.
    func getSelectedMapLocationInfo(name: String?, for coordinate: CLLocationCoordinate2D) async throws -> Location

    /// Creates an `MKMapItem` from a domain `Location`.
    /// - Parameter location: The domain `Location` to convert.
    /// - Returns: An `MKMapItem` representing the location.
    func makeMapItem(from location: Location) -> MKMapItem

    /// Returns debounced autocomplete suggestions for a user-entered query.
    func suggestions(for query: String) async -> [Location]

    /// Performs a detailed place search to resolve a suggested location to a precise coordinate.
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
    /// Reverse-geocodes the user's current Core Location into a `Location` value.
    ///
    /// This method resolves the user's physical location into a human-readable
    /// address using MapKit reverse geocoding.
    ///
    /// - Parameter location: The user's `CLLocation`.
    /// - Returns: A populated `Location` representing the user's location.
    /// - Throws: `LocationError.geocodingFailed` if no address is found.
    func getUserLocationInfo(for location: CLLocation) async throws -> Location {
        guard let request = MKReverseGeocodingRequest(location: location),
              let item = try await request.mapItems.first else {
            throw LocationError.geocodingFailed("No address found.")
        }

        return .init(
            id: Constants.myLocationId,
            collectionId: UUID(),
            placeId: item.identifier?.rawValue,
            displayName: "My Location",
            name: item.name ?? "My Location",
            address: item.address?.fullAddress ?? .empty,
            latitude: item.location.coordinate.latitude,
            longitude: item.location.coordinate.longitude
        )
    }

    /// Reverse-geocodes a coordinate selected directly on the map into a `Location`.
    ///
    /// This method is typically used when handling `MapSelection`, where only
    /// a coordinate is available. If a custom `name` is provided, it will be
    /// used in preference to the reverse-geocoded place name.
    ///
    /// - Parameters:
    ///   - name: An optional display name to prefer over the reverse-geocoded name.
    ///   - coordinate: The coordinate selected on the map.
    /// - Returns: A populated `Location` representing the selected map position.
    /// - Throws: `LocationError.geocodingFailed` if no address is found.
    func getSelectedMapLocationInfo(
        name: String?,
        for coordinate: CLLocationCoordinate2D
    ) async throws -> Location {
        let location = CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )

        guard let request = MKReverseGeocodingRequest(location: location),
              let item = try await request.mapItems.first else {
            throw LocationError.geocodingFailed("No address found.")
        }

        return .init(
            id: Constants.mapSelectionId,
            collectionId: UUID(),
            placeId: item.identifier?.rawValue,
            displayName: .empty,
            name: name ?? item.name ?? .empty,
            address: item.address?.fullAddress ?? .empty,
            latitude: item.location.coordinate.latitude,
            longitude: item.location.coordinate.longitude
        )
    }
}

extension AppleMapService {
    /// Creates an `MKMapItem` from a domain `Location`.
    ///
    /// This method converts a saved or temporary `Location` into a MapKit
    /// representation, allowing it to be used for map camera positioning,
    /// routing, or system interactions.
    ///
    /// - Parameter location: The domain `Location` to convert.
    /// - Returns: An `MKMapItem` representing the location.
    func makeMapItem(from location: Location) -> MKMapItem {
        let clLocation = CLLocation(
            latitude: location.latitude,
            longitude: location.longitude
        )

        let mapItem = MKMapItem(
            location: clLocation,
            address: .init(
                fullAddress: location.address,
                shortAddress: nil
            )
        )

        mapItem.name = location.name

        return mapItem
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
                    collectionId: UUID(),
                    placeId: $0.identifier?.rawValue,
                    displayName: .empty,
                    name: $0.name ?? .empty,
                    address: $0.address?.fullAddress ?? .empty,
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
                    collectionId: UUID(),
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
