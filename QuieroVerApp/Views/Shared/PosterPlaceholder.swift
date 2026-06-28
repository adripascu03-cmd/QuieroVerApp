import SwiftUI

/// Tarjeta neutra mostrada cuando no hay poster disponible (o aún no carga).
struct PosterPlaceholder: View {
    let title: String
    let mediaType: MediaType

    var body: some View {
        ZStack {
            AppTheme.posterPlaceholderGradient

            VStack(spacing: Spacing.xs) {
                Image(systemName: mediaType == .movie ? "film" : "tv")
                    .foregroundStyle(.secondary)
                    .font(.title2)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal, Spacing.xs)
            }
        }
    }
}

#Preview {
    PosterPlaceholder(title: "Lost in Translation", mediaType: .movie)
        .frame(width: 160, height: 240)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius))
}
