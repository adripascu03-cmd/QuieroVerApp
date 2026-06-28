import SwiftUI

/// Botón circular translúcido para los toolbars de las fichas (atrás,
/// volver a galería, favorito). Sustituye los controles azules por
/// defecto por un control limpio que flota bien sobre el hero.
///
/// `foregroundStyle` va ANTES de `font` a propósito: encadenar `.font`
/// directamente sobre un `Image` es "Ambiguous use of 'font'" en el
/// toolchain de Xcode 15.2 — anteponer otro modificador lo resuelve.
struct CircleIconButton: View {
    let systemName: String
    var tint: Color = .primary
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .foregroundStyle(tint)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 38, height: 38)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.18), lineWidth: 0.5))
                .shadow(color: .black.opacity(0.14), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.9))
    }
}
