import Foundation
import FirebaseFirestore

/// DEFROST Report Repository - Data Management Layer
/// Business logic for managing reports with Firebase
class ReportRepository {
    private let firebaseService = FirebaseService.shared
    private var listener: ListenerRegistration?
    
    // MARK: - Create
    
    /// Submit a new report with optional image
    func submitReport(
        type: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        description: String,
        imageData: Data?
    ) async throws {
        let reportID = UUID().uuidString
        var imageURL: String?
        
        // Upload image if provided
        if let imageData = imageData {
            print("📤 Uploading image for report: \(reportID)")
            imageURL = try await firebaseService.uploadImage(imageData, reportID: reportID)
        }
        
        // Create report object
        let report = Report(
            id: reportID,
            timestamp: Date(),
            type: type,
            locationName: locationName,
            latitude: latitude,
            longitude: longitude,
            description: description,
            imageURL: imageURL
        )
        
        // Save to Firestore
        try await firebaseService.createReport(report)
        print("✅ Report submitted successfully")
    }
    
    // MARK: - Read
    
    /// Fetch all reports (one-time fetch)
    func fetchReports() async throws -> [Report] {
        return try await firebaseService.fetchReports()
    }
    
    /// Start listening to real-time updates
    func startListening(onUpdate: @escaping ([Report]) -> Void) {
        listener = firebaseService.listenToReports { reports in
            onUpdate(reports)
        }
        print("👂 Started listening to reports")
    }
    
    /// Stop listening to real-time updates
    func stopListening() {
        listener?.remove()
        listener = nil
        print("🛑 Stopped listening to reports")
    }
    
    // MARK: - Delete
    
    /// Delete a report and its associated image
    func deleteReport(_ report: Report) async throws {
        guard let firestoreID = report.firestoreID else {
            throw RepositoryError.missingFirestoreID
        }
        
        // Delete image if exists
        if let imageURL = report.imageURL {
            do {
                try await firebaseService.deleteImage(url: imageURL)
            } catch {
                print("⚠️ Failed to delete image: \(error.localizedDescription)")
                // Continue with report deletion even if image deletion fails
            }
        }
        
        // Delete from Firestore
        try await firebaseService.deleteReport(firestoreID: firestoreID)
        print("✅ Report deleted successfully: \(report.id)")
    }
}

// MARK: - Custom Errors
enum RepositoryError: LocalizedError {
    case missingFirestoreID
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .missingFirestoreID:
            return "Report is missing Firestore document ID"
        case .invalidData:
            return "Invalid report data"
        }
    }
}
