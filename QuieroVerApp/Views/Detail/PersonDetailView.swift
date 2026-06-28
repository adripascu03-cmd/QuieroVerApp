import SwiftUI
import SwiftData

/// Ficha de una persona (actor, actriz, director, creador...). Recibe
/// solo lo mínimo del punto de entrada (id, nombre y foto) para poder
/// mostrar algo de inmediato mientras carga el resto desde TMDb.
///
/// Hero a pantalla completa con degradado hacia el contenido (inspirado
/// en la composición de retrato + degradado de la referencia), nombre
/// jerarquizado, rol, biografía y filmografía con distinción clara
/// entre créditos de actuación y dirección.
@MainActor
struct PersonDetailView: View {
    let personId: Int
    let initialName: String
    let initialProfilePath: String?
    var onJumpToRoot: (() -> Void)? = nil

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
            VStack(spacing: 0) {
                hero

                switch viewModel.state {
                case .loading:
                    ProgressView()
                        .padding(.top, Spacing.xl)
                case .error(let message):
                    EmptyStateView(title: "No se ha podido cargar.", subtitle: message)
                        .padding(.top, Spacing.xl)
                case .loaded(let details):
                    content(details)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if onJumpToRoot != nil {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onJumpToRoot?()
                    } label: {
                        Image(systemName: "books.vertical.fill")
                    }
                    .accessibilityLabel("Volver a la galería")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? Color.yellow : Color.white)
                }
                .accessibilityLabel(isFavorite ? "Quitar de favoritos" : "Añadir a favoritos")
            }
        }
        .navigationDestination(item: $selectedFilmographyItem) { result in
            RemoteDetailView(result: result, onJumpToRoot: onJumpToRoot)
        }
        .task {
            await viewModel.load(personId: personId)
        }
    }

    private var currentRoleLabel: String? {
        if case .loaded(let details) = viewModel.state, !details.roleLabel.isEmpty {
            return details.roleLabel
        }
        return nil
    }

    private var currentName: String {
        if case .loaded(let details) = viewModel.state { return details.name }
        return initialName
    }

    private var currentProfilePath: String? {
        if case .loaded(let details) = viewModel.state { return details.profilePath }
        return initialProfilePath
    }

    /// Foto a pantalla completa con degradado hacia el fondo: el nombre
    /// y el rol quedan legibles sobre la imagen, sin necesitar una
    /// tarjeta independiente.
    private var hero: some View {
        ZStack(alignment: .bottom) {
            AsyncPosterImage(
                url: ImageURLBuilder.profileURL(path: currentProfilePath, size: "h632"),
                title: currentName,
                mediaType: .movie
            )
            .aspectRatio(3 / 4, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.55), .black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .frame(maxHeight: .infinity, alignment: .bottom)

            VStack(alignment: .leading, spacing: 6) {
                Text(currentName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if let currentRoleLabel {
                    Text(currentRoleLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.18), in: Capsule())
                }

                if case .loaded(let details) = viewModel.state, let birthInfo = birthInfoLine(details) {
                    Text(birthInfo)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.bottom, Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 380)
    }

    @ViewBuilder
    private func content(_ details: PersonDetails) -> some View {
        VStack(alignment: .leading, spacing: Spacing.xl) {
            if let biography = details.biography, !biography.isEmpty {
                SectionBlock(title: "Biografía") {
                    Text(biography)
                        .font(.body)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if !details.directingCredits.isEmpty {
                SectionBlock(title: "Como director/a") {
                    filmographyRow(details.directingCredits)
                }
            }

            if !details.actingCredits.isEmpty {
                SectionBlock(title: "Como actor / actriz") {
                    filmographyRow(details.actingCredits)
                }
            }
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, Spacing.xl)
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
