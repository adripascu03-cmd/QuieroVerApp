import SwiftUI

/// Panel translúcido tipo "glass" para agrupar título, metadatos y
/// géneros bajo el poster flotante. Material con moderación: el
/// contenido sigue siendo el protagonista.
struct GlassInfoPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .padding(.horizontal, Spacing.lg)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
    }
}
