import SwiftUI

@main
struct Git_accesses_App: App {
    @StateObject private var assistiveAccessManager = AssistiveAccessManager()
    @StateObject private var chargerDetectionManager: ChargerDetectionManager
    @StateObject private var magnifierManager = MagnifierManager()
    @StateObject private var motionDetectionManager: MotionDetectionManager
    @StateObject private var callDetectionManager: CallDetectionManager
    @StateObject private var homeScreenResetManager = HomeScreenResetManager()
    
    init() {
        let accessManager = AssistiveAccessManager()
        let magnifier = MagnifierManager()
        
        _assistiveAccessManager = StateObject(wrappedValue: accessManager)
        _chargerDetectionManager = StateObject(wrappedValue: ChargerDetectionManager(assistiveAccessManager: accessManager))
        _magnifierManager = StateObject(wrappedValue: magnifier)
        _motionDetectionManager = StateObject(wrappedValue: MotionDetectionManager(magnifierManager: magnifier))
        _callDetectionManager = StateObject(wrappedValue: CallDetectionManager(assistiveAccessManager: accessManager))
        _homeScreenResetManager = StateObject(wrappedValue: HomeScreenResetManager())
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView(
                assistiveAccessManager: assistiveAccessManager,
                chargerDetectionManager: chargerDetectionManager,
                magnifierManager: magnifierManager,
                motionDetectionManager: motionDetectionManager,
                callDetectionManager: callDetectionManager,
                homeScreenResetManager: homeScreenResetManager
            )
            .preferredColorScheme(nil) // Support both light and dark mode
        }
    }
}
