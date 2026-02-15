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

    private lazy var completer = MKLocalSearchCompleter()
    private var search: MKLocalSearch?
    private var completionByLocationID: [UUID: MKLocalSearchCompletion] = [:]

    private let querySubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var suggestions: CheckedContinuation<[Location], Never>?

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest, .physicalFeature]

        querySubject
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
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
            name: item.name ?? "My Location",
            displayName: "My Location",
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
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            throw LocationError.geocodingFailed("Invalid coordinate.")
        }

        var metadata: LocationMetadata

        // Strategy 1: If MapFeature has a name, try MKLocalSearch for richer metadata
        if let name = name, !name.isEmpty {
            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = name
            searchRequest.region = MKCoordinateRegion(
                center: coordinate,
                span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )

            let search = MKLocalSearch(request: searchRequest)

            if let response = try? await search.start(),
               let firstItem = response.mapItems.first {

                // Validate: Is this result near the user's tap? (within 500m)
                let resultLocation = firstItem.location
                let distance = CLLocation(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                ).distance(from: resultLocation)

                if distance < 500 {
                    metadata = .init(
                        name: firstItem.name ?? name,
                        address: firstItem.address?.fullAddress ?? .empty,
                        placeId: firstItem.identifier?.rawValue
                    )
                } else {
                    Logger.debug("MKLocalSearch result too far (\(distance)m), using reverse geocoding")
                    metadata = try await reverseGeocodeMetadata(for: coordinate, fallbackName: name)
                }
            } else {
                // Search failed - fall back to reverse geocoding
                metadata = try await reverseGeocodeMetadata(for: coordinate, fallbackName: name)
            }
        } else {
            // No name provided - use reverse geocoding
            metadata = try await reverseGeocodeMetadata(for: coordinate, fallbackName: nil)
        }

        return .init(
            id: Constants.mapSelectionId,
            collectionId: UUID(),
            placeId: metadata.placeId,
            name: metadata.name,
            displayName: .empty,
            address: metadata.address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }

    /// Performs reverse geocoding to extract metadata from a coordinate without replacing it.
    ///
    /// This helper method converts a coordinate into human-readable metadata (name, address, place ID)
    /// using MapKit's reverse geocoding service. Unlike the full `getSelectedMapLocationInfo`,
    /// this method is specifically designed to extract **metadata only**, ensuring the original
    /// coordinate is never replaced by the geocoding service's snapped coordinate.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinate to reverse geocode. Must be a valid CLLocationCoordinate2D
    ///                 (validated by caller using `CLLocationCoordinate2DIsValid`).
    ///   - fallbackName: An optional name to use if reverse geocoding returns no name.
    ///                   Typically provided from `MapFeature.title` when available.
    /// - Returns: A `LocationMetadata` struct containing the place name, address, and place ID.
    /// - Throws: `LocationError.geocodingFailed` if the geocoding request fails or returns no results.
    private func reverseGeocodeMetadata(
        for coordinate: CLLocationCoordinate2D,
        fallbackName: String?
    ) async throws -> LocationMetadata {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        guard let request = MKReverseGeocodingRequest(location: location),
              let item = try await request.mapItems.first else {
            throw LocationError.geocodingFailed("No address found.")
        }

        return .init(
            name: fallbackName ?? item.name ?? .empty,
            address: item.address?.fullAddress ?? .empty,
            placeId: item.identifier?.rawValue
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

        completer.queryFragment = .empty

        querySubject.send(query)

        return await withCheckedContinuation { continuation in
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
            guard let completion = completionByLocationID[location.id] else {
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
                    name: $0.name ?? .empty,
                    displayName: .empty,
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

        for completion in completer.results {
            let id = UUID()

            locations.append(
                .init(
                    id: id,
                    collectionId: UUID(),
                    name: completion.title,
                    displayName: .empty,
                    address: completion.subtitle,
                    latitude: .zero,
                    longitude: .zero
                )
            )
            completionByLocationID[id] = completion
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
