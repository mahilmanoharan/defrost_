import SwiftUI

/// DEFROST Dashboard View - Command Center Registry UI
/// Main interface for displaying investigative reports in Urban Noir 2.0 aesthetic
struct DashboardView: View {
    @State private var showInquiry: Bool = false
    @State private var pulseOpacity: Double = 1.0
    
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
                
                // MARK: - Report Registry List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Report.mockArray) { report in
                            reportRow(report)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
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
            InquiryView()
        }
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("COMMAND CENTER")
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
    
    // MARK: - Report Row Component
    private func reportRow(_ report: Report) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Timestamp
            Text(formatTimestamp(report.timestamp))
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(steel)
            
            // Type
            Text(report.type)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(boneWhite)
            
            // Location
            Text(report.locationName)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(steel)
            
            // ID
            Text("ID: \(report.id.uuidString.prefix(8))")
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(steel.opacity(0.6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(obsidian)
        .overlay(
            Rectangle()
                .stroke(steel, lineWidth: 0.5)
        )
        .cornerRadius(0)
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
