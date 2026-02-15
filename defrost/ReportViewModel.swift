import Foundation
import SwiftUI
import Combine

/// DEFROST Report ViewModel - State Management
/// ObservableObject that manages report data and syncs with Firebase
@MainActor
class ReportViewModel: ObservableObject {
    // MARK: - Published State
    @Published var reports: [Report] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var isSubmitting: Bool = false
    
    // MARK: - Dependencies
    private let repository = ReportRepository()
    
    // MARK: - Lifecycle
    
    /// Start listening to real-time updates when view appears
    func startListening() {
        isLoading = true
        
        repository.startListening { [weak self] reports in
            guard let self = self else { return }
            self.reports = reports
            self.isLoading = false
            print("📱 UI updated with \(reports.count) reports")
        }
    }
    
    /// Stop listening when view disappears
    func stopListening() {
        repository.stopListening()
    }
    
    // MARK: - Submit Report
    
    /// Submit a new report to Firebase
    func submitReport(
        type: String,
        locationName: String,
        latitude: Double,
        longitude: Double,
        description: String,
        imageData: Data?
    ) async {
        isSubmitting = true
        errorMessage = nil
        
        do {
            try await repository.submitReport(
                type: type,
                locationName: locationName,
                latitude: latitude,
                longitude: longitude,
                description: description,
                imageData: imageData
            )
            print("✅ ViewModel: Report submitted successfully")
        } catch {
            errorMessage = "Failed to submit report: \(error.localizedDescription)"
            showError = true
            print("❌ ViewModel error: \(error.localizedDescription)")
        }
        
        isSubmitting = false
    }
    
    // MARK: - Delete Report
    
    /// Delete a report (admin only)
    func deleteReport(_ report: Report) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.deleteReport(report)
            print("✅ ViewModel: Report deleted successfully")
        } catch {
            errorMessage = "Failed to delete report: \(error.localizedDescription)"
            showError = true
            print("❌ ViewModel error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Helper: Validate Report Data
    
    /// Validate report fields before submission
    func validateReport(type: String, locationName: String, description: String) -> Bool {
        guard !type.isEmpty else {
            errorMessage = "Please select a threat type"
            showError = true
            return false
        }
        
        guard !locationName.isEmpty else {
            errorMessage = "Please enter a location name"
            showError = true
            return false
        }
        
        guard !description.isEmpty else {
            errorMessage = "Please enter a description"
            showError = true
            return false
        }
        
        return true
    }
}
