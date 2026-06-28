import SwiftUI

/// Botón circular flotante para añadir, anclado abajo a la derecha
/// (inspirado en el "+" de Listy). Vive en un overlay por encima del
/// contenido con un área táctil amplia y su propio gesto de tap, así
/// que ningún gesto del deck ni del scroll puede bloquearlo.
struct FloatingAddButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .foregroundStyle(.white)
                .font(.system(size: 24, weight: .semibold))
                .frame(width: 60, height: 60)
                .background(Color.accentColor, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                .shadow(color: Color.accentColor.opacity(0.45), radius: 16, x: 0, y: 8)
                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
        .accessibilityLabel("Añadir película, serie o persona")
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color(.systemGroupedBackground).ignoresSafeArea()
        FloatingAddButton {}
            .padding(24)
    }
}
