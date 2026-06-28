import SwiftUI

/// Entrada para añadir contenido, integrada en la cabecera: visible
/// pero discreta, no domina la parte superior de la galería.
struct CompactAddCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .foregroundStyle(Color.accentColor)
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(.thinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
        }
        .buttonStyle(PressableButtonStyle(scale: 0.92))
        .accessibilityLabel("Añadir película o serie")
    }
}
