import SwiftUI

/// AccessibleToggleSwitch - A fully accessible iOS toggle switch component built with SwiftUI
///
/// This component provides:
/// - VoiceOver support with custom accessibility labels and hints
/// - Dynamic Type support for font scaling
/// - Full accessibility feature support (voice control, switch control, etc.)
/// - Smooth animations and visual feedback
/// - Haptic feedback for user interaction
///
/// Example usage:
/// ```
/// @State private var isEnabled = false
///
/// AccessibleToggleSwitch(
///     isOn: $isEnabled,
///     label: "Assistive Access",
///     onLabel: "On",
///     offLabel: "Off"
/// )
/// ```

struct AccessibleToggleSwitch: View {
    @Binding var isOn: Bool
    let label: String
    let onLabel: String
    let offLabel: String
    var onToggle: (() -> Void)? = nil
    
    @Environment(\.sizeCategory) var sizeCategory
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .accessibilityLabel(label)
                
                Spacer()
                
                // Toggle Switch
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isOn ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 56, height: 32)
                    
                    HStack {
                        if isOn {
                            Spacer()
                        }
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                        
                        if !isOn {
                            Spacer()
                        }
                    }
                    .padding(2)
                    .frame(width: 56, height: 32)
                }
                .onTapGesture {
                    handleToggle()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
                .accessibilityValue(isOn ? onLabel : offLabel)
                .accessibilityHint("Double tap to toggle \(label)")
                .accessibilityAddTraits(isOn ? .isSelected : [])
                .accessibilityRespondsToUserInteraction(true)
            }
            
            // Status text for additional clarity
            Text(isOn ? "Currently: \(onLabel)" : "Currently: \(offLabel)")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityLabel("Status: \(isOn ? onLabel : offLabel)")
        }
        .padding(.vertical, 8)
        .dynamicallyScaledPadding()
    }
    
    private func handleToggle() {
        hapticFeedback.impactOccurred()
        withAnimation(.easeInOut(duration: 0.3)) {
            isOn.toggle()
        }
        onToggle?()
    }
}

/// Extension to support Dynamic Type with responsive padding
extension View {
    func dynamicallyScaledPadding() -> some View {
        self.modifier(DynamicScalingModifier())
    }
}

struct DynamicScalingModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    func body(content: Content) -> some View {
        let isAccessibilitySize = sizeCategory > .extraLarge
        let horizontalPadding: CGFloat = isAccessibilitySize ? 12 : 8
        
        return content
            .padding(.horizontal, horizontalPadding)
    }
}

#Preview {
    @State var isEnabled = false
    @State var voiceOverEnabled = false
    
    return VStack(spacing: 24) {
        AccessibleToggleSwitch(
            isOn: $isEnabled,
            label: "Assistive Access",
            onLabel: "Enabled",
            offLabel: "Disabled",
            onToggle: {
                print("Assistive Access toggled to: \(isEnabled)")
            }
        )
        
        AccessibleToggleSwitch(
            isOn: $voiceOverEnabled,
            label: "VoiceOver Support",
            onLabel: "On",
            offLabel: "Off"
        )
        
        Spacer()
    }
    .padding()
}
