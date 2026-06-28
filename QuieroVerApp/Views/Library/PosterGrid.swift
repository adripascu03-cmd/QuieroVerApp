import SwiftUI

/// Grid visual de posters, 2 columnas, espacio generoso.
/// Navega por valor: el padre debe declarar
/// `.navigationDestination(for: MediaItem.self)`.
struct PosterGrid: View {
    let items: [MediaItem]
    var showImpact: Bool = false

    private let columns = [
        GridItem(.flexible(), spacing: Spacing.gridGutter),
        GridItem(.flexible(), spacing: Spacing.gridGutter)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: Spacing.xl) {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    EditorialPosterCard(item: item, showImpact: showImpact)
                }
                .buttonStyle(PressableButtonStyle())
            }
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.bottom, Spacing.xl)
    }
}
