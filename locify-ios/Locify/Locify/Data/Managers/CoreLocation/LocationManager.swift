//
//  LocationManager.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/9/25.
//

import Combine
import CoreLocation
import Foundation

// MARK: - Protocols and Enums

/// Protocol defining the interface for location management operations.
protocol LocationManagerProtocol {
    /// The current authorization status for location services.
    var authorizationStatus: CLAuthorizationStatus { get }

    /// The last known location, if available.
    var lastKnownLocation: CLLocation? { get }

    /// Requests location permission for the specified type.
    /// - Parameter type: The type of permission to request (`whenInUse` or `always`).
    /// - Returns: `true` if permission is granted, `false` otherwise.
    /// - Throws: `LocationError` if permission cannot be requested or is denied.
    func requestPermission(type: LocationPermissionType) async throws -> Bool

    /// Starts updating the user's location with specified accuracy and distance filter.
    /// - Parameters:
    ///   - accuracy: Desired location accuracy (e.g., `kCLLocationAccuracyBest`).
    ///   - distanceFilter: Minimum distance (in meters) before updating location.
    /// - Throws: `LocationError` if location services are disabled or permission is denied.
    func startUpdatingLocation(accuracy: CLLocationAccuracy, distanceFilter: CLLocationDistance) async throws

    /// Stops updating the user's location.
    func stopUpdatingLocation()

    /// Retrieves location information as a `Location` object for a given location.
    /// - Parameter location: The `CLLocation` to geocode.
    /// - Returns: A `Location` object containing detailed location data.
    /// - Throws: `LocationError` if geocoding fails or network is unavailable.
    func getLocationInfo(for location: CLLocation) async throws -> Location

    /// Publisher for real-time location updates.
    var locationUpdates: AnyPublisher<CLLocation, Never> { get }

    /// Publisher for authorization status changes.
    var authorizationUpdates: AnyPublisher<CLAuthorizationStatus, Never> { get }

    /// Publisher for location-related errors.
    var errors: AnyPublisher<LocationError, Never> { get }
}

/// Enum defining types of location permission requests.
enum LocationPermissionType {
    /// Permission for location access when the app is in use.
    case whenInUse

    /// Permission for location access at all times, including in the background.
    case always
}

/// Enum representing possible errors during location operations.
enum LocationError: Error, LocalizedError {
    case permissionDenied
    case permissionRestricted
    case locationUnavailable
    case geocodingFailed(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission was denied."
        case .permissionRestricted:
            return "Location permission is restricted."
        case .locationUnavailable:
            return "Location is currently unavailable."
        case .geocodingFailed(let message):
            return "Geocoding failed: \(message)"
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: - LocationManager

/// Manages location services using CoreLocation, providing real-time updates, permission handling, and geocoding.
final class LocationManager: NSObject, LocationManagerProtocol {
    // MARK: - Properties

    /// Singleton instance for accessing the location manager.
    static let shared = LocationManager()

    private let locationManager: CLLocationManager
    private let geocoder: CLGeocoder
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let errorSubject = PassthroughSubject<LocationError, Never>()
    private var lastKnownLocationStorage: CLLocation?

    // MARK: - Computed Properties

    /// The current authorization status for location services.
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }

    /// The last known location, if available.
    var lastKnownLocation: CLLocation? {
        lastKnownLocationStorage
    }

    /// Publisher for real-time location updates.
    var locationUpdates: AnyPublisher<CLLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }

    /// Publisher for authorization status changes.
    var authorizationUpdates: AnyPublisher<CLAuthorizationStatus, Never> {
        authorizationSubject.eraseToAnyPublisher()
    }

