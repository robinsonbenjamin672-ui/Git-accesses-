import Foundation

/// AssistiveAccessManager - Manages assistive access settings persistence
///
/// This manager handles:
/// - Saving assistive access state to UserDefaults
/// - Loading saved state on app launch
/// - Providing reactive updates via @Published
/// - Default settings

class AssistiveAccessManager: ObservableObject {
    @Published var isAssistiveAccessEnabled: Bool {
        didSet {
            saveAssistiveAccessState()
        }
    }
    
    private let assistiveAccessKey = "com.app.assistiveAccess.enabled"
    private let defaultsManager = UserDefaults.standard
    
    init() {
        // Load saved state or use default (false)
        self.isAssistiveAccessEnabled = defaultsManager.bool(
            forKey: assistiveAccessKey
        )
    }
    
    /// Save the assistive access state to UserDefaults
    private func saveAssistiveAccessState() {
        defaultsManager.set(isAssistiveAccessEnabled, forKey: assistiveAccessKey)
        print("Assistive Access state saved: \(isAssistiveAccessEnabled)")
    }
    
    /// Reset to default state
    func resetToDefault() {
        isAssistiveAccessEnabled = false
        print("Assistive Access reset to default")
    }
    
    /// Clear all stored preferences
    func clearAllPreferences() {
        defaultsManager.removeObject(forKey: assistiveAccessKey)
        isAssistiveAccessEnabled = false
        print("All preferences cleared")
    }
}
