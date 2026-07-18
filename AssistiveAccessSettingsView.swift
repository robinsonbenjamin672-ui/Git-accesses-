import SwiftUI

/// AssistiveAccessSettingsView - Manages assistive access toggle with system integration
///
/// This view provides a user-friendly interface to control assistive access settings.
/// It includes:
/// - Toggle to turn assistive access on/off
/// - Status indicators
/// - Confirmation feedback
/// - Accessibility features support

struct AssistiveAccessSettingsView: View {
    @State private var isAssistiveAccessEnabled = false
    @State private var showConfirmation = false
    @State private var statusMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Assistive Access Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Control accessibility features on your device")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Main Toggle Control
            AccessibleToggleSwitch(
                isOn: $isAssistiveAccessEnabled,
                label: "Assistive Access",
                onLabel: "Enabled",
                offLabel: "Disabled",
                onToggle: {
                    handleAssistiveAccessToggle()
                }
            )
            .padding()
            
            // Status Information
            if !statusMessage.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: isAssistiveAccessEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(isAssistiveAccessEnabled ? .green : .red)
                    
                    Text(statusMessage)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .transition(.scale.combined(with: .opacity))
            }
            
            // Information Section
            VStack(alignment: .leading, spacing: 12) {
                Text("What is Assistive Access?")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text("Assistive Access simplifies the iPhone interface for people who need a higher level of support. When enabled, it provides streamlined controls and focused features.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Confirmation Alert
            if showConfirmation {
                ConfirmationView(
                    isEnabled: isAssistiveAccessEnabled,
                    onConfirm: {
                        applyAssistiveAccessSetting()
                        showConfirmation = false
                    },
                    onCancel: {
                        isAssistiveAccessEnabled.toggle()
                        showConfirmation = false
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            // Footer Info
            Text("Changes take effect immediately. You may need to restart your app.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .padding()
        .navigationTitle("Settings")
        .accessibilityLabel("Assistive Access Settings")
    }
    
    private func handleAssistiveAccessToggle() {
        showConfirmation = true
    }
    
    private func applyAssistiveAccessSetting() {
        let action = isAssistiveAccessEnabled ? "enabled" : "disabled"
        statusMessage = "Assistive Access has been \(action)"
        
        // Here you would implement actual system integration
        // For now, this provides UI feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                statusMessage = ""
            }
        }
        
        // Log the change
        print("Assistive Access toggled to: \(isAssistiveAccessEnabled)")
    }
}

/// Confirmation View - Asks user to confirm assistive access change
struct ConfirmationView: View {
    let isEnabled: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: isEnabled ? "checkmark.circle" : "xmark.circle")
                    .font(.system(size: 40))
                    .foregroundColor(isEnabled ? .green : .orange)
                
                Text(isEnabled ? "Enable Assistive Access?" : "Disable Assistive Access?")
                    .font(.headline)
                
                Text(isEnabled ?
                    "This will enable simplified controls and focused features." :
                    "This will return you to the standard iPhone interface."
                )
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            }
            .padding()
            
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray4))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
                
                Button(action: onConfirm) {
                    Text(isEnabled ? "Enable" : "Disable")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isEnabled ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(isEnabled ? "Enable Assistive Access confirmation" : "Disable Assistive Access confirmation")
    }
}

#Preview {
    NavigationStack {
        AssistiveAccessSettingsView()
    }
}
