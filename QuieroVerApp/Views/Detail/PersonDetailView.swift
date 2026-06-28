import SwiftUI
import SwiftData

/// Ficha de una persona (actor, actriz, director, creador...). Recibe lo
/// mínimo del punto de entrada (id, nombre, foto) para mostrar algo de
/// inmediato mientras carga el resto desde TMDb.
///
/// Hero a sangre con la foto recortada a una altura FIJA (`.clipped()`
/// sobre un contenedor de tamaño fijo, no `.aspectRatio(.fill)` suelto,
/// que era lo que desbordaba y solapaba el texto sobre la cara). El
/// degradado funde la foto hacia el fondo de la página: el nombre queda
/// sobre la zona ya opaca, perfectamente legible, y la biografía y la
/// filmografía van claramente DEBAJO, sin solaparse.
@MainActor
struct PersonDetailView: View {
    let personId: Int
    let initialName: String
    let initialProfilePath: String?
    @Binding var path: NavigationPath
    var onJumpToRoot: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PersonDetailViewModel()

    @Query(sort: [SortDescriptor(\FavoritePerson.createdAt, order: .reverse)])
    private var favorites: [FavoritePerson]

    private let heroHeight: CGFloat = 460

    private var isFavorite: Bool {
        favorites.contains { $0.tmdbId == personId }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                content
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleIconButton(systemName: "chevron.left") { dismiss() }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if onJumpToRoot != nil {
                    CircleIconButton(systemName: "rectangle.stack.fill") { onJumpToRoot?() }
                }
                CircleIconButton(
                    systemName: isFavorite ? "star.fill" : "star",
                    tint: isFavorite ? .yellow : .primary
                ) {
                    toggleFavorite()
                }
            }
        }
        .task {
            await viewModel.load(personId: personId)
        }
    }

    // MARK: Datos en vivo o iniciales

    private var currentName: String {
        if case .loaded(let details) = viewModel.state { return details.name }
        return initialName
    }

    private var currentProfilePath: String? {
        if case .loaded(let details) = viewModel.state { return details.profilePath }
        return initialProfilePath
    }

    private var currentRoleLabel: String? {
        if case .loaded(let details) = viewModel.state, !details.roleLabel.isEmpty {
            return details.roleLabel
        }
        return nil
    }

    // MARK: Hero

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            // Foto recortada a tamaño fijo: el overlay rellena el
            // contenedor y `.clipped()` lo recorta — nunca desborda.
            Color(.secondarySystemBackground)
                .overlay {
                    AsyncPosterImage(
                        url: ImageURLBuilder.profileURL(path: currentProfilePath, size: "h632"),
                        title: currentName,
                        mediaType: .movie,
                        contentMode: .fill
                    )
                }
                .frame(height: heroHeight)
                .frame(maxWidth: .infinity)
                .clipped()

            // Degradado: transparente arriba, funde al fondo de la página
            // abajo, de modo que el nombre se apoya sobre zona opaca.
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: Color(.systemBackground).opacity(0.0), location: 0.42),
                    .init(color: Color(.systemBackground).opacity(0.88), location: 0.74),
                    .init(color: Color(.systemBackground), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: Spacing.xs) {
                Text(currentName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if let currentRoleLabel {
                    Text(currentRoleLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color(.secondarySystemBackground), in: Capsule())
                }

                if case .loaded(let details) = viewModel.state, let birthInfo = birthInfoLine(details) {
                    Text(birthInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.bottom, Spacing.sm)
        }
        .frame(height: heroHeight)
        .frame(maxWidth: .infinity)
    }

    // MARK: Contenido bajo el hero

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
                .padding(.top, Spacing.xl)
                .frame(maxWidth: .infinity)
        case .error(let message):
            EmptyStateView(title: "No se ha podido cargar.", subtitle: message)
                .padding(.top, Spacing.lg)
        case .loaded(let details):
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

                if details.biography == nil && details.directingCredits.isEmpty && details.actingCredits.isEmpty {
                    Text("No hay más información disponible de esta persona.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func filmographyRow(_ items: [PersonCreditItem]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: Spacing.md) {
                ForEach(items) { credit in
                    Button {
                        path.append(MediaSearchResult(
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
                        ))
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            AsyncPosterImage(
                                url: ImageURLBuilder.posterURL(path: credit.posterPath, size: "w185"),
                                title: credit.title,
                                mediaType: credit.mediaType
                            )
                            .frame(width: 100, height: 150)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.posterCornerRadius, style: .continuous))
                            .gridPosterShadow()

                            Text(credit.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                                .frame(width: 100, alignment: .leading)

                            if let year = credit.year {
                                Text(String(year))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .frame(width: 100, alignment: .leading)
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
