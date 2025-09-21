//
//  LocationManager.swift
//  Locify
//
//  Created by Hoàng Hiệp Lê on 8/9/25.
//

import Combine
import CoreLocation

// MARK: - Protocols and Enums

/// Protocol defining the interface for location management operations.
protocol LocationManagerProtocol {
    /// The current authorization status for location services.
    var authorizationStatus: CLAuthorizationStatus { get }

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
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let authorizationSubject = PassthroughSubject<CLAuthorizationStatus, Never>()
    private let errorSubject = PassthroughSubject<LocationError, Never>()
    private var lastKnownLocationStorage: CLLocation?

    // MARK: - Computed Properties

    /// The current authorization status for location services.
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
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
    /// - Parameter locationManager: The `CLLocationManager` instance (default: new instance).
    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
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

    /// Returns the most recently recorded user location, if available.
    ///
    /// This method provides access to the last location delivered by Core Location and cached by the manager.
    /// It retries up to 3 times, waiting 0.5 seconds between attempts, to give Core Location time to deliver
    /// a value if updates have just started.
    /// - Returns: The last known `CLLocation` if one has been received.
    /// - Throws: `LocationError.locationUnavailable` if no location is available after retries.
    func getLastKnownLocation() async throws -> CLLocation {
        // Fast path if we already have a cached location
        if let location = lastKnownLocationStorage {
            return location
        }

        // Retry up to 3 times, waiting 0.5 seconds between attempts
        let maxRetries = 3
        for attempt in 1...maxRetries {
            try await Task.sleep(for: .seconds(0.5))
            if let location = lastKnownLocationStorage {
                return location
            }
            Logger.debug("Last known location unavailable. Retry #\(attempt) of #\(maxRetries)")
        }

        // After retries, still no location
        throw LocationError.locationUnavailable
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
