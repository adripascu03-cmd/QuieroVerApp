import SwiftUI

struct SearchResultRow: View {
    let result: MediaSearchResult

    var body: some View {
        HStack(spacing: Spacing.md) {
            AsyncPosterImage(
                url: ImageURLBuilder.posterURL(path: result.posterPath, size: "w185"),
                title: result.title,
                mediaType: result.mediaType
            )
            .aspectRatio(2 / 3, contentMode: .fill)
            .frame(width: 56, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                Text(metaLine)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let overview = result.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }

    private var metaLine: String {
        var parts = [result.mediaType.displayName]
        if let year = result.year { parts.append(String(year)) }
        return parts.joined(separator: " · ")
    }
}
