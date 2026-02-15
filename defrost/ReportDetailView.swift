import SwiftUI
import CoreLocation

/// DEFROST Report Detail View - Full Report Display
/// Instagram-style detailed view of a single report
struct ReportDetailView: View {
    let report: Report
    @Environment(\.dismiss) private var dismiss
    
    // Mock user location (NYC area)
    private let userLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
    
    // MARK: - Color Palette (No-Vibe Protocol)
    private let obsidian = Color(hex: "#080808")
    private let boneWhite = Color(hex: "#EAE7E2")
    private let steel = Color(hex: "#555555")
    private let crimson = Color(hex: "#8B0000")
    
    var body: some View {
        ZStack {
            obsidian.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header with back button
                headerView
                
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Image Placeholder
                        imageSection
                        
                        // MARK: - Report Details
                        detailsSection
                    }
                }
            }
        }
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(boneWhite)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text(report.type)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(boneWhite)
            
            Spacer()
            
            // Spacer for symmetry
            Color.clear
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(obsidian)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(steel),
            alignment: .bottom
        )
    }
    
    // MARK: - Image Section
    private var imageSection: some View {
        ZStack {
            Rectangle()
                .fill(steel.opacity(0.2))
                .aspectRatio(1.0, contentMode: .fit)
            
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 50))
                    .foregroundColor(steel)
                
                Text("NO_IMAGE_ATTACHED")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
            }
        }
    }
    
    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Type and Time
            HStack {
                Text(report.type)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(crimson)
                
                Spacer()
                
                Text(report.timeAgo())
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(steel)
            }
            
            // Location Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(steel)
                    
                    Text(report.locationName)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundColor(boneWhite)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.circle")
                        .font(.system(size: 12))
                        .foregroundColor(steel)
                    
                    Text(report.formattedDistance(from: userLocation))
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(steel)
                    
                    Text("FROM_YOUR_LOCATION")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(steel.opacity(0.7))
                }
            }
            
            // Divider
            Rectangle()
                .fill(steel)
                .frame(height: 0.5)
            
            // Description
            VStack(alignment: .leading, spacing: 8) {
                Text("REPORT_DETAILS")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
                    .tracking(1)
                
                Text(report.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(boneWhite)
                    .lineSpacing(4)
            }
            
            // Timestamp
            VStack(alignment: .leading, spacing: 4) {
                Text("TIMESTAMP")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
                    .tracking(1)
                
                Text(formatTimestamp(report.timestamp))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(steel)
            }
            
            // Coordinates
            VStack(alignment: .leading, spacing: 4) {
                Text("COORDINATES")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
                    .tracking(1)
                
                Text("\(String(format: "%.4f", report.latitude)), \(String(format: "%.4f", report.longitude))")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(steel)
            }
            
            // Report ID
            VStack(alignment: .leading, spacing: 4) {
                Text("REPORT_ID")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
                    .tracking(1)
                
                Text(report.id.uuidString.uppercased())
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(steel.opacity(0.6))
            }
        }
        .padding(16)
    }
    
    // MARK: - Utility Functions
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd_HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    ReportDetailView(report: Report.mockArray[0])
}
