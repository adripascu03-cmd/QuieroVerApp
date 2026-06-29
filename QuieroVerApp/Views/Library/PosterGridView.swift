import SwiftUI

/// Galería 2D de posters: retícula de 2 columnas con tarjetas de
/// geometría uniforme (`EditorialPosterCard`). Es la vista de "Vistas"
/// y el modo galería opcional de "Quiero ver". Reserva espacio inferior
/// para que la tab bar flotante no tape la última fila.
struct PosterGridView: View {
    let items: [MediaItem]
    var showImpact: Bool = false
    var onSelect: (MediaItem) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.gridGutter),
        GridItem(.flexible(), spacing: Spacing.gridGutter)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                ForEach(items) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        EditorialPosterCard(item: item, showImpact: showImpact)
                    }
                    .buttonStyle(PressableButtonStyle())
                }
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, Spacing.xs)
            .padding(.bottom, 96)
        }
    }
}
