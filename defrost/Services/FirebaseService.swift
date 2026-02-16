import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

/// DEFROST Firebase Service - Backend Connection Layer
/// Handles all Firebase operations for Firestore and Storage
class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    private init() {}
    
    // MARK: - Firestore Operations
    
    /// Fetch all reports from Firestore
    func fetchReports() async throws -> [Report] {
        let snapshot = try await db.collection("reports")
            .order(by: "timestamp", descending: true)
            .limit(to: 100) // Limit to last 100 reports
            .getDocuments()
        
        let reports = snapshot.documents.compactMap { document -> Report? in
            try? document.data(as: Report.self)
        }
        
        print("📊 Fetched \(reports.count) reports from Firestore")
        return reports
    }
    
    /// Create a new report in Firestore
    func createReport(_ report: Report) async throws {
        let reportData: [String: Any] = [
            "id": report.id,
            "timestamp": Timestamp(date: report.timestamp),
            "type": report.type,
            "locationName": report.locationName,
            "latitude": report.latitude,
            "longitude": report.longitude,
            "description": report.description,
            "imageURL": report.imageURL as Any
        ]
        
        try await db.collection("reports").addDocument(data: reportData)
        print("✅ Report created successfully: \(report.id)")
    }
    
    /// Delete a report from Firestore
    func deleteReport(firestoreID: String) async throws {
        try await db.collection("reports").document(firestoreID).delete()
        print("🗑️ Report deleted: \(firestoreID)")
    }
    
    /// Listen to real-time updates from Firestore
    func listenToReports(completion: @escaping ([Report]) -> Void) -> ListenerRegistration {
        let listener = db.collection("reports")
            .order(by: "timestamp", descending: true)
            .limit(to: 100)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("❌ Firestore listener error: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("⚠️ No documents found")
                    completion([])
                    return
                }
                
                let reports = documents.compactMap { document -> Report? in
                    try? document.data(as: Report.self)
                }
                
                print("🔄 Real-time update: \(reports.count) reports")
                completion(reports)
            }
        
        return listener
    }
    
    // MARK: - Storage Operations
    
    /// Upload an image to Firebase Storage and return the download URL
    func uploadImage(_ imageData: Data, reportID: String) async throws -> String {
        // Compress image before upload
        guard let compressedData = compressImage(imageData) else {
            throw FirebaseError.imageCompressionFailed
        }
        
        let storageRef = storage.reference()
        let imageRef = storageRef.child("report-images/\(reportID).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // Upload image
        _ = try await imageRef.putDataAsync(compressedData, metadata: metadata)
        print("📤 Image uploaded for report: \(reportID)")
        
        // Get download URL
        let downloadURL = try await imageRef.downloadURL()
        print("🔗 Download URL: \(downloadURL.absoluteString)")
        
        return downloadURL.absoluteString
    }
    
    /// Delete an image from Firebase Storage
    func deleteImage(url: String) async throws {
        let storageRef = storage.reference(forURL: url)
        try await storageRef.delete()
        print("🗑️ Image deleted from Storage")
    }
    
    // MARK: - Image Compression
    
    /// Compress image to reduce upload size
    private func compressImage(_ imageData: Data) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }
        
        // Resize to max width of 800px
        let maxWidth: CGFloat = 800
        let scale = maxWidth / image.size.width
        
        if scale < 1 {
            let newHeight = image.size.height * scale
            let newSize = CGSize(width: maxWidth, height: newHeight)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // Compress to 70% quality
            return resizedImage?.jpegData(compressionQuality: 0.7)
        }
        
        // If already small, just compress
        return image.jpegData(compressionQuality: 0.7)
    }
}

// MARK: - Custom Errors
enum FirebaseError: LocalizedError {
    case imageCompressionFailed
    case uploadFailed
    case deleteFailed
    
    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "Failed to compress image"
        case .uploadFailed:
            return "Failed to upload to Firebase"
        case .deleteFailed:
            return "Failed to delete from Firebase"
        }
    }
}
