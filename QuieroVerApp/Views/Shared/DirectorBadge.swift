import SwiftUI

/// Insignia compacta de dirección/creación: avatar circular + nombre,
/// pensada para vivir junto a la cabecera de la ficha de detalle.
///
/// `onTap` sigue el mismo patrón que `CastPersonChip`: preparado para
/// una futura ficha de director/creador, sin comportamiento hoy.
struct DirectorBadge: View {
    let person: PersonDisplayItem
    let roleLabel: String
    var onTap: (() -> Void)? = nil

    var body: some View {
        if let onTap {
            Button(action: onTap) { content }
                .buttonStyle(PressableButtonStyle(scale: 0.96))
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: Spacing.xs) {
            PersonAvatarImage(person: person, size: 32)

            VStack(alignment: .leading, spacing: 0) {
                Text(roleLabel)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(person.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.thinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.primary.opacity(0.08), lineWidth: 1))
    }
}
