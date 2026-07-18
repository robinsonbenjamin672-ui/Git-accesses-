import SwiftUI

/// SettingsView - Unified settings hub for all automation systems
///
/// This view provides:
/// - Global settings and preferences
/// - Individual system configuration
/// - Reset and clear options
/// - About and version information

struct SettingsView: View {
    @ObservedObject var assistiveAccessManager: AssistiveAccessManager
    @ObservedObject var chargerDetectionManager: ChargerDetectionManager
    @ObservedObject var magnifierManager: MagnifierManager
    @ObservedObject var motionDetectionManager: MotionDetectionManager
    @ObservedObject var callDetectionManager: CallDetectionManager
    @ObservedObject var homeScreenResetManager: HomeScreenResetManager
    
    @State private var showClearAllConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Auto-Toggle Settings Section
                Section(header: Text("Auto-Toggle Settings").accessibilityAddTraits(.isHeader)) {
                    Toggle("Charger Auto-Toggle", isOn: Binding(
                        get: { chargerDetectionManager.isAutoToggleEnabled },
                        set: { _ in chargerDetectionManager.toggleAutoToggle() }
                    ))
                    .accessibilityLabel("Charger auto-toggle")
                    
                    Toggle("Motion Auto-Toggle", isOn: Binding(
                        get: { motionDetectionManager.isAutoToggleEnabled },
                        set: { _ in motionDetectionManager.toggleAutoToggle() }
                    ))
                    .accessibilityLabel("Motion auto-toggle")
                    
                    Toggle("Call Auto-Toggle", isOn: Binding(
                        get: { callDetectionManager.isAutoToggleEnabled },
                        set: { _ in callDetectionManager.toggleAutoToggle() }
                    ))
                    .accessibilityLabel("Call auto-toggle")
                }
                
                // Feature Status Section
                Section(header: Text("Feature Status").accessibilityAddTraits(.isHeader)) {
                    HStack {
                        Text("Assistive Access")
                        Spacer()
                        Text(assistiveAccessManager.isAssistiveAccessEnabled ? "Enabled" : "Disabled")
                            .foregroundColor(assistiveAccessManager.isAssistiveAccessEnabled ? .green : .gray)
                    }
                    
                    HStack {
                        Text("Magnifier")
                        Spacer()
                        Text(magnifierManager.isMagnifierEnabled ? "Enabled" : "Disabled")
                            .foregroundColor(magnifierManager.isMagnifierEnabled ? .green : .gray)
                    }
                    
                    HStack {
                        Text("Charger Connected")
                        Spacer()
                        Text(chargerDetectionManager.isChargerConnected ? "Yes" : "No")
                            .foregroundColor(chargerDetectionManager.isChargerConnected ? .green : .gray)
                    }
                    
                    HStack {
                        Text("Motion Detected")
                        Spacer()
                        Text(motionDetectionManager.isMotionDetected ? "Yes" : "No")
                            .foregroundColor(motionDetectionManager.isMotionDetected ? .green : .gray)
                    }
                    
                    HStack {
                        Text("Call Active")
                        Spacer()
                        Text(callDetectionManager.isCallActive ? "Yes" : "No")
                            .foregroundColor(callDetectionManager.isCallActive ? .green : .gray)
                    }
                }
                
                // Reset Options Section
                Section(header: Text("Reset Options").accessibilityAddTraits(.isHeader)) {
                    Button(action: {
                        assistiveAccessManager.resetToDefault()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Assistive Access")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        magnifierManager.resetToDefault()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Reset Magnifier")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        callDetectionManager.clearCallHistory()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Call History")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        homeScreenResetManager.clearResetHistory()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Clear Reset History")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Clear All Section
                Section {
                    Button(action: {
                        showClearAllConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("Clear All Settings")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.red)
                    }
                }
                
                // About Section
                Section(header: Text("About").accessibilityAddTraits(.isHeader)) {
                    HStack {
                        Text("App Name")
                        Spacer()
                        Text("Git-accesses")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Information Section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This app provides automated control over accessibility features based on various device events including charger connection, motion detection, and phone calls.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Clear All Settings?",
                isPresented: $showClearAllConfirmation,
                actions: {
                    Button("Clear All", role: .destructive) {
                        assistiveAccessManager.resetToDefault()
                        magnifierManager.resetToDefault()
                        chargerDetectionManager.disableAutoToggle()
                        motionDetectionManager.disableAutoToggle()
                        callDetectionManager.disableAutoToggle()
                        callDetectionManager.clearCallHistory()
                        homeScreenResetManager.clearResetHistory()
                    }
                },
                message: {
                    Text("This will reset all settings to their default values. This action cannot be undone.")
                }
            )
        }
    }
}

#Preview {
    let accessManager = AssistiveAccessManager()
    let chargerManager = ChargerDetectionManager(assistiveAccessManager: accessManager)
    let magnifierManager = MagnifierManager()
    let motionManager = MotionDetectionManager(magnifierManager: magnifierManager)
    let callManager = CallDetectionManager(assistiveAccessManager: accessManager)
    let resetManager = HomeScreenResetManager()
    
    return SettingsView(
        assistiveAccessManager: accessManager,
        chargerDetectionManager: chargerManager,
        magnifierManager: magnifierManager,
        motionDetectionManager: motionManager,
        callDetectionManager: callManager,
        homeScreenResetManager: resetManager
    )
}
