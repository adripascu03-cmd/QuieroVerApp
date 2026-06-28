import SwiftUI

/// Tarjeta de poster para el grid: casi plana, sombra muy sutil,
/// título debajo y, en Vistas, una cápsula discreta con el impacto.
struct MediaPosterCard: View {
    let item: MediaItem
    var showImpact: Bool = false

    private var posterURL: URL? {
        ImageURLBuilder.posterURL(path: item.posterPath)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xxs) {
            ZStack(alignment: .bottomTrailing) {
                AsyncPosterImage(url: posterURL, title: item.title, mediaType: item.mediaType)
                    .aspectRatio(2 / 3, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius))
                    .gridPosterShadow()

                if showImpact, let impact = item.personalImpact {
                    ImpactBadge(value: impact)
                        .padding(8)
                }
            }

            Text(item.title)
                .font(.caption.weight(.medium))
                .lineLimit(1)
                .foregroundStyle(.primary)

            Text(item.displayYear)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title), \(item.mediaType.displayName), \(item.displayYear)")
    }
}

/// Cápsula discreta con el impacto personal, p. ej. "8.2".
struct ImpactBadge: View {
    let value: Double

    var body: some View {
        Text(formatted)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.55), in: Capsule())
    }

    private var formatted: String {
        value.rounded() == value ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}
