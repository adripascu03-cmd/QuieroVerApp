import SwiftUI

/// Cabecera editorial de la ficha de detalle: backdrop difuminado que
/// funde con el fondo del sistema, poster grande y protagonista que se
/// apoya sobre el borde inferior con sombra suave, y opcionalmente una
/// insignia de dirección/creación cerca de la cabecera. El título y los
/// metadatos NO van superpuestos a la imagen (legibilidad); viven en el
/// panel de abajo. Compartida entre la ficha previa y la ficha guardada.
struct MediaHeroHeader: View {
    let title: String
    let mediaType: MediaType
    let posterPath: String?
    let backdropPath: String?
    var director: PersonDisplayItem? = nil
    var directorRoleLabel: String = "Dirección"

    private let heroHeight: CGFloat = 240
    private let posterWidth: CGFloat = 144
    private let posterHeight: CGFloat = 216
    /// Cuánto sobresale el poster por debajo del backdrop, solapando con
    /// el contenido siguiente. Contenido a propósito: el padre debe
    /// reservar este mismo espacio como padding superior.
    static let posterOverlap: CGFloat = 44

    var body: some View {
        ZStack(alignment: .bottom) {
            backdrop

            if let director {
                VStack {
                    HStack {
                        Spacer()
                        DirectorBadge(person: director, roleLabel: directorRoleLabel)
                    }
                    Spacer()
                }
                .padding(.top, 54)
                .padding(.horizontal, Spacing.screenMargin)
            }

            AsyncPosterImage(
                url: ImageURLBuilder.posterURL(path: posterPath),
                title: title,
                mediaType: mediaType,
                contentMode: .fit
            )
            .frame(width: posterWidth, height: posterHeight)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous))
            .detailPosterShadow()
            .offset(y: Self.posterOverlap)
        }
        .frame(height: heroHeight)
    }

    @ViewBuilder
    private var backdrop: some View {
        let backdropURL = ImageURLBuilder.backdropURL(path: backdropPath)
        let fallbackURL = ImageURLBuilder.posterURL(path: posterPath, size: "w780")
        let url = backdropURL ?? fallbackURL

        ZStack {
            if let url {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: backdropURL == nil ? 28 : 0)
                    } else {
                        Color(.systemGray5)
                    }
                }
            } else {
                Color(.systemGray5)
            }
        }
        .frame(height: heroHeight)
        .clipped()
        .overlay(AppTheme.backdropFade(into: Color(.systemBackground)))
    }
}
