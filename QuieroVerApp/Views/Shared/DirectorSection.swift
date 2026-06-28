import SwiftUI

/// Tarjeta de dirección/creación: foto grande, nombre, pulsable. Vive
/// como su propia sección en la ficha de detalle (entre Sinopsis y
/// Reparto), con el título "Dirección"/"Creación" aportado por el
/// `SectionBlock` que la envuelve — bien integrada, no un badge suelto.
///
/// `onTap` sigue el mismo patrón que `CastPersonChip`: si se
/// proporciona, la tarjeta se vuelve pulsable con el mismo feedback
/// táctil que el resto de la app.
struct DirectorSection: View {
    let person: PersonDisplayItem
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
        HStack(spacing: Spacing.md) {
            PersonAvatarImage(person: person, size: 56)

            Text(person.name)
                .font(.headline)
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: Spacing.xs)

            if onTap != nil {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.footnote.weight(.semibold))
            }
        }
        .padding(Spacing.sm)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
        .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
    }
}
