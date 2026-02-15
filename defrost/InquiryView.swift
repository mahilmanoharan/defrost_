import SwiftUI
import PhotosUI
import CoreLocation

/// DEFROST Inquiry View - Terminal-Style Submission Interface
/// Report input shell with Urban Noir 2.0 terminal aesthetic
struct InquiryView: View {
    // Report fields
    @State private var threatType: String = ""
    @State private var locationName: String = ""
    @State private var description: String = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    
    // Location
    @StateObject private var locationManager = LocationManager()
    
    @Environment(\.dismiss) private var dismiss
    
    // Callback for when submission is complete
    var onSubmit: () -> Void
    
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
                        // Threat Type Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("[THREAT_TYPE]")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(steel)
                                .tracking(1)
                            
                            HStack(spacing: 8) {
                                ForEach(["CHECKPOINT", "PATROL", "RAID"], id: \.self) { type in
                                    Button(action: {
                                        threatType = type
                                    }) {
                                        Text(type)
                                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                                            .foregroundColor(threatType == type ? obsidian : boneWhite)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(threatType == type ? boneWhite : Color.clear)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(threatType == type ? boneWhite : steel, lineWidth: 0.5)
                                            )
                                    }
                                }
                            }
                        }
                        
                        // Location Name Field
                        terminalInputField(
                            label: "[LOCATION_NAME]",
                            placeholder: "AREA_DESCRIPTION",
                            text: $locationName
                        )
                        
                        // Auto-detected Location Display
                        VStack(alignment: .leading, spacing: 8) {
                            Text("[GPS_COORDINATES]")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(steel)
                                .tracking(1)
                            
                            HStack(spacing: 8) {
                                if locationManager.isAuthorized {
                                    if let location = locationManager.location {
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "location.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(crimson)
                                                
                                                Text("LAT: \(String(format: "%.4f", location.coordinate.latitude))")
                                                    .font(.system(size: 12, design: .monospaced))
                                                    .foregroundColor(boneWhite)
                                            }
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "location.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(crimson)
                                                
                                                Text("LON: \(String(format: "%.4f", location.coordinate.longitude))")
                                                    .font(.system(size: 12, design: .monospaced))
                                                    .foregroundColor(boneWhite)
                                            }
                                        }
                                    } else {
                                        HStack(spacing: 6) {
                                            ProgressView()
                                                .tint(crimson)
                                            
                                            Text("ACQUIRING_LOCATION...")
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(steel)
                                        }
                                    }
                                } else {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .font(.system(size: 12))
                                                .foregroundColor(crimson)
                                            
                                            Text("LOCATION_ACCESS_REQUIRED")
                                                .font(.system(size: 12, design: .monospaced))
                                                .foregroundColor(crimson)
                                        }
                                        
                                        Button(action: {
                                            locationManager.requestLocation()
                                        }) {
                                            HStack {
                                                Image(systemName: "location.circle.fill")
                                                    .font(.system(size: 14))
                                                
                                                Text("ENABLE_LOCATION")
                                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                            }
                                            .foregroundColor(obsidian)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(crimson)
                                            .overlay(
                                                Rectangle()
                                                    .stroke(crimson, lineWidth: 0.5)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(obsidian)
                            .overlay(
                                Rectangle()
                                    .stroke(steel, lineWidth: 0.5)
                            )
                        }
                        
                        // Description Field (Multi-line)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("[DESCRIPTION]")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(steel)
                                .tracking(1)
                            
                            TextEditor(text: $description)
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(boneWhite)
                                .scrollContentBackground(.hidden)
                                .frame(height: 120)
                                .padding(12)
                                .background(obsidian)
                                .overlay(
                                    Rectangle()
                                        .stroke(steel, lineWidth: 0.5)
                                )
                        }
                        
                        // Image Upload
                        VStack(alignment: .leading, spacing: 8) {
                            Text("[PHOTO_EVIDENCE]")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(steel)
                                .tracking(1)
                            
                            PhotosPicker(selection: $selectedImage, matching: .images) {
                                HStack {
                                    Image(systemName: imageData != nil ? "photo.fill" : "photo")
                                        .font(.system(size: 20))
                                        .foregroundColor(steel)
                                    
                                    Text(imageData != nil ? "IMAGE_SELECTED" : "ATTACH_IMAGE")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(boneWhite)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12))
                                        .foregroundColor(steel)
                                }
                                .padding(12)
                                .background(obsidian)
                                .overlay(
                                    Rectangle()
                                        .stroke(steel, lineWidth: 0.5)
                                )
                            }
                            .onChange(of: selectedImage) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                        imageData = data
                                    }
                                }
                            }
                        }
                        
                        // Auto-timestamp info
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundColor(steel)
                            
                            Text("TIMESTAMP_AUTO_GENERATED")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(steel.opacity(0.7))
                        }
                        .padding(.top, 8)
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
                    SwipeToSubmit(onCommit: {
                        dismiss()
                        onSubmit()
                    })
                    Spacer()
                }
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            locationManager.requestLocation()
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
            
            // Empty space for symmetry
            Spacer()
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
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
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
            .keyboardType(keyboardType)
            .padding(12)
            .background(obsidian)
            .overlay(
                Rectangle()
                    .stroke(steel, lineWidth: 0.5)
            )
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
    InquiryView(onSubmit: {
        print("Report submitted")
    })
}
