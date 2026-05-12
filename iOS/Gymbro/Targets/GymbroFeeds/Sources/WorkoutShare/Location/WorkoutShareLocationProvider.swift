import CoreLocation
import Foundation

enum WorkoutShareLocationError: Error {
    case permissionDenied
    case unableToDetermineLocation
}

@MainActor
final class WorkoutShareLocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var pendingContinuation: CheckedContinuation<[String], Error>?
    private var pendingAuthorizationContinuation: CheckedContinuation<Void, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestSuggestedLocations() async throws -> [String] {
        if let existing = pendingContinuation {
            _ = existing
            throw WorkoutShareLocationError.unableToDetermineLocation
        }

        guard CLLocationManager.locationServicesEnabled() else {
            throw WorkoutShareLocationError.permissionDenied
        }

        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            try await requestAuthorizationIfNeeded()
        case .restricted, .denied:
            throw WorkoutShareLocationError.permissionDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            break
        }

        return try await withCheckedThrowingContinuation { continuation in
            pendingContinuation = continuation
            DispatchQueue.global(qos: .userInitiated).async { [manager] in
                manager.requestLocation()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let mapped = mapLocationError(error) {
                pendingContinuation?.resume(throwing: mapped)
            } else {
                pendingContinuation?.resume(throwing: error)
            }
            pendingContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.first else {
                pendingContinuation?.resume(throwing: WorkoutShareLocationError.unableToDetermineLocation)
                pendingContinuation = nil
                return
            }

            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                let strings = placemarks
                    .compactMap(formatPlacemark(_:))
                    .removingDuplicates()

                if strings.isEmpty {
                    pendingContinuation?.resume(throwing: WorkoutShareLocationError.unableToDetermineLocation)
                } else {
                    pendingContinuation?.resume(returning: strings)
                }
            } catch {
                pendingContinuation?.resume(throwing: error)
            }

            pendingContinuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                pendingAuthorizationContinuation?.resume(returning: ())
                pendingAuthorizationContinuation = nil
            case .restricted, .denied:
                pendingAuthorizationContinuation?.resume(throwing: WorkoutShareLocationError.permissionDenied)
                pendingAuthorizationContinuation = nil

                pendingContinuation?.resume(throwing: WorkoutShareLocationError.permissionDenied)
                pendingContinuation = nil
            case .notDetermined:
                break
            @unknown default:
                break
            }
        }
    }

    private func requestAuthorizationIfNeeded() async throws {
        if let existing = pendingAuthorizationContinuation {
            _ = existing
            throw WorkoutShareLocationError.unableToDetermineLocation
        }

        let status = manager.authorizationStatus
        guard status == .notDetermined else { return }

        try await withCheckedThrowingContinuation { continuation in
            pendingAuthorizationContinuation = continuation
            DispatchQueue.global(qos: .userInitiated).async { [manager] in
                manager.requestWhenInUseAuthorization()
            }
        }
    }

    private func formatPlacemark(_ placemark: CLPlacemark) -> String? {
        let parts = [
            placemark.name,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
        .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

        guard !parts.isEmpty else { return nil }
        return parts.joined(separator: ", ")
    }

    private func mapLocationError(_ error: Error) -> WorkoutShareLocationError? {
        guard let clError = error as? CLError else { return nil }
        switch clError.code {
        case .denied:
            return .permissionDenied
        case .locationUnknown:
            return .unableToDetermineLocation
        default:
            return nil
        }
    }
}

private extension Array where Element == String {
    func removingDuplicates() -> [String] {
        var seen: Set<String> = []
        var result: [String] = []
        for item in self {
            if seen.insert(item).inserted {
                result.append(item)
            }
        }
        return result
    }
}
