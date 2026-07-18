import Foundation
import UIKit

/// ChargerDetectionManager - Monitors device charging state and toggles assistive access
///
/// This manager handles:
/// - Detecting when charger is plugged in/removed
/// - Automatically toggling assistive access based on charging status
/// - Sending notifications to the user
/// - Persisting charger detection preferences

class ChargerDetectionManager: ObservableObject {
    @Published var isChargerConnected = false
    @Published var isAutoToggleEnabled = true
    @Published var statusMessage = ""
    
    private let assistiveAccessManager: AssistiveAccessManager
    private let autoToggleKey = "com.app.charger.autoToggle"
    private let defaultsManager = UserDefaults.standard
    
    init(assistiveAccessManager: AssistiveAccessManager) {
        self.assistiveAccessManager = assistiveAccessManager
        self.isAutoToggleEnabled = defaultsManager.bool(
            forKey: autoToggleKey
        ) ?? true
        
        setupBatteryMonitoring()
        checkCurrentChargerStatus()
    }
    
    /// Setup battery state monitoring
    private func setupBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Listen for battery state changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        
        print("Battery monitoring enabled")
    }
    
    /// Check current charger status
    private func checkCurrentChargerStatus() {
        let state = UIDevice.current.batteryState
        isChargerConnected = (state == .charging || state == .full)
        print("Current charger status: \(isChargerConnected ? \"Connected\" : \"Disconnected\")")
    }
    
    /// Handle battery state changes
    @objc private func batteryStateDidChange() {
        DispatchQueue.main.async {
            self.checkCurrentChargerStatus()
            
            if self.isAutoToggleEnabled {
                self.handleChargerStatusChange()
            }
        }
    }
    
    /// Handle charger connection/disconnection
    private func handleChargerStatusChange() {
        if isChargerConnected {
            assistiveAccessManager.isAssistiveAccessEnabled = true
            statusMessage = "Charger detected! Assistive Access enabled."
            print("Charger plugged in - Assistive Access enabled")
        } else {
            assistiveAccessManager.isAssistiveAccessEnabled = false
            statusMessage = "Charger removed. Assistive Access disabled."
            print("Charger removed - Assistive Access disabled")
        }
        
        // Auto-dismiss status message
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                self.statusMessage = ""
            }
        }
    }
    
    /// Toggle auto-toggle feature
    func toggleAutoToggle() {
        isAutoToggleEnabled.toggle()
        defaultsManager.set(isAutoToggleEnabled, forKey: autoToggleKey)
        print("Auto-toggle set to: \(isAutoToggleEnabled)")
    }
    
    /// Enable auto-toggle
    func enableAutoToggle() {
        isAutoToggleEnabled = true
        defaultsManager.set(true, forKey: autoToggleKey)
        print("Auto-toggle enabled")
    }
    
    /// Disable auto-toggle
    func disableAutoToggle() {
        isAutoToggleEnabled = false
        defaultsManager.set(false, forKey: autoToggleKey)
        print("Auto-toggle disabled")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
}