import SwiftUI
import SwiftData

/// Ficha de un item ya guardado, en "Quiero ver" o en "Vistas".
/// Misma estructura objetiva (TMDb) + sección personal cuando aplica.
struct SavedDetailView: View {
    @Bindable var item: MediaItem

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingCompletionSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MediaBackdropHeader(
                    title: item.title,
                    mediaType: item.mediaType,
                    metaLine: metaLine,
                    posterPath: item.posterPath,
                    backdropPath: item.backdropPath
                )

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    GenreChips(names: item.genres.map(\.name))

                    Text(item.overview?.isEmpty == false ? item.overview! : "Sin sinopsis disponible.")
                        .font(.body)
                        .foregroundStyle(item.overview?.isEmpty == false ? .primary : .secondary)

                    CastSection(
                        title: item.creditSectionLabel,
                        people: item.directorsOrCreators.map(PersonDisplayItem.init)
                    )
                    CastSection(title: "Reparto", people: item.cast.map(PersonDisplayItem.init))

                    personalSection

                    if item.status == .wantToWatch {
                        ReasonAddedField(item: item)
                    }

                    secondaryActions
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.lg)
                .padding(.bottom, item.status == .wantToWatch ? Spacing.xxl + 60 : Spacing.xl)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if item.status == .wantToWatch {
                SlideToMarkWatchedView {
                    showingCompletionSheet = true
                }
                .padding(.horizontal, Spacing.md)
                .padding(.bottom, Spacing.sm)
                .background(.clear)
            }
        }
        .sheet(isPresented: $showingCompletionSheet) {
            CompletionSheetView(item: item)
        }
        .confirmationDialog(
            "¿Eliminar de tu biblioteca?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                modelContext.delete(item)
                dismiss()
            }
            Button("Cancelar", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var personalSection: some View {
        if item.status == .watched {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Tu registro")
                    .font(.headline)

                if let watchedAt = item.watchedAt {
                    Text("Vista el \(watchedAt.formatted(date: .long, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let impact = item.personalImpact {
                    HStack(spacing: Spacing.xs) {
                        Text("Impacto personal")
                            .font(.subheadline)
                        ImpactBadge(value: impact)
                    }
                }

                if let note = item.personalNote, !note.isEmpty {
                    Text(note)
                        .font(.body)
                        .padding(Spacing.sm)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                }
            }
        }
    }

    @ViewBuilder
    private var secondaryActions: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if item.status == .watched {
                Button("Editar nota e impacto") {
                    showingCompletionSheet = true
                }
                Button("Mover a Quiero ver") {
                    item.moveBackToWantToWatch()
                }
            }
            Button("Eliminar de la biblioteca", role: .destructive) {
                showingDeleteConfirmation = true
            }
        }
        .font(.subheadline)
        .padding(.top, Spacing.sm)
    }

    private var metaLine: String {
        var parts = [item.mediaType.displayName]
        if let year = item.year { parts.append(String(year)) }
        if item.mediaType == .movie, let runtime = item.runtimeMinutes, runtime > 0 {
            parts.append("\(runtime) min")
        }
        if item.mediaType == .tv, let seasons = item.numberOfSeasons, seasons > 0 {
            parts.append(seasons == 1 ? "1 temporada" : "\(seasons) temporadas")
        }
        return parts.joined(separator: " · ")
    }
}
