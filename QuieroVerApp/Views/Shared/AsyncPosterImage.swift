import SwiftUI

/// Poster con carga remota y fallback elegante a placeholder si no hay
/// imagen o la carga falla. Pensado para grid (casi plano) y detalle.
struct AsyncPosterImage: View {
    let url: URL?
    let title: String
    let mediaType: MediaType
    var contentMode: ContentMode = .fill

    var body: some View {
        if let url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                case .empty:
                    PosterPlaceholder(title: title, mediaType: mediaType)
                case .failure:
                    PosterPlaceholder(title: title, mediaType: mediaType)
                @unknown default:
                    PosterPlaceholder(title: title, mediaType: mediaType)
                }
            }
        } else {
            PosterPlaceholder(title: title, mediaType: mediaType)
        }
    }
}
