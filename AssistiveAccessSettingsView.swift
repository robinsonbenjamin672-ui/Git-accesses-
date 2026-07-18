import SwiftUI

/// AssistiveAccessSettingsView - Manages assistive access toggle with system integration
///
/// This view provides a user-friendly interface to control assistive access settings.
/// It includes:
/// - Toggle to turn assistive access on/off
/// - Status indicators
/// - Confirmation feedback
/// - Accessibility features support
/// - Persistent storage via UserDefaults

struct AssistiveAccessSettingsView: View {
    @StateObject private var manager = AssistiveAccessManager()
    @State private var showConfirmation = false
    @State private var statusMessage = ""
    @State private var pendingState = false
    
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
                isOn: Binding(
                    get: { manager.isAssistiveAccessEnabled },
                    set: { newValue in
                        pendingState = newValue
                        showConfirmation = true
                    }
                ),
                label: "Assistive Access",
                onLabel: "Enabled",
                offLabel: "Disabled"
            )
            .padding()
            
            // Status Information
            if !statusMessage.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: manager.isAssistiveAccessEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(manager.isAssistiveAccessEnabled ? .green : .red)
                    
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
            
            // Current Status Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Current Status")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                HStack(spacing: 12) {
                    Circle()
                        .fill(manager.isAssistiveAccessEnabled ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                    
                    Text(manager.isAssistiveAccessEnabled ? "Assistive Access is Enabled" : "Assistive Access is Disabled")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
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
            
            // Reset Button
            Button(action: {
                manager.resetToDefault()
                statusMessage = "Settings reset to default"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        statusMessage = ""
                    }
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset to Default")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray4))
                .foregroundColor(.black)
                .cornerRadius(8)
            }
            .padding()
            
            // Confirmation Alert
            if showConfirmation {
                ConfirmationView(
                    isEnabled: pendingState,
                    onConfirm: {
                        applyAssistiveAccessSetting()
                        showConfirmation = false
                    },
                    onCancel: {
                        showConfirmation = false
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            Spacer()
            
            // Footer Info
            Text("Changes are saved automatically. You may need to restart your app.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .padding()
        .navigationTitle("Settings")
        .accessibilityLabel("Assistive Access Settings")
    }
    
    private func applyAssistiveAccessSetting() {
        manager.isAssistiveAccessEnabled = pendingState
        let action = pendingState ? "enabled" : "disabled"
        statusMessage = "Assistive Access has been \(action)"
        
        // Auto-dismiss status message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                statusMessage = ""
            }
        }
        
        print("Assistive Access toggled to: \(pendingState)")
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
