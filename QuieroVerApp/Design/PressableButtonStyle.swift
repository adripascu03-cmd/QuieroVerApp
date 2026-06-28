import SwiftUI

/// Feedback táctil consistente al tocar tarjetas y botones: una
/// compresión sutil, no teatral. Se usa en posters, tarjetas y CTAs.
struct PressableButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
