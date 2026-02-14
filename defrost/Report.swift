import Foundation

/// DEFROST Report Model - Shell Data Structure
/// Represents a single investigative report entry in the Urban Noir 2.0 system
struct Report: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: String
    let locationName: String
    
    init(
        id: UUID = UUID(),
        timestamp: Date,
        type: String,
        locationName: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.locationName = locationName
    }
}

// MARK: - Mock Data Extension
extension Report {
    static let mockArray: [Report] = [
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 7),
            type: "INCIDENT_01",
            locationName: "TERMINAL_DISTRICT_NORTH"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 6),
            type: "SECTOR_CHECK",
            locationName: "WATERFRONT_PIER_09"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 5),
            type: "INCIDENT_02",
            locationName: "INDUSTRIAL_ZONE_ECHO"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 4),
            type: "SURVEILLANCE_LOG",
            locationName: "DOWNTOWN_CROSSING"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 3),
            type: "SECTOR_CHECK",
            locationName: "BLACKSITE_ALPHA"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 2),
            type: "INCIDENT_03",
            locationName: "RESIDENTIAL_BLOCK_47"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-86400 * 1),
            type: "PERIMETER_SWEEP",
            locationName: "TRANSIT_HUB_CENTRAL"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-3600 * 12),
            type: "INCIDENT_04",
            locationName: "ROOFTOP_ACCESS_DENIED"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-3600 * 6),
            type: "SECTOR_CHECK",
            locationName: "UNDERGROUND_PASSAGE_12"
        ),
        Report(
            timestamp: Date().addingTimeInterval(-3600 * 1),
            type: "ACTIVE_INVESTIGATION",
            locationName: "GRID_SECTOR_UNKNOWN"
        )
    ]
}
