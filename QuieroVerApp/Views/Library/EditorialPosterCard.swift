import SwiftUI

/// Tarjeta de poster para el grid. La geometría del poster es fija e
/// idéntica en todas las tarjetas (vía `GeometryReader` + ratio 2:3
/// forzado), así que un poster de TMDb con proporciones ligeramente
/// distintas nunca rompe la retícula ni deforma la tarjeta.
struct EditorialPosterCard: View {
    let item: MediaItem
    var showImpact: Bool = false

    private var posterURL: URL? {
        ImageURLBuilder.posterURL(path: item.posterPath)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            GeometryReader { proxy in
                ZStack(alignment: .bottomTrailing) {
                    AsyncPosterImage(url: posterURL, title: item.title, mediaType: item.mediaType)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous))
                        .gridPosterShadow()

                    if showImpact, let impact = item.personalImpact {
                        ImpactBadge(value: impact)
                            .padding(8)
                    }
                }
            }
            .aspectRatio(2 / 3, contentMode: .fit)

            Text(item.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)

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
            .overlay(Capsule().strokeBorder(.white.opacity(0.25), lineWidth: 0.5))
    }

    private var formatted: String {
        value.rounded() == value ? String(format: "%.0f", value) : String(format: "%.1f", value)
    }
}
