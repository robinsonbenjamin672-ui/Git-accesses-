import Foundation
import Network

/// MagnifierManager - Manages magnifier settings persistence
///
/// This manager handles:
/// - Saving magnifier state to UserDefaults
/// - Loading saved state on app launch
/// - Providing reactive updates via @Published
/// - Default settings

class MagnifierManager: ObservableObject {
    @Published var isMagnifierEnabled: Bool {
        didSet {
            saveMagnifierState()
        }
    }
    
    private let magnifierKey = "com.app.magnifier.enabled"
    private let defaultsManager = UserDefaults.standard
    
    init() {
        // Load saved state or use default (false)
        self.isMagnifierEnabled = defaultsManager.bool(
            forKey: magnifierKey
        )
    }
    
    /// Save the magnifier state to UserDefaults
    private func saveMagnifierState() {
        defaultsManager.set(isMagnifierEnabled, forKey: magnifierKey)
        print("Magnifier state saved: \(isMagnifierEnabled)")
    }
    
    /// Reset to default state
    func resetToDefault() {
        isMagnifierEnabled = false
        print("Magnifier reset to default")
    }
    
    /// Clear all stored preferences
    func clearAllPreferences() {
        defaultsManager.removeObject(forKey: magnifierKey)
        isMagnifierEnabled = false
        print("All magnifier preferences cleared")
    }
}
