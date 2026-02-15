import SwiftUI

/// DEFROST Help View - Know Your Rights Section
/// FAQ and guidance for encounters with ICE
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expandedSection: String? = nil
    
    // MARK: - Color Palette (No-Vibe Protocol)
    private let obsidian = Color(hex: "#080808")
    private let boneWhite = Color(hex: "#EAE7E2")
    private let steel = Color(hex: "#555555")
    private let crimson = Color(hex: "#8B0000")
    
    var body: some View {
        ZStack {
            obsidian.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - Header
                headerView
                
                // MARK: - Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Introduction
                        introSection
                        
                        // Know Your Rights Sections
                        rightsSection(
                            id: "home",
                            title: "AT_HOME",
                            icon: "house.fill",
                            content: """
• You do not have to open the door
• Ask to see a warrant through the door or window
• A warrant must be signed by a judge
• Do not open the door even if they have a warrant
• They can only enter if the warrant allows it
• You have the right to remain silent
• You do not have to answer questions about where you were born or how you entered the US
"""
                        )
                        
                        rightsSection(
                            id: "street",
                            title: "ON_THE_STREET",
                            icon: "figure.walk",
                            content: """
• Stay calm and keep your hands visible
• You have the right to remain silent
• You do not have to consent to a search
• Ask "Am I free to leave?"
• If they say yes, calmly walk away
• If they say no, say "I wish to remain silent"
• Do not run or physically resist
• Remember officer names, badge numbers, and agency
"""
                        )
                        
                        rightsSection(
                            id: "car",
                            title: "IN_A_CAR",
                            icon: "car.fill",
                            content: """
• Keep your hands on the steering wheel
• Do not consent to a search
• You and your passengers have the right to remain silent
• If you're the passenger, you can ask if you're free to leave
• If the officer says yes, sit silently or calmly leave
• Officers need reasonable suspicion to detain you
• They need probable cause to search your car
"""
                        )
                        
                        rightsSection(
                            id: "arrested",
                            title: "IF_ARRESTED",
                            icon: "exclamationmark.triangle.fill",
                            content: """
• Say "I wish to remain silent"
• Ask for a lawyer immediately
• Do not sign anything without a lawyer
• Do not discuss your immigration status
• You have the right to make a phone call
• Write down everything you remember
• Contact family, friends, or your consulate
• Remember: Anything you say can be used against you
"""
                        )
                        
                        rightsSection(
                            id: "documents",
                            title: "DOCUMENTS",
                            icon: "doc.fill",
                            content: """
• Carry proof of immigration status if you have it
• Keep copies of all important documents
• Know your A-number (Alien Registration Number)
• Have emergency contacts written down
• Carry your lawyer's contact information
• Do not show false documents
• Do not lie about your citizenship
"""
                        )
                        
                        // Emergency Contacts
                        emergencySection
                        
                        // Disclaimer
                        disclaimerSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Spacer()
            
            Text("KNOW_YOUR_RIGHTS")
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(boneWhite)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(steel)
                    .frame(width: 44, height: 44)
            }
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
    
    // MARK: - Intro Section
    private var introSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 20))
                    .foregroundColor(crimson)
                
                Text("YOUR_RIGHTS")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(boneWhite)
            }
            
            Text("Everyone in the United States has constitutional rights, regardless of immigration status. You have the right to remain silent and the right to speak to a lawyer.")
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(steel)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(obsidian)
        .overlay(
            Rectangle()
                .stroke(crimson, lineWidth: 1)
        )
    }
    
    // MARK: - Rights Section (Expandable)
    private func rightsSection(id: String, title: String, icon: String, content: String) -> some View {
        VStack(spacing: 0) {
            // Header Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if expandedSection == id {
                        expandedSection = nil
                    } else {
                        expandedSection = id
                    }
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(crimson)
                        .frame(width: 24)
                    
                    Text(title)
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(boneWhite)
                    
                    Spacer()
                    
                    Image(systemName: expandedSection == id ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(steel)
                }
                .padding(16)
                .background(obsidian)
                .overlay(
                    Rectangle()
                        .stroke(steel, lineWidth: 0.5)
                )
            }
            
            // Expandable Content
            if expandedSection == id {
                VStack(alignment: .leading, spacing: 0) {
                    Text(content)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(boneWhite)
                        .lineSpacing(6)
                        .padding(16)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(obsidian.opacity(0.5))
                .overlay(
                    Rectangle()
                        .stroke(steel, lineWidth: 0.5)
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
            }
        }
    }
    
    // MARK: - Emergency Section
    private var emergencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 18))
                    .foregroundColor(crimson)
                
                Text("EMERGENCY_CONTACTS")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(boneWhite)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                contactRow(title: "NATIONAL_IMMIGRATION_LAW", number: "1-855-234-1555")
                contactRow(title: "ACLU_IMMIGRANTS_RIGHTS", number: "1-877-881-8369")
                contactRow(title: "RAICES_HOTLINE", number: "1-844-723-2376")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(obsidian)
        .overlay(
            Rectangle()
                .stroke(steel, lineWidth: 0.5)
        )
    }
    
    private func contactRow(title: String, number: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(steel)
            
            Button(action: {
                if let url = URL(string: "tel://\(number.replacingOccurrences(of: "-", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(crimson)
                    
                    Text(number)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(boneWhite)
                }
            }
        }
    }
    
    // MARK: - Disclaimer
    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DISCLAIMER")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(steel)
            
            Text("This information is for educational purposes only and does not constitute legal advice. For specific legal guidance, consult with a qualified immigration attorney.")
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(steel.opacity(0.7))
                .lineSpacing(4)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(obsidian.opacity(0.5))
        .overlay(
            Rectangle()
                .stroke(steel, lineWidth: 0.5)
        )
    }
}

// MARK: - Preview
#Preview {
    HelpView()
}
