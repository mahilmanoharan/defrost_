import SwiftUI

/// DEFROST Swipe To Submit Component - Vertical Drag Interaction
/// Urban Noir 2.0 haptic-feedback swipe mechanism for report submission
struct SwipeToSubmit: View {
    @State private var dragOffset: CGFloat = 0
    @State private var isCompleted: Bool = false
    
    var onCommit: () -> Void = {}
    // MARK: - Interaction Constants
    private let swipeThreshold: CGFloat = -200
    private let trackHeight: CGFloat = 240
    private let handleHeight: CGFloat = 60
    private let hapticNotchInterval: CGFloat = 40
    
    // MARK: - Haptic Generators
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    
    // MARK: - Color Palette (No-Vibe Protocol)
    private let obsidian = Color(hex: "#080808")
    private let boneWhite = Color(hex: "#EAE7E2")
    private let steel = Color(hex: "#555555")
    private let crimson = Color(hex: "#8B0000")
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Track Background
            Rectangle()
                .fill(obsidian)
                .frame(width: 80, height: trackHeight)
                .overlay(
                    Rectangle()
                        .stroke(steel, lineWidth: 0.5)
                )
                .cornerRadius(0)
            
            // Progress Indicator Fill
            Rectangle()
                .fill(crimson.opacity(progressOpacity))
                .frame(width: 365, height: max(0, abs(dragOffset)))
                .cornerRadius(0)
            
            // Swipeable Handle
            swipeHandle
                .offset(y: dragOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            handleDragChanged(value)
                        }
                        .onEnded { _ in
                            handleDragEnded()
                        }
                )
        }
        .frame(height: trackHeight)
        .onAppear {
            impactGenerator.prepare()
            notificationGenerator.prepare()
        }
    }
    
    // MARK: - Swipe Handle Component
    private var swipeHandle: some View {
        VStack(spacing: 4) {
            // Chevron Indicators
            ForEach(0..<1, id: \.self) { _ in
                Image(systemName: "arrow.up")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(boneWhite)
            }
            
            Text("SWIPE")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundColor(boneWhite)
        }
        .frame(width: 375, height: handleHeight)
        .background(crimson)
        .overlay(
            Rectangle()
                .stroke(steel, lineWidth: 0.5)
        )
        .cornerRadius(12)
    }
    
    // MARK: - Drag Handlers
    private func handleDragChanged(_ value: DragGesture.Value) {
        // Only allow upward drag (negative translation)
        let translation = min(0, value.translation.height)
        dragOffset = translation
        
        // Haptic notch feedback at intervals
        let currentNotch = Int(abs(translation) / hapticNotchInterval)
        let previousNotch = Int(abs(dragOffset - value.translation.height) / hapticNotchInterval)
        
        if currentNotch > previousNotch {
            impactGenerator.impactOccurred()
        }
        
        // Pre-completion haptic at threshold
        if abs(translation) >= abs(swipeThreshold) && !isCompleted {
            notificationGenerator.notificationOccurred(.warning)
            isCompleted = true
        }
    }
    
    private func handleDragEnded() {
        // Check if threshold was reached
        if dragOffset <= swipeThreshold {
            // Successful submission
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onCommit()
            }
            
            notificationGenerator.notificationOccurred(.success)
            print("TRANSMISSION_INITIATED")
            
            
            // Reset with animation
            withAnimation(Animation.easeIn(duration: 0.3)) {
                dragOffset = 0
            }
            isCompleted = false
        } else {
            // Failed attempt - snap back
            withAnimation(Animation.easeIn(duration: 0.2)) {
                dragOffset = 0
            }
            isCompleted = false
        }
    }
    
    // MARK: - Computed Properties
    private var progressOpacity: Double {
        let progress = abs(dragOffset) / abs(swipeThreshold)
        return min(1.0, progress * 0.6)
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
    ZStack {
        Color(hex: "#080808").ignoresSafeArea()
        
        SwipeToSubmit()
    }
}
