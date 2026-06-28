import SwiftUI
import SwiftData

/// Ficha previa de un resultado de búsqueda, antes de añadirlo a la
/// biblioteca. Carga el detalle completo de TMDb (sinopsis, reparto,
/// dirección/creación) y ofrece el botón "Añadir a Quiero ver". Al
/// añadir, avisa al padre (`onAdded`) para que cierre toda la búsqueda
/// de una vez, sin obligar a un "atrás" manual.
@MainActor
struct RemoteDetailView: View {
    let result: MediaSearchResult
    var onAdded: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = RemoteDetailViewModel()
    @State private var addedItem: MediaItem?

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 400)
            case .error(let message):
                EmptyStateView(
                    title: "No se ha podido cargar.",
                    subtitle: message
                )
                .frame(maxWidth: .infinity, minHeight: 400)
            case .loaded(let details):
                loadedContent(details)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(result)
        }
    }

    @ViewBuilder
    private func loadedContent(_ details: MediaDetails) -> some View {
        VStack(spacing: 0) {
            MediaHeroHeader(
                title: details.title,
                mediaType: details.mediaType,
                posterPath: details.posterPath,
                backdropPath: details.backdropPath,
                director: details.creatorsOrDirectors.first.map(PersonDisplayItem.init),
                directorRoleLabel: details.creditSectionLabel
            )

            VStack(alignment: .leading, spacing: Spacing.xl) {
                GlassInfoPanel {
                    VStack(spacing: Spacing.xs) {
                        Text(details.title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(metaLine(details))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        GenreChips(names: details.genres.map(\.name))
                    }
                    .frame(maxWidth: .infinity)
                }

                SectionBlock(title: "Sinopsis") {
                    Text(details.overview?.isEmpty == false ? details.overview! : "Sin sinopsis disponible.")
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundStyle(details.overview?.isEmpty == false ? .primary : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if !details.creatorsOrDirectors.isEmpty {
                    SectionBlock(title: details.creditSectionLabel) {
                        CastCarousel(people: details.creatorsOrDirectors.map(PersonDisplayItem.init))
                    }
                }

                if !details.cast.isEmpty {
                    SectionBlock(title: "Reparto") {
                        CastCarousel(people: details.cast.map(PersonDisplayItem.init))
                    }
                }

                PrimaryGlassButton(
                    title: addedItem != nil ? "Añadida a Quiero ver" : "Añadir a Quiero ver",
                    systemImage: addedItem != nil ? "checkmark" : "bookmark.fill",
                    isDisabled: addedItem != nil
                ) {
                    addToLibrary(details)
                }
                .padding(.top, Spacing.sm)
            }
            .padding(.horizontal, Spacing.screenMargin)
            .padding(.top, MediaHeroHeader.posterOverlap + Spacing.sm)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func metaLine(_ details: MediaDetails) -> String {
        var parts = [details.mediaType.displayName]
        if let year = details.year { parts.append(String(year)) }
        if details.mediaType == .movie, let runtime = details.runtimeMinutes, runtime > 0 {
            parts.append("\(runtime) min")
        }
        if details.mediaType == .tv, let seasons = details.numberOfSeasons, seasons > 0 {
            parts.append(seasons == 1 ? "1 temporada" : "\(seasons) temporadas")
        }
        return parts.joined(separator: " · ")
    }

    private func addToLibrary(_ details: MediaDetails) {
        guard addedItem == nil else { return }
        let item = LibraryWriter.addToWantToWatch(details: details, context: modelContext)
        addedItem = item
        Haptics.light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            onAdded?()
        }
    }
}

extension MediaDetails {
    var creditSectionLabel: String {
        mediaType == .movie ? "Dirección" : "Creación"
    }
}
