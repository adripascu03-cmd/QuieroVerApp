import SwiftUI

/// Cabecera de la ficha: poster protagonista, centrado y flotante sobre
/// el fondo claro con una sombra suave — composición limpia y editorial
/// (estilo Listy), sin el backdrop difuminado anterior que ensuciaba la
/// pantalla. Compartida entre la ficha previa y la ficha guardada.
struct MediaHeroHeader: View {
    let title: String
    let mediaType: MediaType
    let posterPath: String?
    /// Se mantiene por compatibilidad de las llamadas; ya no se pinta un
    /// backdrop (decisión: fondo limpio).
    var backdropPath: String? = nil

    private let posterWidth: CGFloat = 160
    private let posterHeight: CGFloat = 240

    var body: some View {
        AsyncPosterImage(
            url: ImageURLBuilder.posterURL(path: posterPath),
            title: title,
            mediaType: mediaType,
            contentMode: .fill
        )
        .frame(width: posterWidth, height: posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
        .detailPosterShadow()
        .frame(maxWidth: .infinity)
        .padding(.top, Spacing.md)
        .padding(.bottom, Spacing.xs)
    }
}
