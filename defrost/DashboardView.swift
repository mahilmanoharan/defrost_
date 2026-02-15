import SwiftUI
import CoreLocation

/// DEFROST Dashboard View - Command Center Registry UI
/// Main interface for displaying investigative reports in Urban Noir 2.0 aesthetic
struct DashboardView: View {
    @State private var showInquiry: Bool = false
    @State private var pulseOpacity: Double = 1.0
    @State private var showSubmissionConfirmation: Bool = false
    @State private var showRedBackground: Bool = false
    @State private var redBackgroundHeight: CGFloat = 0
    @State private var selectedReport: Report?
    
    // Mock user location (NYC area)
    private let userLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
    
    // Filter states
    @State private var selectedSort: SortOption = .recency
    @State private var selectedThreatType: ThreatFilter = .all
    
    // Filter options
    enum SortOption: String, CaseIterable {
        case recency = "RECENCY"
        case nearest = "NEAREST"
    }
    
    enum ThreatFilter: String, CaseIterable {
        case all = "ALL"
        case checkpoint = "CHECKPOINT"
        case patrol = "PATROL"
        case raid = "RAID"
    }
    
    // MARK: - Color Palette (No-Vibe Protocol)
    private let obsidian = Color(hex: "#080808")
    private let boneWhite = Color(hex: "#EAE7E2")
    private let steel = Color(hex: "#555555")
    private let crimson = Color(hex: "#8B0000")
    
