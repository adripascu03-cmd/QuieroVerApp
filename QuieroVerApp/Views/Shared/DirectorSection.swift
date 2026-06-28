import SwiftUI

/// Línea compacta de dirección/creación: avatar circular pequeño +
/// "Dirección · Nombre". Pensada para vivir DENTRO de `GlassInfoPanel`,
/// junto al título y los metadatos — no como elemento flotante propio,
/// para que componga como parte del mismo grupo en vez de sentirse
/// suelta sobre el backdrop.
///
/// `onTap` sigue el mismo patrón que `CastPersonChip`: si se
/// proporciona, la línea se vuelve pulsable con el mismo feedback
/// táctil que el resto de la app.
struct DirectorBadge: View {
    let person: PersonDisplayItem
    let roleLabel: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(PressableButtonStyle(scale: 0.97))
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: 6) {
            PersonAvatarImage(person: person, size: 22)
            Text("\(roleLabel) · \(person.name)")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
