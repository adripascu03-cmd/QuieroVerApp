import SwiftUI
import SwiftData

/// Ficha previa de un resultado de búsqueda, antes de añadirlo a la
/// biblioteca. Carga el detalle completo de TMDb (sinopsis, reparto,
/// dirección/creación) y ofrece el botón "Añadir a Quiero ver".
@MainActor
struct RemoteDetailView: View {
    let result: MediaSearchResult

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
        VStack(alignment: .leading, spacing: 0) {
            header(details)

            VStack(alignment: .leading, spacing: Spacing.lg) {
                GenreChips(names: details.genres.map(\.name))

                Text(details.overview?.isEmpty == false ? details.overview! : "Sin sinopsis disponible.")
                    .font(.body)
                    .foregroundStyle(details.overview?.isEmpty == false ? .primary : .secondary)

                CastSection(
                    title: details.creditSectionLabel,
                    people: details.creatorsOrDirectors.map(PersonDisplayItem.init)
                )

                CastSection(title: "Reparto", people: details.cast.map(PersonDisplayItem.init))

                VStack(alignment: .leading, spacing: Spacing.md) {
                    addButton(details)

                    if let addedItem {
                        ReasonAddedField(item: addedItem)
                    }
                }
                .padding(.top, Spacing.sm)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.lg)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func header(_ details: MediaDetails) -> some View {
        MediaBackdropHeader(
            title: details.title,
            mediaType: details.mediaType,
            metaLine: metaLine(details),
            posterPath: details.posterPath,
            backdropPath: details.backdropPath
        )
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

    @ViewBuilder
    private func addButton(_ details: MediaDetails) -> some View {
        Button {
            addToLibrary(details)
        } label: {
            Label(
                addedItem != nil ? "Añadida a Quiero ver" : "Añadir a Quiero ver",
                systemImage: addedItem != nil ? "checkmark" : "bookmark.fill"
            )
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xs)
        }
        .buttonStyle(.borderedProminent)
        .tint(addedItem != nil ? Color.secondary : Color.accentColor)
        .disabled(addedItem != nil)
        .clipShape(Capsule())
    }

    private func addToLibrary(_ details: MediaDetails) {
        guard addedItem == nil else { return }
        let item = LibraryWriter.addToWantToWatch(details: details, context: modelContext)
        addedItem = item
        Haptics.light()
    }
}

extension MediaDetails {
    var creditSectionLabel: String {
        mediaType == .movie ? "Dirección" : "Creación"
    }
}
