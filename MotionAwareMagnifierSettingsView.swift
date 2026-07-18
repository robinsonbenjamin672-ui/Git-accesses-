import SwiftUI

/// MotionAwareMagnifierSettingsView - Manages magnifier with motion detection
///
/// This view provides:
/// - Toggle to turn magnifier on/off manually
/// - Motion detection with auto-toggle feature
/// - Real-time motion and door status display
/// - Motion sensitivity adjustment
/// - Confirmation feedback
/// - Full accessibility support

struct MotionAwareMagnifierSettingsView: View {
    @StateObject private var magnifierManager = MagnifierManager()
    @StateObject private var motionDetectionManager: MotionDetectionManager
    @State private var showConfirmation = false
    @State private var statusMessage = ""
    @State private var pendingState = false
    @State private var motionThreshold = 2.0
    
    init() {
        let manager = MagnifierManager()
        _magnifierManager = StateObject(wrappedValue: manager)
        _motionDetectionManager = StateObject(wrappedValue: MotionDetectionManager(magnifierManager: manager))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Magnifier Settings")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Control magnifier with motion detection")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Motion Status Section
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: motionDetectionManager.isMotionDetected ? "waveform.circle.fill" : "waveform.circle")
                        .font(.system(size: 20))
                        .foregroundColor(motionDetectionManager.isMotionDetected ? .blue : .gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Motion Status")
                            .font(.headline)
                        
                        Text(motionDetectionManager.isMotionDetected ? "Motion Detected" : "No Motion")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Door Status
                HStack(spacing: 12) {
                    Image(systemName: motionDetectionManager.isDoorOpen ? "door.left.hand.open" : "door.left.hand")
                        .font(.system(size: 20))
                        .foregroundColor(motionDetectionManager.isDoorOpen ? .green : .red)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Door Status")
                            .font(.headline)
                        
                        Text(motionDetectionManager.isDoorOpen ? "Door Open" : "Door Closed")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Motion Intensity Indicator
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motion Intensity: \(String(format: "%.2f", motionDetectionManager.motionIntensity))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ProgressView(value: min(motionDetectionManager.motionIntensity, 5.0) / 5.0)
                        .tint(.blue)
                }
                .padding(.top, 8)
                
                // Motion Sensitivity Slider
                VStack(alignment: .leading, spacing: 8) {
                    Text("Motion Sensitivity")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(.gray)
                        
                        Slider(value: $motionThreshold, in: 0.5...5.0, step: 0.1)
                            .onChange(of: motionThreshold) { newValue in
                                motionDetectionManager.setMotionThreshold(newValue)
                            }
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.gray)
                        
                        Text(String(format: "%.1f", motionThreshold))
                            .font(.caption)
                            .frame(width: 30)
                    }
                    .accessibilityLabel("Motion sensitivity slider")
                }
                .padding(.top, 8)
                
                // Auto-Toggle Feature
                VStack(alignment: .leading, spacing: 8) {
                    Text("Auto-Toggle on Motion")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Toggle(
                        "Automatically toggle magnifier when door opens/closes",
                        isOn: Binding(
                            get: { motionDetectionManager.isAutoToggleEnabled },
                            set: { _ in motionDetectionManager.toggleAutoToggle() }
                        )
                    )
                    .accessibilityLabel("Auto-toggle on motion")
                    .accessibilityHint(motionDetectionManager.isAutoToggleEnabled ? "Auto-toggle is enabled" : "Auto-toggle is disabled")
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Main Toggle Control
            AccessibleToggleSwitch(
                isOn: Binding(
                    get: { magnifierManager.isMagnifierEnabled },
                    set: { newValue in
                        pendingState = newValue
                        showConfirmation = true
                    }
                ),
                label: "Magnifier",
                onLabel: "Enabled",
                offLabel: "Disabled"
            )
            .padding()
            
            // Status Information
            if !statusMessage.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: magnifierManager.isMagnifierEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(magnifierManager.isMagnifierEnabled ? .green : .red)
                    
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
            
            // Motion Detection Status
            if !motionDetectionManager.statusMessage.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "waveform.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text(motionDetectionManager.statusMessage)
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
                        .fill(magnifierManager.isMagnifierEnabled ? Color.green : Color.gray)
                        .frame(width: 12, height: 12)
                    
                    Text(magnifierManager.isMagnifierEnabled ? "Magnifier is Enabled" : "Magnifier is Disabled")
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Information Section
            VStack(alignment: .leading, spacing: 12) {
                Text("How It Works")
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)
                
                Text("The motion detector uses your phone's accelerometer to detect door open/close movements. Adjust the sensitivity slider to fine-tune detection for your environment.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
            
            // Reset Button
            Button(action: {
                magnifierManager.resetToDefault()
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
                ConfirmationMagnifierView(
                    isEnabled: pendingState,
                    onConfirm: {
                        applyMagnifierSetting()
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
            Text("Changes are saved automatically. Motion detection requires accelerometer access.")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .padding()
        .navigationTitle("Settings")
        .accessibilityLabel("Magnifier Settings with Motion Detection")
    }
    
    private func applyMagnifierSetting() {
        magnifierManager.isMagnifierEnabled = pendingState
        let action = pendingState ? "enabled" : "disabled"
        statusMessage = "Magnifier has been \(action)"
        
        // Auto-dismiss status message
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                statusMessage = ""
            }
        }
        
        print("Magnifier toggled to: \(pendingState)")
    }
}

/// Confirmation View - Asks user to confirm magnifier change
struct ConfirmationMagnifierView: View {
    let isEnabled: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: isEnabled ? "checkmark.circle" : "xmark.circle")
                    .font(.system(size: 40))
                    .foregroundColor(isEnabled ? .green : .orange)
                
                Text(isEnabled ? "Enable Magnifier?" : "Disable Magnifier?")
                    .font(.headline)
                
                Text(isEnabled ?
                    "This will enable the magnifier for zoomed viewing." :
                    "This will disable the magnifier."
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
        .accessibilityLabel(isEnabled ? "Enable Magnifier confirmation" : "Disable Magnifier confirmation")
    }
}

#Preview {
    NavigationStack {
        MotionAwareMagnifierSettingsView()
    }
}
