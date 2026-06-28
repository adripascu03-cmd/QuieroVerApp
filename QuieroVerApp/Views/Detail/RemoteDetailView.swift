import SwiftUI
import SwiftData

/// Ficha previa de un resultado de búsqueda, antes de añadirlo a la
/// biblioteca. Carga el detalle completo de TMDb y ofrece "Añadir a
/// Quiero ver". Al añadir, avisa al padre (`onAdded`) para cerrar toda
/// la búsqueda de una vez. Misma jerarquía visual que la ficha guardada.
@MainActor
struct RemoteDetailView: View {
    let result: MediaSearchResult
    @Binding var path: NavigationPath
    var onAdded: (() -> Void)? = nil
    var onJumpToRoot: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = RemoteDetailViewModel()
    @State private var addedItem: MediaItem?

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 420)
            case .error(let message):
                EmptyStateView(
                    title: "No se ha podido cargar.",
                    subtitle: message
                )
                .frame(maxWidth: .infinity, minHeight: 420)
            case .loaded(let details):
                loadedContent(details)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                CircleIconButton(systemName: "chevron.left") { dismiss() }
            }
            if onJumpToRoot != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    CircleIconButton(systemName: "rectangle.stack.fill") { onJumpToRoot?() }
                }
            }
        }
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
                posterPath: details.posterPath
            )

            VStack(alignment: .leading, spacing: Spacing.xl) {
                VStack(spacing: Spacing.sm) {
                    Text(details.title)
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    GenreChips(names: details.genres.map(\.name))
                }
                .frame(maxWidth: .infinity)

                MetricChipsRow(chips: metricChips(details))

                SectionBlock(title: "Sinopsis") {
                    Text(details.overview?.isEmpty == false ? details.overview! : "Sin sinopsis disponible.")
                        .font(.body)
                        .lineSpacing(5)
                        .foregroundStyle(details.overview?.isEmpty == false ? .primary : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let director = details.creatorsOrDirectors.first.map(PersonDisplayItem.init) {
                    SectionBlock(title: details.creditSectionLabel) {
                        DirectorSection(person: director) {
                            path.append(PersonNavigationTarget(director))
                        }
                    }
                }

                if !details.cast.isEmpty {
                    SectionBlock(title: "Reparto") {
                        CastCarousel(people: details.cast.map(PersonDisplayItem.init)) { person in
                            path.append(PersonNavigationTarget(person))
                        }
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
            .padding(.top, Spacing.sm)
            .padding(.bottom, Spacing.xxl)
        }
    }

    private func metricChips(_ details: MediaDetails) -> [MetricChip.Item] {
        var chips: [MetricChip.Item] = [.init(label: "Tipo", value: details.mediaType.displayName)]
        if let year = details.year {
            chips.append(.init(label: "Año", value: String(year)))
        }
        if details.mediaType == .movie, let runtime = details.runtimeMinutes, runtime > 0 {
            chips.append(.init(label: "Duración", value: "\(runtime) min"))
        } else if details.mediaType == .tv, let seasons = details.numberOfSeasons, seasons > 0 {
            chips.append(.init(label: "Temporadas", value: "\(seasons)"))
        }
        if let vote = details.voteAverage, vote > 0 {
            chips.append(.init(label: "Valoración", value: String(format: "★ %.1f", vote)))
        }
        return chips
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
