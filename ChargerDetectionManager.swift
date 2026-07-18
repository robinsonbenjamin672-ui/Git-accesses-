import Foundation
import UIKit

/// ChargerDetectionManager - Monitors charging state and triggers assistive access changes
///
/// This manager:
/// - Detects when a charger is plugged in/removed
/// - Automatically toggles assistive access based on charging status
/// - Sends notifications on charging state changes
/// - Persists user preferences

class ChargerDetectionManager: ObservableObject {
    @Published var isCharging = false
    @Published var batteryLevel: Float = 0.0
    @Published var chargerDetectionEnabled = true
    
    private var assistiveAccessManager: AssistiveAccessManager
    private let chargerDetectionKey = "com.app.chargerDetection.enabled"
    private let autoToggleKey = "com.app.chargerDetection.autoToggle"
    private let defaultsManager = UserDefaults.standard
    
    static let chargerPluggedNotification = NSNotification.Name("ChargerPluggedIn")
    static let chargerUnpluggedNotification = NSNotification.Name("ChargerUnplugged")
    
    init(assistiveAccessManager: AssistiveAccessManager) {
        self.assistiveAccessManager = assistiveAccessManager
        
        // Load saved preferences
        self.chargerDetectionEnabled = defaultsManager.bool(
            forKey: chargerDetectionKey
        )
        
        // Start monitoring battery state
        setupBatteryMonitoring()
        
        // Get initial battery state
        updateBatteryState()
    }
    
    /// Setup battery monitoring
    private func setupBatteryMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryStateDidChange),
            name: UIDevice.batteryStateDidChangeNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(batteryLevelDidChange),
            name: UIDevice.batteryLevelDidChangeNotification,
            object: nil
        )
    }
    
    /// Update battery state and charging status
    @objc private func batteryStateDidChange() {
        updateBatteryState()
    }
    
    @objc private func batteryLevelDidChange() {
        DispatchQueue.main.async {
            self.batteryLevel = UIDevice.current.batteryLevel
        }
    }
    
    /// Check current battery state and handle charging changes
    private func updateBatteryState() {
        let device = UIDevice.current
        let currentBatteryState = device.batteryState
        let wasCharging = isCharging
        
        // Determine if currently charging
        let nowCharging = (currentBatteryState == .charging || currentBatteryState == .full)
        
        DispatchQueue.main.async {
            self.isCharging = nowCharging
            self.batteryLevel = device.batteryLevel
            
            // Handle state change
            if wasCharging != nowCharging {
                self.handleChargingStateChange(isNowCharging: nowCharging)
            }
        }
    }
    
    /// Handle charging state changes
    private func handleChargingStateChange(isNowCharging: Bool) {
        if chargerDetectionEnabled {
            if isNowCharging {
                handleChargerPluggedIn()
            } else {
                handleChargerUnplugged()
            }
        }
    }
    
    /// Handle when charger is plugged in
    private func handleChargerPluggedIn() {
        print("⚡ Charger plugged in - Battery level: \(Int(batteryLevel * 100))%")
        
        // Post notification
        NotificationCenter.default.post(name: Self.chargerPluggedNotification, object: nil)
        
        // Optionally toggle assistive access
        if defaultsManager.bool(forKey: autoToggleKey) {
            assistiveAccessManager.isAssistiveAccessEnabled = true
            print("✅ Assistive Access enabled on charger plugged in")
        }
    }
    
    /// Handle when charger is unplugged
    private func handleChargerUnplugged() {
        print("🔌 Charger unplugged - Battery level: \(Int(batteryLevel * 100))%")
        
        // Post notification
        NotificationCenter.default.post(name: Self.chargerUnpluggedNotification, object: nil)
        
        // Optionally toggle assistive access
        if defaultsManager.bool(forKey: autoToggleKey) {
            assistiveAccessManager.isAssistiveAccessEnabled = false
            print("❌ Assistive Access disabled on charger unplugged")
        }
    }
    
    /// Toggle charger detection on/off
    func toggleChargerDetection(_ enabled: Bool) {
        chargerDetectionEnabled = enabled
        defaultsManager.set(enabled, forKey: chargerDetectionKey)
        print("Charger detection: \(enabled ? "enabled" : "disabled")")
    }
    
    /// Toggle auto-toggle of assistive access
    func toggleAutoToggle(_ enabled: Bool) {
        defaultsManager.set(enabled, forKey: autoToggleKey)
        print("Auto-toggle assistive access: \(enabled ? "enabled" : "disabled")")
    }
    
    /// Get current battery state as readable string
    var batteryStateDescription: String {
        let device = UIDevice.current
        switch device.batteryState {
        case .unknown:
            return "Unknown"
        case .unplugged:
            return "Unplugged"
        case .charging:
            return "Charging"
        case .full:
            return "Full"
        @unknown default:
            return "Unknown"
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.isBatteryMonitoringEnabled = false
    }
}
