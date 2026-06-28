import SwiftUI

/// Elemento del carrusel de reparto/dirección: foto, nombre y
/// personaje (si aplica), con ancho fijo para no romper el layout.
///
/// `onTap` queda preparado para una fase futura (ficha de actor/
/// director): si se proporciona, el chip se vuelve pulsable con el
/// mismo feedback táctil que el resto de la app. Hoy no se pasa en
/// ningún sitio, así que el comportamiento actual no cambia.
struct CastPersonChip: View {
    let person: PersonDisplayItem
    var size: CGFloat = 64
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(PressableButtonStyle(scale: 0.95))
        } else {
            content
        }
    }

    private var content: some View {
        VStack(spacing: 6) {
            PersonAvatarImage(person: person, size: size)

            Text(person.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .frame(width: size + 20)

            if let character = person.character, !character.isEmpty {
                Text(character)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: size + 20)
            }
        }
    }
}
