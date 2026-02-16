import Foundation
import CoreLocation
import UserNotifications
import Combine

/// DEFROST Notification Manager - Location-Based Alert System
/// Monitors new reports and triggers notifications when threats are nearby
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
        
        // Set notification delegate to show notifications even when app is in foreground
        notificationCenter.delegate = self
        print("🔔 NotificationManager initialized with foreground notification support")
    }
    
    // MARK: - Request Permissions
    
    /// Request both notification and location permissions
    @MainActor
    func requestPermissions() {
        // Request notification permission
        Task {
            do {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
                if granted {
                    print("🔔 Notification permission granted")
                } else {
                    print("⚠️ Notification permission denied")
                }
            } catch {
                print("❌ Notification permission error: \(error.localizedDescription)")
            }
        }
        
        // Request location permission - ALWAYS (for background tracking)
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            print("📍 Requesting 'Always' location permission for background tracking...")
            locationManager.requestAlwaysAuthorization() // Changed from requestWhenInUseAuthorization
        case .authorizedAlways:
            print("✅ 'Always' location permission already granted")
            configureBackgroundTracking()
            startLocationUpdates()
        case .authorizedWhenInUse:
            print("⚠️ WARNING: Only 'When In Use' permission granted!")
            print("⚠️ Background notifications will NOT work when screen is locked.")
            print("⚠️ Go to Settings → Privacy → Location Services → defrost → Change to 'Always'")
            startLocationUpdates()
        case .denied, .restricted:
            print("❌ Location permission denied or restricted")
        @unknown default:
            break
        }
    }
    
    // MARK: - Background Location Configuration
    
    /// Configure location manager for background tracking
    private func configureBackgroundTracking() {
        // Enable background location updates
        locationManager.allowsBackgroundLocationUpdates = true
        
        // Don't pause updates automatically (critical for physical devices)
        locationManager.pausesLocationUpdatesAutomatically = false
        
        // Show blue bar when tracking in background (optional, for transparency)
        locationManager.showsBackgroundLocationIndicator = true
        
        print("🔋 Background location tracking configured")
        print("   - allowsBackgroundLocationUpdates: true")
        print("   - pausesLocationUpdatesAutomatically: false")
    }
    
    /// Check if user has granted 'Always' permission
    func checkAlwaysPermission() -> Bool {
        let status = locationManager.authorizationStatus
        
        if status == .authorizedAlways {
            print("✅ 'Always' permission: GRANTED")
            return true
        } else {
            print("⚠️ 'Always' permission: NOT GRANTED")
            print("   Current status: \(statusString(status))")
            print("   Background tracking will NOT work when screen is locked!")
            return false
        }
    }
    
    /// Convert authorization status to readable string
    private func statusString(_ status: CLAuthorizationStatus) -> String {
        switch status {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Denied"
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use Only"
        @unknown default: return "Unknown"
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
        print("🔔 Checking report: \(report.id)")
        
        // Skip if already processed
        guard !processedReportIDs.contains(report.id) else {
            print("   ⏭️ Already processed, skipping")
            return
        }
        
        // Calculate distance
        guard let distanceInMeters = calculateDistance(to: report) else {
            print("   ⚠️ Could not calculate distance (no user location)")
            return
        }
        
        let distanceInMiles = metersToMiles(distanceInMeters)
        print("   📏 Distance: \(String(format: "%.1f", distanceInMiles)) miles (threshold: 5.0 miles)")
        
        // Check if within 5 miles
        if distanceInMeters <= alertRadius {
            print("   ✅ Within range! Triggering notification...")
            triggerNotification(for: report, distance: distanceInMiles)
            
            // Mark as processed
            processedReportIDs.insert(report.id)
        } else {
            print("   ❌ Too far away, no notification")
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
        
        // Create trigger (deliver after 1 second to ensure it shows even if app is in foreground)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
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
                print("✅ Notification scheduled successfully for: \(report.type) at \(String(format: "%.1f", distance)) miles")
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
        
        DispatchQueue.main.async {
            self.userLocation = location
            print("📍 User location updated: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        
        DispatchQueue.main.async {
            switch status {
            case .authorizedAlways:
                self.isAuthorized = true
                self.configureBackgroundTracking() // Enable background tracking
                self.startLocationUpdates()
                print("✅ Location authorized: Always (background tracking enabled)")
            case .authorizedWhenInUse:
                self.isAuthorized = true
                self.startLocationUpdates()
                print("⚠️ Location authorized: When In Use Only")
                print("⚠️ Background notifications will NOT work!")
                print("⚠️ Change to 'Always' in Settings for full functionality")
            case .denied, .restricted:
                self.isAuthorized = false
                print("❌ Location denied or restricted")
            case .notDetermined:
                print("⚠️ Location permission not determined")
            @unknown default:
                break
            }
            
            // Check and log permission status
            _ = self.checkAlwaysPermission()
        }
    }
}
// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Called when notification is about to be presented while app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("🔔 Presenting notification in foreground: \(notification.request.content.title)")
        
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user taps on the notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print("🔔 User tapped notification: \(userInfo)")
        
        // Handle notification tap (could navigate to specific report)
        completionHandler()
    }
}

