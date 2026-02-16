import Foundation
import CoreLocation
import FirebaseFirestore

/// DEFROST Report Model - Shell Data Structure
/// Represents a single investigative report entry in the Urban Noir 2.0 system
struct Report: Identifiable, Codable {
    @DocumentID var firestoreID: String? // Firestore auto-generated ID
    let id: String // UUID as String for Firestore compatibility
    let timestamp: Date
    let type: String
    let locationName: String
    let latitude: Double
    let longitude: Double
    let description: String
    let imageURL: String? // Firebase Storage URL
    
    init(
        id: String = UUID().uuidString,
        timestamp: Date,
        type: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        description: String,
        imageURL: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.description = description
        self.imageURL = imageURL
    }
    
    // Calculate distance from user location
    func distance(from userLocation: CLLocation) -> Double {
        let reportLocation = CLLocation(latitude: latitude, longitude: longitude)
        return userLocation.distance(from: reportLocation)
    }
    
    // Format distance in miles or feet
    func formattedDistance(from userLocation: CLLocation) -> String {
        let distanceMeters = distance(from: userLocation)
        let distanceMiles = distanceMeters / 1609.34
        
        if distanceMiles < 0.1 {
            let feet = Int(distanceMeters * 3.28084)
            return "\(feet)_FT"
        } else {
            return String(format: "%.1f_MI", distanceMiles)
        }
    }
    
    // Time ago formatting
    func timeAgo() -> String {
        let interval = Date().timeIntervalSince(timestamp)
        let minutes = Int(interval / 60)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        
        if days > 0 {
            return "\(days)_DAY\(days == 1 ? "" : "S")_AGO"
        } else if hours > 0 {
            return "\(hours)_HR\(hours == 1 ? "" : "S")_AGO"
        } else {
            return "\(minutes)_MIN\(minutes == 1 ? "" : "S")_AGO"
        }
    }
}

// MARK: - Mock Data Extension (for previews only)
extension Report {
    static let mockArray: [Report] = [
        Report(
            timestamp: Date().addingTimeInterval(-3600 * 2),
            type: "CHECKPOINT",
            locationName: "DOWNTOWN_5TH_AVE",
            latitude: 40.7580,
            longitude: -73.9855,
            description: "Mobile checkpoint set up near subway entrance. 3 vehicles, approximately 6-8 officers. Checking IDs and documents.",
            imageURL: nil
        ),
        Report(
            timestamp: Date().addingTimeInterval(-3600 * 5),
            type: "PATROL",
            locationName: "BRONX_GRAND_CONCOURSE",
            latitude: 40.8448,
            longitude: -73.9242,
            description: "Marked vehicles patrolling residential area. Multiple stops observed over 30 minute period.",
            imageURL: nil
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 1),
            type: "RAID",
            locationName: "BROOKLYN_SUNSET_PARK",
            latitude: 40.6431,
            longitude: -74.0134,
            description: "Early morning operation at apartment building. Multiple units present. Building surrounded.",
            imageURL: nil
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 2),
            type: "CHECKPOINT",
            locationName: "QUEENS_ROOSEVELT_AVE",
            latitude: 40.7465,
            longitude: -73.8917,
            description: "Checkpoint near commercial district. Heavy activity during rush hour.",
            imageURL: nil
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 3),
            type: "PATROL",
            locationName: "MANHATTAN_WASHINGTON_HEIGHTS",
            latitude: 40.8518,
            longitude: -73.9352,
            description: "Increased patrol presence in neighborhood. Multiple units spotted throughout the day.",
            imageURL: nil
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 5),
            type: "CHECKPOINT",
            locationName: "STATEN_ISLAND_FERRY_TERMINAL",
            latitude: 40.6436,
            longitude: -74.0732,
            description: "Checkpoint at terminal entrance. All passengers being screened before boarding.",
            imageURL: nil
        )
    ]
}
