import Foundation
import CoreLocation
import Combine

/// Location Manager for DEFROST
/// Handles requesting and monitoring user location
class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var isAuthorized: Bool = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Check initial authorization status
        DispatchQueue.main.async {
            self.checkAuthorization()
        }
    }
    
    func requestLocation() {
        // First check current status
        let status = locationManager.authorizationStatus
        
        print("📍 Current location status: \(status.rawValue)")
        
        switch status {
        case .notDetermined:
            print("📍 Requesting when in use authorization")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("📍 Already authorized, requesting location")
            locationManager.requestLocation()
        case .denied, .restricted:
            print("📍 Location access denied or restricted")
            isAuthorized = false
        @unknown default:
            print("📍 Unknown authorization status")
        }
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    private func checkAuthorization() {
        let status = locationManager.authorizationStatus
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            print("📍 Location authorized, requesting location")
            locationManager.requestLocation()
        case .notDetermined:
            isAuthorized = false
            print("📍 Location permission not determined")
        case .denied, .restricted:
            isAuthorized = false
            print("📍 Location permission denied or restricted")
        @unknown default:
            isAuthorized = false
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("📍 Location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        DispatchQueue.main.async {
            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("📍 Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("📍 Authorization changed to: \(manager.authorizationStatus.rawValue)")
        DispatchQueue.main.async {
            self.checkAuthorization()
        }
    }
}
