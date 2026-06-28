import SwiftUI

/// Entrada principal y clara para añadir contenido — sustituye la lupa
/// escondida en la toolbar. Vive arriba de la galería "Quiero ver".
struct AddMediaCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Spacing.sm) {
                ZStack {
                    Circle().fill(Color.accentColor.opacity(0.15))
                    Image(systemName: "plus")
                        .foregroundStyle(Color.accentColor)
                        .font(.headline)
                }
                .frame(width: 36, height: 36)

                Text("Añadir película o serie")
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer(minLength: Spacing.xs)

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(Spacing.md)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
        }
        .buttonStyle(PressableButtonStyle(scale: 0.98))
    }
}
