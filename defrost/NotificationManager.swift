import Foundation
import CoreLocation
import UserNotifications

/// DEFROST Notification Manager - Location-Based Alert System
/// Monitors new reports and triggers notifications when threats are nearby
@MainActor
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    // Location manager
    private let locationManager = CLLocationManager()
    
    // Notification center
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Current user location
    @Published var userLocation: CLLocation?
    @Published var isAuthorized: Bool = false
    
    // Distance threshold (5 miles in meters)
    private let alertRadius: Double = 8046.72 // 5 miles = 8046.72 meters
    
    // Track processed report IDs to avoid duplicate notifications
    private var processedReportIDs: Set<String> = []
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100 // Update every 100 meters
    }
    
    // MARK: - Request Permissions
    
    /// Request both notification and location permissions
    func requestPermissions() {
        // Request notification permission
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🔔 Notification permission granted")
            } else if let error = error {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
        
        // Request location permission
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization() // For background updates
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ Location permission denied")
        @unknown default:
            break
        }
    }
    
    // MARK: - Location Updates
    
    /// Start monitoring location updates
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        isAuthorized = true
        print("📍 Location updates started")
    }
    
    /// Stop monitoring location updates
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        print("🛑 Location updates stopped")
    }
    
    // MARK: - Distance Calculation
    
    /// Calculate distance between user and report location
    func calculateDistance(to report: Report) -> Double? {
        guard let userLocation = userLocation else {
            print("⚠️ User location not available")
            return nil
        }
        
        let reportLocation = CLLocation(
            latitude: report.latitude,
            longitude: report.longitude
        )
        
        let distanceInMeters = userLocation.distance(from: reportLocation)
        return distanceInMeters
    }
    
    /// Convert meters to miles
    private func metersToMiles(_ meters: Double) -> Double {
        return meters / 1609.34
    }
    
    // MARK: - Report Monitoring
    
    /// Check new report and trigger notification if within radius
    func checkNewReport(_ report: Report) {
        // Skip if already processed
        guard !processedReportIDs.contains(report.id) else {
            return
        }
        
        // Calculate distance
        guard let distanceInMeters = calculateDistance(to: report) else {
            return
        }
        
        // Check if within 5 miles
        if distanceInMeters <= alertRadius {
            let distanceInMiles = metersToMiles(distanceInMeters)
            triggerNotification(for: report, distance: distanceInMiles)
            
            // Mark as processed
            processedReportIDs.insert(report.id)
        }
    }
    
    /// Process multiple new reports (call this when reports array updates)
    func checkNewReports(_ reports: [Report]) {
        for report in reports {
            checkNewReport(report)
        }
    }
    
    // MARK: - Trigger Notification
    
    /// Send local notification for nearby threat
    private func triggerNotification(for report: Report, distance: Double) {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ DEFROST ALERT"
        content.body = String(format: "Alert: %@ reported %.1f miles away", report.type, distance)
        content.sound = .default
        content.badge = 1
        
        // Add custom data
        content.userInfo = [
            "reportID": report.id,
            "reportType": report.type,
            "distance": distance,
            "locationName": report.locationName
        ]
        
        // Create trigger (immediate)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: report.id,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        notificationCenter.add(request) { error in
            if let error = error {
                print("❌ Notification error: \(error.localizedDescription)")
            } else {
                print("✅ Notification sent: \(report.type) at \(String(format: "%.1f", distance)) miles")
            }
        }
    }
    
    // MARK: - Clear Processed Reports
    
    /// Clear processed reports (call when user wants to reset)
    func clearProcessedReports() {
        processedReportIDs.removeAll()
        print("🗑️ Cleared processed reports cache")
    }
}

// MARK: - CLLocationManagerDelegate
extension NotificationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        Task { @MainActor in
            self.userLocation = location
            print("📍 User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        Task { @MainActor in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.isAuthorized = true
                self.startLocationUpdates()
                print("✅ Location authorized: \(status == .authorizedAlways ? "Always" : "When In Use")")
            case .denied, .restricted:
                self.isAuthorized = false
                print("❌ Location denied or restricted")
            case .notDetermined:
                print("⚠️ Location permission not determined")
            @unknown default:
                break
            }
        }
    }
}
