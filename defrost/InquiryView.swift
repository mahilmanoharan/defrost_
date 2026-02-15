import SwiftUI

/// DEFROST Inquiry View - Terminal-Style Submission Interface
/// Report input shell with Urban Noir 2.0 terminal aesthetic
struct InquiryView: View {
    @State private var encounterType: String = ""
    @State private var coordinateOverride: String = ""
    @State private var timestamp: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
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
                // MARK: - Header
                headerView
                
                // MARK: - Terminal Input Fields
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Encounter Type Field
                        terminalInputField(
                            label: "[ENCOUNTER_TYPE]",
                            placeholder: "TYPE_CLASSIFICATION",
                            text: $encounterType
                        )
                        
                        // Coordinate Override Field
                        terminalInputField(
                            label: "[COORDINATE_OVERRIDE]",
                            placeholder: "LAT_LONG_MANUAL",
                            text: $coordinateOverride
                        )
                        
                        // Timestamp Field
                        terminalInputField(
                            label: "[TIMESTAMP]",
                            placeholder: "YYYY.MM.DD_HH:MM:SS",
                            text: $timestamp
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .padding(.bottom, 280)
                }
                
                Spacer()
            }
            
            // MARK: - Swipe To Submit Footer
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    SwipeToSubmit(onCommit:{dismiss()})
                    Spacer()
                }
                .padding(.bottom, 32)
            }
        }
    }
    
    // MARK: - Header Component
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(steel)
                    .frame(width: 44, height: 44)
            }
            
            Spacer()
            
            Text("INQUIRY_MODULE")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
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
    
    // MARK: - Terminal Input Field Component
    private func terminalInputField(
        label: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Field Label
            Text(label)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(steel)
                .tracking(1)
            
            // Text Input Field
            TextField("", text: text, prompt: Text(placeholder)
                .foregroundColor(steel.opacity(0.4))
                .font(.system(size: 14, design: .monospaced))
            )
            .font(.system(size: 14, design: .monospaced))
            .foregroundColor(boneWhite)
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled(true)
            .padding(12)
            .background(obsidian)
            .overlay(
                Rectangle()
                    .stroke(steel, lineWidth: 0.5)
            )
            .cornerRadius(0)
        }
    }
}

//// MARK: - Color Extension
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 6: // RGB (24-bit)
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8: // ARGB (32-bit)
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

// MARK: - Preview
#Preview {
    InquiryView()
}
