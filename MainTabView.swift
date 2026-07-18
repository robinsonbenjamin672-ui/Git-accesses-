import SwiftUI

/// MainTabView - Main navigation hub for all automation systems
///
/// This view provides access to:
/// - Dashboard with all system statuses
/// - Call detection and assistive access
/// - Charger detection and assistive access
/// - Motion detection and magnifier
/// - Home screen reset
/// - Unified settings

struct MainTabView: View {
    @ObservedObject var assistiveAccessManager: AssistiveAccessManager
    @ObservedObject var chargerDetectionManager: ChargerDetectionManager
    @ObservedObject var magnifierManager: MagnifierManager
    @ObservedObject var motionDetectionManager: MotionDetectionManager
    @ObservedObject var callDetectionManager: CallDetectionManager
    @ObservedObject var homeScreenResetManager: HomeScreenResetManager
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Dashboard Tab
            DashboardView(
                assistiveAccessManager: assistiveAccessManager,
                chargerDetectionManager: chargerDetectionManager,
                magnifierManager: magnifierManager,
                motionDetectionManager: motionDetectionManager,
                callDetectionManager: callDetectionManager
            )
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2")
            }
            .tag(0)
            
            // Call & Assistive Access Tab
            CallAwareAssistiveAccessView(
                assistiveAccessManager: assistiveAccessManager,
                callDetectionManager: callDetectionManager,
                homeScreenResetManager: homeScreenResetManager
            )
            .tabItem {
                Label("Calls", systemImage: "phone.fill")
            }
            .tag(1)
            
            // Charger & Assistive Access Tab
            ChargerAwareAssistiveAccessSettingsView(
                assistiveAccessManager: assistiveAccessManager,
                chargerDetectionManager: chargerDetectionManager
            )
            .tabItem {
                Label("Charger", systemImage: "bolt.fill")
            }
            .tag(2)
            
            // Motion & Magnifier Tab
            MotionAwareMagnifierSettingsView(
                magnifierManager: magnifierManager,
                motionDetectionManager: motionDetectionManager
            )
            .tabItem {
                Label("Motion", systemImage: "waveform.circle")
            }
            .tag(3)
            
            // Settings Tab
            SettingsView(
                assistiveAccessManager: assistiveAccessManager,
                chargerDetectionManager: chargerDetectionManager,
                magnifierManager: magnifierManager,
                motionDetectionManager: motionDetectionManager,
                callDetectionManager: callDetectionManager,
                homeScreenResetManager: homeScreenResetManager
            )
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(4)
        }
        .accessibilityElement(children: .contain)
    }
}

/// Dashboard View - Overview of all system statuses
struct DashboardView: View {
    @ObservedObject var assistiveAccessManager: AssistiveAccessManager
    @ObservedObject var chargerDetectionManager: ChargerDetectionManager
    @ObservedObject var magnifierManager: MagnifierManager
    @ObservedObject var motionDetectionManager: MotionDetectionManager
    @ObservedObject var callDetectionManager: CallDetectionManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Dashboard")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Overview of all automation systems")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // Assistive Access Status
                StatusCardView(
                    title: "Assistive Access",
                    icon: "accessibility",
                    isEnabled: assistiveAccessManager.isAssistiveAccessEnabled,
                    status: assistiveAccessManager.isAssistiveAccessEnabled ? "Enabled" : "Disabled"
                )
                
                // Charger Status
                StatusCardView(
                    title: "Charger Detection",
                    icon: "bolt.fill",
                    isEnabled: chargerDetectionManager.isChargerConnected,
                    status: chargerDetectionManager.isChargerConnected ? "Connected" : "Disconnected"
                )
                
                // Magnifier Status
                StatusCardView(
                    title: "Magnifier",
                    icon: "magnifyingglass",
                    isEnabled: magnifierManager.isMagnifierEnabled,
                    status: magnifierManager.isMagnifierEnabled ? "Enabled" : "Disabled"
                )
                
                // Motion Detection Status
                StatusCardView(
                    title: "Motion Detection",
                    icon: "waveform.circle.fill",
                    isEnabled: motionDetectionManager.isMotionDetected,
                    status: motionDetectionManager.isDoorOpen ? "Door Open" : "Door Closed"
                )
                
                // Call Status
                StatusCardView(
                    title: "Call Status",
                    icon: "phone.fill",
                    isEnabled: callDetectionManager.isCallActive,
                    status: callDetectionManager.isCallActive ? "Call Active" : "No Call"
                )
                
                // System Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("System Summary")
                        .font(.headline)
                        .accessibilityAddTraits(.isHeader)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Auto-Toggles Enabled")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(String(countAutoToggles()))
                                .font(.headline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Systems Active")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(String(countActiveSystems()))
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
    
    private func countAutoToggles() -> Int {
        var count = 0
        if chargerDetectionManager.isAutoToggleEnabled { count += 1 }
        if motionDetectionManager.isAutoToggleEnabled { count += 1 }
        if callDetectionManager.isAutoToggleEnabled { count += 1 }
        return count
    }
    
    private func countActiveSystems() -> Int {
        var count = 0
        if assistiveAccessManager.isAssistiveAccessEnabled { count += 1 }
        if magnifierManager.isMagnifierEnabled { count += 1 }
        if chargerDetectionManager.isChargerConnected { count += 1 }
        if motionDetectionManager.isMotionDetected { count += 1 }
        if callDetectionManager.isCallActive { count += 1 }
        return count
    }
}

/// Status Card View - Displays individual system status
struct StatusCardView: View {
    let title: String
    let icon: String
    let isEnabled: Bool
    let status: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isEnabled ? .green : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Circle()
                .fill(isEnabled ? Color.green : Color.gray)
                .frame(width: 12, height: 12)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Custom Initializers for Views

extension CallAwareAssistiveAccessView {
    init(
        assistiveAccessManager: AssistiveAccessManager,
        callDetectionManager: CallDetectionManager,
        homeScreenResetManager: HomeScreenResetManager
    ) {
        self._assistiveAccessManager = StateObject(wrappedValue: assistiveAccessManager)
        self._callDetectionManager = StateObject(wrappedValue: callDetectionManager)
        self._homeScreenResetManager = StateObject(wrappedValue: homeScreenResetManager)
    }
}

extension ChargerAwareAssistiveAccessSettingsView {
    init(
        assistiveAccessManager: AssistiveAccessManager,
        chargerDetectionManager: ChargerDetectionManager
    ) {
        self._assistiveAccessManager = StateObject(wrappedValue: assistiveAccessManager)
        self._chargerDetectionManager = StateObject(wrappedValue: chargerDetectionManager)
    }
}

extension MotionAwareMagnifierSettingsView {
    init(
        magnifierManager: MagnifierManager,
        motionDetectionManager: MotionDetectionManager
    ) {
        self._magnifierManager = StateObject(wrappedValue: magnifierManager)
        self._motionDetectionManager = StateObject(wrappedValue: motionDetectionManager)
    }
}

#Preview {
    let accessManager = AssistiveAccessManager()
    let chargerManager = ChargerDetectionManager(assistiveAccessManager: accessManager)
    let magnifierManager = MagnifierManager()
    let motionManager = MotionDetectionManager(magnifierManager: magnifierManager)
    let callManager = CallDetectionManager(assistiveAccessManager: accessManager)
    let resetManager = HomeScreenResetManager()
    
    return MainTabView(
        assistiveAccessManager: accessManager,
        chargerDetectionManager: chargerManager,
        magnifierManager: magnifierManager,
        motionDetectionManager: motionManager,
        callDetectionManager: callManager,
        homeScreenResetManager: resetManager
    )
}
