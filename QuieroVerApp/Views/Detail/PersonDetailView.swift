import SwiftUI
import SwiftData

/// Ficha de una persona (actor, actriz, director, creador...). Recibe
/// solo lo mínimo del punto de entrada (id, nombre y foto) para poder
/// mostrar algo de inmediato mientras carga el resto desde TMDb.
struct PersonDetailView: View {
    let personId: Int
    let initialName: String
    let initialProfilePath: String?

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PersonDetailViewModel()
    @State private var selectedFilmographyItem: MediaSearchResult?

    @Query(sort: [SortDescriptor(\FavoritePerson.createdAt, order: .reverse)])
    private var favorites: [FavoritePerson]

    private var isFavorite: Bool {
        favorites.contains { $0.tmdbId == personId }
    }

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                VStack(spacing: Spacing.lg) {
                    header(nil)
                    ProgressView()
                }
                .padding(.top, Spacing.xl)
            case .error(let message):
                VStack(spacing: Spacing.lg) {
                    header(nil)
                    EmptyStateView(title: "No se ha podido cargar.", subtitle: message)
                }
                .padding(.top, Spacing.xl)
            case .loaded(let details):
                content(details)
            }
        }
        .navigationTitle(initialName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? Color.yellow : Color.secondary)
                }
                .accessibilityLabel(isFavorite ? "Quitar de favoritos" : "Añadir a favoritos")
            }
        }
        .navigationDestination(item: $selectedFilmographyItem) { result in
            RemoteDetailView(result: result)
        }
        .task {
            await viewModel.load(personId: personId)
        }
    }

    @ViewBuilder
    private func header(_ details: PersonDetails?) -> some View {
        VStack(spacing: Spacing.sm) {
            PersonAvatarImage(
                person: PersonDisplayItem(
                    id: personId,
                    name: details?.name ?? initialName,
                    profilePath: details?.profilePath ?? initialProfilePath,
                    character: nil
                ),
                size: 120
            )
            .detailPosterShadow()

            Text(details?.name ?? initialName)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            if let details {
                if !details.roleLabel.isEmpty {
                    Text(details.roleLabel)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if let birthInfo = birthInfoLine(details) {
                    Text(birthInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.top, Spacing.lg)
    }

    @ViewBuilder
    private func content(_ details: PersonDetails) -> some View {
        VStack(spacing: Spacing.xl) {
            header(details)

            if let biography = details.biography, !biography.isEmpty {
                SectionBlock(title: "Biografía") {
                    Text(biography)
                        .font(.body)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !details.filmography.isEmpty {
                SectionBlock(title: details.filmographyTitle) {
                    filmographyRow(details.filmography)
                }
            }
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.bottom, Spacing.xxl)
    }

    private func filmographyRow(_ items: [PersonCreditItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Spacing.md) {
                ForEach(items) { credit in
                    Button {
                        selectedFilmographyItem = MediaSearchResult(
                            id: credit.id,
                            tmdbId: credit.tmdbId,
                            mediaType: credit.mediaType,
                            title: credit.title,
                            originalTitle: nil,
                            overview: nil,
                            posterPath: credit.posterPath,
                            backdropPath: nil,
                            releaseDate: nil,
                            year: credit.year
                        )
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            AsyncPosterImage(
                                url: ImageURLBuilder.posterURL(path: credit.posterPath, size: "w185"),
                                title: credit.title,
                                mediaType: credit.mediaType
                            )
                            .aspectRatio(2 / 3, contentMode: .fill)
                            .frame(width: 96, height: 144)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous))
                            .gridPosterShadow()

                            Text(credit.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .frame(width: 96, alignment: .leading)

                            if let role = credit.roleDescription, !role.isEmpty {
                                Text(role)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                    .frame(width: 96, alignment: .leading)
                            }
                        }
                    }
                    .buttonStyle(PressableButtonStyle(scale: 0.96))
                }
            }
            .padding(.horizontal, Spacing.screenMargin)
        }
        .padding(.horizontal, -Spacing.screenMargin)
    }

    private func birthInfoLine(_ details: PersonDetails) -> String? {
        guard let birthday = details.birthday else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "es_ES")

        var line = formatter.string(from: birthday)
        if let place = details.placeOfBirth, !place.isEmpty {
            line += " · \(place)"
        }
        if let deathday = details.deathday {
            line += " — † \(formatter.string(from: deathday))"
        }
        return line
    }

    private func toggleFavorite() {
        if let existing = favorites.first(where: { $0.tmdbId == personId }) {
            modelContext.delete(existing)
        } else {
            var name = initialName
            var profilePath = initialProfilePath
            var department: String?
            var biography: String?
            if case .loaded(let details) = viewModel.state {
                name = details.name
                profilePath = details.profilePath
                department = details.knownForDepartment
                biography = details.biography
            }
            let favorite = FavoritePerson(
                tmdbId: personId,
                name: name,
                profilePath: profilePath,
                knownForDepartment: department,
                biography: biography
            )
            modelContext.insert(favorite)
        }
        Haptics.light()
    }
}
