import SwiftUI

/// Envoltorio simple para una sección de la ficha de detalle: título +
/// contenido, espaciado consistente. Evita el aspecto de formulario.
struct SectionBlock<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(.headline)
            content
        }
    }
}
