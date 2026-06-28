import SwiftUI

/// Agrupación de la biblioteca por director/creador: una fila por
/// persona, con su foto+nombre a la izquierda y sus películas/series
/// guardadas en esa librería en un carrusel horizontal a la derecha.
/// Películas sin director identificable simplemente no aparecen aquí
/// — no rompen nada.
struct DirectorsSection: View {
    let items: [MediaItem]
    var showImpact: Bool = false
    var onSelectDirector: ((PersonDisplayItem) -> Void)? = nil

    private struct Group: Identifiable {
        let director: PersonDisplayItem
        let items: [MediaItem]
        var id: Int { director.id }
    }

    private var groups: [Group] {
        var order: [Int] = []
        var people: [Int: PersonDisplayItem] = [:]
        var works: [Int: [MediaItem]] = [:]

        for item in items {
            guard let credit = item.directorsOrCreators.first else { continue }
            let key = credit.tmdbId
            if people[key] == nil {
                people[key] = PersonDisplayItem(credit)
                works[key] = []
                order.append(key)
            }
            works[key]?.append(item)
        }

        return order.compactMap { key in
            guard let person = people[key], let works = works[key] else { return nil }
            return Group(director: person, items: works)
        }
    }

    var body: some View {
        if groups.isEmpty {
            Text("Ninguna de tus películas guardadas tiene dirección identificable todavía.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.top, Spacing.lg)
        } else {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                ForEach(groups) { group in
                    DirectorRow(
                        director: group.director,
                        items: group.items,
                        showImpact: showImpact,
                        onSelectDirector: onSelectDirector
                    )
                }
            }
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xl)
        }
    }
}

private struct DirectorRow: View {
    let director: PersonDisplayItem
    let items: [MediaItem]
    var showImpact: Bool
    var onSelectDirector: ((PersonDisplayItem) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.md) {
            directorButton

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(items) { item in
                        NavigationLink(value: item) {
                            posterThumbnail(item)
                        }
                        .buttonStyle(PressableButtonStyle())
                    }
                }
            }
        }
        .padding(.horizontal, Spacing.screenMargin)
    }

    @ViewBuilder
    private var directorButton: some View {
        if let onSelectDirector {
            Button {
                onSelectDirector(director)
            } label: {
                directorContent
            }
            .buttonStyle(PressableButtonStyle(scale: 0.95))
        } else {
            directorContent
        }
    }

    private var directorContent: some View {
        VStack(spacing: 6) {
            PersonAvatarImage(person: director, size: 64)
            Text(director.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(width: 76)
    }

    private func posterThumbnail(_ item: MediaItem) -> some View {
        ZStack(alignment: .bottomTrailing) {
            AsyncPosterImage(
                url: ImageURLBuilder.posterURL(path: item.posterPath, size: "w185"),
                title: item.title,
                mediaType: item.mediaType
            )
            .aspectRatio(2 / 3, contentMode: .fill)
            .frame(width: 84, height: 126)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous))
            .gridPosterShadow()

            if showImpact, let impact = item.personalImpact {
                ImpactBadge(value: impact)
                    .padding(6)
            }
        }
    }
}
