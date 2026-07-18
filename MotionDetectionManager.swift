import Foundation
import CoreMotion

/// MotionDetectionManager - Monitors device motion to detect door open/close events
///
/// This manager handles:
/// - Detecting significant motion changes
/// - Differentiating between door open and close motions
/// - Automatically toggling magnifier based on motion
/// - Persisting motion detection preferences

class MotionDetectionManager: ObservableObject {
    @Published var isMotionDetected = false
    @Published var isDoorOpen = false
    @Published var isAutoToggleEnabled = true
    @Published var statusMessage = ""
    @Published var motionIntensity: Double = 0.0
    
    private let magnifierManager: MagnifierManager
    private let motionManager = CMMotionManager()
    private let autoToggleKey = "com.app.motion.autoToggle"
    private let defaultsManager = UserDefaults.standard
    
    private var motionThreshold: Double = 2.0 // Acceleration threshold for motion detection
    private var motionBuffer: [Double] = []
    private let bufferSize = 10
    
    init(magnifierManager: MagnifierManager) {
        self.magnifierManager = magnifierManager
        self.isAutoToggleEnabled = defaultsManager.bool(
            forKey: autoToggleKey
        ) ?? true
        
        setupMotionDetection()
    }
    
    /// Setup motion detection
    private func setupMotionDetection() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            self.processMotionData(data)
        }
        
        print("Motion detection initialized")
    }
    
    /// Process accelerometer data
    private func processMotionData(_ data: CMAccelerometerData) {
        let acceleration = sqrt(
            data.acceleration.x * data.acceleration.x +
            data.acceleration.y * data.acceleration.y +
            data.acceleration.z * data.acceleration.z
        )
        
        // Add to buffer
        motionBuffer.append(acceleration)
        if motionBuffer.count > bufferSize {
            motionBuffer.removeFirst()
        }
        
        // Update motion intensity
        motionIntensity = acceleration
        
        // Detect significant motion
        if acceleration > motionThreshold {
            isMotionDetected = true
            analyzeDoorMotion()
        } else {
            isMotionDetected = false
        }
    }
    
    /// Analyze motion pattern to determine door open/close
    private func analyzeDoorMotion() {
        guard motionBuffer.count >= bufferSize else { return }
        
        let average = motionBuffer.reduce(0, +) / Double(motionBuffer.count)
        let variance = motionBuffer.map { pow($0 - average, 2) }.reduce(0, +) / Double(motionBuffer.count)
        let stdDev = sqrt(variance)
        
        // High variance indicates opening/closing motion
        // Increasing acceleration indicates opening
        // Decreasing acceleration indicates closing
        
        let recentAvg = motionBuffer.suffix(5).reduce(0, +) / 5.0
        let olderAvg = motionBuffer.prefix(5).reduce(0, +) / 5.0
        
        if recentAvg > olderAvg && stdDev > 0.5 {
            // Motion increasing - door opening
            updateDoorState(isOpen: true)
        } else if recentAvg < olderAvg && stdDev > 0.5 {
            // Motion decreasing - door closing
            updateDoorState(isOpen: false)
        }
    }
    
    /// Update door state and toggle magnifier if auto-toggle is enabled
    private func updateDoorState(isOpen: Bool) {
        isDoorOpen = isOpen
        
        if isAutoToggleEnabled {
            magnifierManager.isMagnifierEnabled = isOpen
            statusMessage = isOpen ? "Door opened! Magnifier enabled." : "Door closed. Magnifier disabled."
            print("Door \(isOpen ? "opened" : "closed") - Magnifier \(isOpen ? "enabled" : "disabled")")
            
            // Auto-dismiss status message
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.statusMessage = ""
                }
            }
        }
    }
    
    /// Toggle auto-toggle feature
    func toggleAutoToggle() {
        isAutoToggleEnabled.toggle()
        defaultsManager.set(isAutoToggleEnabled, forKey: autoToggleKey)
        print("Motion auto-toggle set to: \(isAutoToggleEnabled)")
    }
    
    /// Enable auto-toggle
    func enableAutoToggle() {
        isAutoToggleEnabled = true
        defaultsManager.set(true, forKey: autoToggleKey)
        print("Motion auto-toggle enabled")
    }
    
    /// Disable auto-toggle
    func disableAutoToggle() {
        isAutoToggleEnabled = false
        defaultsManager.set(false, forKey: autoToggleKey)
        print("Motion auto-toggle disabled")
    }
    
    /// Adjust motion detection sensitivity
    func setMotionThreshold(_ threshold: Double) {
        motionThreshold = max(0.5, min(5.0, threshold)) // Clamp between 0.5 and 5.0
        print("Motion threshold set to: \(motionThreshold)")
    }
    
    deinit {
        motionManager.stopAccelerometerUpdates()
    }
}