    var body: some View {
        ZStack {
            // Background
            obsidian.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Command Center Header
                headerView
                
                // MARK: - Filter Controls
                filterControlsView
                
                // MARK: - Report Registry List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredReports) { report in
                            reportCard(report)
                                .onTapGesture {
                                    selectedReport = report
                                }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
                
                Spacer()
            }
            
            // MARK: - Bottom Action Button
            VStack {
                Spacer()
                initiateInquiryButton
            }
        }
        .fullScreenCover(isPresented: $showInquiry) {
            InquiryView(onSubmit: handleReportSubmission)
        }
        .sheet(item: $selectedReport) { report in
            ReportDetailView(report: report)
        }
        .overlay(
            // Full red background after submission - comes from bottom up
            VStack {
                Spacer()
                crimson
                    .frame(height: redBackgroundHeight)
                    .ignoresSafeArea()
            }
            .ignoresSafeArea()
        )
        .overlay(
            // Submission Confirmation Card
            Group {
                if showSubmissionConfirmation {
                    submissionConfirmationCard
                }
            }
        )
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("DEFROST_")
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(boneWhite)
                .tracking(2)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(crimson)
                    .frame(width: 8, height: 8)
                    .opacity(pulseOpacity)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: 1.5).repeatForever(autoreverses: true)
                        ) {
                            pulseOpacity = 0.3
                        }
                    }
                
                Text("SYSTEM_SCANNING")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(crimson)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(obsidian)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(steel),
            alignment: .bottom
        )
    }
    
    // MARK: - Filter Controls Component
    private var filterControlsView: some View {
        VStack(spacing: 12) {
            // Sort Options (Recency / Nearest)
            HStack(spacing: 8) {
                Text("SORT:")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
                
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button(action: {
                        selectedSort = option
                    }) {
                        Text(option.rawValue)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(selectedSort == option ? obsidian : boneWhite)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedSort == option ? boneWhite : Color.clear)
                            .overlay(
                                Rectangle()
                                    .stroke(selectedSort == option ? boneWhite : steel, lineWidth: 0.5)
                            )
                    }
                }
                
                Spacer()
            }
            
            // Threat Type Filter
            HStack(spacing: 8) {
                Text("TYPE:")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(steel)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ThreatFilter.allCases, id: \.self) { filter in
                            Button(action: {
                                selectedThreatType = filter
                            }) {
                                Text(filter.rawValue)
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(selectedThreatType == filter ? obsidian : boneWhite)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(selectedThreatType == filter ? boneWhite : Color.clear)
                                    .overlay(
                                        Rectangle()
                                            .stroke(selectedThreatType == filter ? boneWhite : steel, lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(obsidian)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(steel),
            alignment: .bottom
        )
    }
    
    // MARK: - Report Card Component (Instagram Style)
    private func reportCard(_ report: Report) -> some View {
        VStack(spacing: 0) {
            // Image Placeholder
            ZStack {
                Rectangle()
                    .fill(steel.opacity(0.2))
                    .aspectRatio(1.0, contentMode: .fit)
                
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.system(size: 40))
                        .foregroundColor(steel)
                    
                    Text("NO_IMAGE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(steel)
                }
            }
            
            // Report Info
            VStack(alignment: .leading, spacing: 12) {
                // Type Badge
                HStack {
                    Text(report.type)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(obsidian)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(crimson)
                    
                    Spacer()
                    
                    Text(report.timeAgo())
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(steel)
                }
                
                // Location
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundColor(steel)
                    
                    Text(report.locationName)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(boneWhite)
                }
                
                // Distance and Date
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.circle")
                            .font(.system(size: 10))
                            .foregroundColor(steel)
                        
                        Text(report.formattedDistance(from: userLocation))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(steel)
                    }
                    
                    Spacer()
                    
                    Text(formatDate(report.timestamp))
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(steel.opacity(0.7))
                }
                
                // Description Preview
                Text(report.description)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(boneWhite.opacity(0.8))
                    .lineLimit(2)
                    .lineSpacing(2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(obsidian)
        }
        .overlay(
            Rectangle()
                .stroke(steel, lineWidth: 0.5)
        )
    }
    
    // MARK: - Date Formatter
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    // MARK: - Initiate Inquiry Button
    private var initiateInquiryButton: some View {
        Button(action: {
            showInquiry = true
        }) {
            Text("[REPORT_]")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(boneWhite)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(crimson)
                .overlay(
                    Rectangle()
                        .stroke(crimson, lineWidth: 0.5)
                )
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }
    
    // MARK: - Placeholder Inquiry View
    private var placeholderInquiryView: some View {
        ZStack {
            obsidian.ignoresSafeArea()
            
            VStack {
                Text("INQUIRY_MODULE")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(boneWhite)
                
                Button(action: {
                    showInquiry = false
                }) {
                    Text("[CLOSE]")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(crimson)
                        .padding()
                }
            }
        }
    }
    
    // MARK: - Utility Functions
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd_HH:mm:ss"
        return formatter.string(from: date)
    }
    
    // MARK: - Submission Confirmation Card
    private var submissionConfirmationCard: some View {
        ZStack {
            // Tap anywhere to dismiss
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissConfirmation()
                }
            
            VStack(spacing: 24) {
                // Checkmark placeholder
                ZStack {
                    Circle()
                        .stroke(boneWhite, lineWidth: 2)
                        .frame(width: 80, height: 80)
                    
                    // Placeholder for checkmark SF Symbol
                    Text("✓")
                        .font(.system(size: 50, weight: .bold, design: .monospaced))
                        .foregroundColor(boneWhite)
                }
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    Text("REPORT_SUBMITTED")
                        .font(.system(size: 20, weight: .bold, design: .monospaced))
                        .foregroundColor(boneWhite)
                        .tracking(2)
                    
                    Text("THANK_YOU_FOR_YOUR_REPORT")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(boneWhite.opacity(0.8))
                        .tracking(1)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    dismissConfirmation()
                }) {
                    Text("[DISMISS]")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(boneWhite)
                        .frame(width: 200, height: 44)
                        .overlay(
                            Rectangle()
                                .stroke(boneWhite, lineWidth: 0.5)
                        )
                }
                .padding(.bottom, 20)
            }
            .padding(32)
            .background(crimson.opacity(0.3))
            .overlay(
                Rectangle()
                    .stroke(boneWhite, lineWidth: 1)
            )
            .frame(width: 320)
        }
    }
    
    // MARK: - Dismiss Confirmation
    private func dismissConfirmation() {
        withAnimation(.easeOut(duration: 0.3)) {
            showSubmissionConfirmation = false
            redBackgroundHeight = 0
        }
    }
    
    // MARK: - Handle Report Submission
    private func handleReportSubmission() {
        // Animate red background from bottom to top immediately
        withAnimation(.easeOut(duration: 0.35)) {
            redBackgroundHeight = UIScreen.main.bounds.height
        }
        
        // Dismiss the inquiry view almost immediately so red shows through
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            showInquiry = false
        }
        
        // Show the confirmation card after red fills
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.2)) {
                showSubmissionConfirmation = true
            }
        }
    }
    
    // MARK: - Filtered Reports
    private var filteredReports: [Report] {
        var reports = Report.mockArray
        
        // Filter by threat type
        if selectedThreatType != .all {
            reports = reports.filter { $0.type.uppercased() == selectedThreatType.rawValue }
        }
        
        // Sort by selected option
        switch selectedSort {
        case .recency:
            reports = reports.sorted { $0.timestamp > $1.timestamp }
        case .nearest:
            // Sort by distance from user location (closest first)
            reports = reports.sorted { 
                $0.distance(from: userLocation) < $1.distance(from: userLocation)
            }
        }
        
        return reports
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
}
