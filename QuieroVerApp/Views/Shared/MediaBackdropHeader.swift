import SwiftUI

/// Cabecera de ficha de detalle: backdrop (o poster difuminado como
/// fallback) con degradado, poster grande y título/metadatos superpuestos.
/// Compartida entre la ficha previa (TMDb en vivo) y la ficha guardada.
struct MediaBackdropHeader: View {
    let title: String
    let mediaType: MediaType
    let metaLine: String
    let posterPath: String?
    let backdropPath: String?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            backdrop

            HStack(alignment: .bottom, spacing: Spacing.md) {
                AsyncPosterImage(
                    url: ImageURLBuilder.posterURL(path: posterPath),
                    title: title,
                    mediaType: mediaType
                )
                .aspectRatio(2 / 3, contentMode: .fill)
                .frame(width: 120, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius))
                .detailPosterShadow()

                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text(metaLine)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }
                .shadow(color: .black.opacity(0.4), radius: 6)
            }
            .padding(Spacing.md)
        }
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
                            .blur(radius: backdropURL == nil ? 24 : 0)
                    } else {
                        Color(.systemGray5)
                    }
                }
            } else {
                Color(.systemGray5)
            }
        }
        .frame(height: 280)
        .clipped()
        .overlay(
            LinearGradient(
                colors: [.black.opacity(0.05), .black.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
