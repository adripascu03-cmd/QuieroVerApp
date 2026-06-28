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
            VStack(spacing: 0) {
                MediaDetailHero(
                    title: item.title,
                    mediaType: item.mediaType,
                    posterPath: item.posterPath,
                    backdropPath: item.backdropPath
                )

                VStack(alignment: .leading, spacing: Spacing.lg) {
                    GlassInfoPanel {
                        VStack(spacing: Spacing.xs) {
                            Text(item.title)
                                .font(.title2.bold())
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Text(metaLine)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            GenreChips(names: item.genres.map(\.name))
                        }
                        .frame(maxWidth: .infinity)
                    }

                    SectionBlock(title: "Sinopsis") {
                        Text(item.overview?.isEmpty == false ? item.overview! : "Sin sinopsis disponible.")
                            .font(.body)
                            .lineSpacing(4)
                            .foregroundStyle(item.overview?.isEmpty == false ? .primary : .secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if !item.directorsOrCreators.isEmpty {
                        SectionBlock(title: item.creditSectionLabel) {
                            CastCarousel(people: item.directorsOrCreators.map(PersonDisplayItem.init))
                        }
                    }

                    if !item.cast.isEmpty {
                        SectionBlock(title: "Reparto") {
                            CastCarousel(people: item.cast.map(PersonDisplayItem.init))
                        }
                    }

                    if item.status == .watched {
                        SectionBlock(title: "Tu registro") {
                            personalRegistry
                        }
                    }

                    if item.status == .wantToWatch {
                        ReasonAddedField(item: item)
                    }

                    secondaryActions
                }
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.top, MediaDetailHero.posterOverlap + Spacing.sm)
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
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.bottom, Spacing.sm)
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
    private var personalRegistry: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
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
                    .lineSpacing(3)
                    .padding(Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
                    .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
            }
        }
    }

    @ViewBuilder
    private var secondaryActions: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            if item.status == .watched {
                Button {
                    showingCompletionSheet = true
                } label: {
                    Label("Editar nota e impacto", systemImage: "pencil")
                }
                Button {
                    item.moveBackToWantToWatch()
                } label: {
                    Label("Mover a Quiero ver", systemImage: "arrow.uturn.backward")
                }
            }
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Eliminar de la biblioteca", systemImage: "trash")
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