    /// Publisher for location-related errors.
    var errors: AnyPublisher<LocationError, Never> {
        errorSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization

    /// Initializes the location manager with dependencies.
    /// - Parameters:
    ///   - locationManager: The `CLLocationManager` instance (default: new instance).
    ///   - geocoder: The `CLGeocoder` instance for reverse geocoding (default: new instance).
    init(
        locationManager: CLLocationManager = CLLocationManager(),
        geocoder: CLGeocoder = CLGeocoder()
    ) {
        self.locationManager = locationManager
        self.geocoder = geocoder
        super.init()
        locationManager.delegate = self
    }
}

// MARK: - Permission Handling
extension LocationManager {
    /// Requests location permission for the specified type.
    /// - Parameter type: The type of permission to request (`whenInUse` or `always`).
    /// - Returns: `true` if permission is granted, `false` otherwise.
    /// - Throws: `LocationError` if permission cannot be requested or is denied.
    func requestPermission(type: LocationPermissionType) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            switch authorizationStatus {
            case .notDetermined:
                if type == .always {
                    locationManager.allowsBackgroundLocationUpdates = true
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.allowsBackgroundLocationUpdates = false
                    locationManager.requestWhenInUseAuthorization()
                }
                Task { @MainActor in
                    do {
                        let status = try await waitForAuthorizationChange()
                        let granted = status == .authorizedWhenInUse || status == .authorizedAlways
                        continuation.resume(returning: granted)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            case .authorizedWhenInUse, .authorizedAlways:
                continuation.resume(returning: true)
            case .denied:
                errorSubject.send(.permissionDenied)
                continuation.resume(throwing: LocationError.permissionDenied)
            case .restricted:
                errorSubject.send(.permissionRestricted)
                continuation.resume(throwing: LocationError.permissionRestricted)
            @unknown default:
                let error = LocationError.unknown
                errorSubject.send(error)
                continuation.resume(throwing: error)
            }
        }
    }

    /// Waits for an authorization status change with a timeout.
    /// - Returns: The new authorization status.
    /// - Throws: `LocationError` if the operation times out or fails.
    private func waitForAuthorizationChange() async throws -> CLAuthorizationStatus {
        try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            var cancellable: AnyCancellable?
            cancellable = authorizationUpdates
                .first()
                .sink { status in
                    guard !didResume else { return }

                    didResume = true

                    cancellable?.cancel()
                    continuation.resume(returning: status)
                }
            Task {
                try await Task.sleep(for: .seconds(20))

                guard !didResume else { return }

                didResume = true

                cancellable?.cancel()
                continuation.resume(returning: authorizationStatus)
            }
        }
    }
}

// MARK: - Location Updates
extension LocationManager {
    /// Starts updating the user's location with specified accuracy and distance filter.
    /// - Parameters:
    ///   - accuracy: Desired location accuracy (default: `kCLLocationAccuracyBest`).
    ///   - distanceFilter: Minimum distance (in meters) before updating location (default: `kCLDistanceFilterNone`).
    /// - Throws: `LocationError` if location services are disabled or permission is denied.
    func startUpdatingLocation(
        accuracy: CLLocationAccuracy = kCLLocationAccuracyBest,
        distanceFilter: CLLocationDistance = kCLDistanceFilterNone
    ) async throws {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            errorSubject.send(.permissionDenied)
            throw LocationError.permissionDenied
        }

        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = distanceFilter
        locationManager.startUpdatingLocation()
    }

    /// Stops updating the user's location.
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - Geocoding
extension LocationManager {
    /// Retrieves location information as a `Location` object for a given location.
    /// - Parameter location: The `CLLocation` to geocode.
    /// - Returns: A `Location` object containing detailed location data.
    /// - Throws: `LocationError` if geocoding fails or network is unavailable.
    func getLocationInfo(for location: CLLocation) async throws -> Location {
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                throw LocationError.geocodingFailed("No address found.")
            }

            guard let address = placemark.locationAddress else {
                throw LocationError.geocodingFailed("Invalid address data.")
            }

            let name = placemark.name ?? "My location"

            return Location(
                id: Constants.myLocationId,
                categoryId: UUID(),
                displayName: "My location",
                name: name,
                address: address,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                createdAt: Date(),
                updatedAt: Date()
            )
        } catch {
            errorSubject.send(.geocodingFailed(error.localizedDescription))
            throw LocationError.geocodingFailed(error.localizedDescription)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Logger.debug("Location updated: \(location.coordinate)")
        lastKnownLocationStorage = location
        locationSubject.send(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Logger.error("Location error: \(error.localizedDescription)")
        let locationError: LocationError
        if let clError = error as? CLError {
            switch clError.code {
            case .denied: locationError = .permissionDenied
            case .locationUnknown: locationError = .locationUnavailable
            default: locationError = .unknown
            }
        } else {
            locationError = .unknown
        }
        errorSubject.send(locationError)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Logger.debug("Authorization changed: \(manager.authorizationStatus)")
        authorizationSubject.send(manager.authorizationStatus)
    }
}

// MARK: - CLPlacemark Extension
extension CLPlacemark {
    /// Formats the placemark into a human-readable address string.
    var locationAddress: String? {
        let components = [subThoroughfare, thoroughfare, locality, administrativeArea, postalCode, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        return components.isEmpty ? nil : components.joined(separator: ", ")
    }
}
