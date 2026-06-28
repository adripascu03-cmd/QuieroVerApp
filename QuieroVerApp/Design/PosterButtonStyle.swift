import SwiftUI

/// Pequeño feedback táctil al tocar un poster: una compresión sutil,
/// no teatral, mientras se abre la ficha de detalle.
struct PosterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
