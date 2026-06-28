import SwiftUI
import SwiftData

/// Ficha de un item ya guardado, en "Quiero ver" o en "Vistas".
/// Jerarquía: portada → título → género → sinopsis → métricas →
/// dirección → reparto → registro/acciones. La tab bar se oculta sola
/// (la decide RootView según la profundidad de navegación), así que
/// aquí no hay que gestionarla.
struct SavedDetailView: View {
    @Bindable var item: MediaItem
    @Binding var path: NavigationPath
    var onJumpToRoot: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isRatingInline = false
    @State private var inlineRating = 3
    @State private var sheetInitialRating: Int?
    @State private var showingRatingSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MediaHeroHeader(
                    title: item.title,
                    mediaType: item.mediaType,
                    posterPath: item.posterPath
                )

                VStack(alignment: .leading, spacing: Spacing.xl) {
                    titleBlock

                    MetricChipsRow(chips: metricChips)

                    SectionBlock(title: "Sinopsis") {
                        Text(item.overview?.isEmpty == false ? item.overview! : "Sin sinopsis disponible.")
                            .font(.body)
                            .lineSpacing(5)
                            .foregroundStyle(item.overview?.isEmpty == false ? .primary : .secondary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    if let director = item.directorsOrCreators.first.map(PersonDisplayItem.init) {
                        SectionBlock(title: item.creditSectionLabel) {
                            DirectorSection(person: director) {
                                path.append(PersonNavigationTarget(director))
                            }
                        }
                    }

                    if !item.cast.isEmpty {
                        SectionBlock(title: "Reparto") {
                            CastCarousel(people: item.cast.map(PersonDisplayItem.init)) { person in
                                path.append(PersonNavigationTarget(person))
                            }
                        }
                    }

                    if item.status == .watched {
                        SectionBlock(title: "Tu registro") {
                            personalRegistry
                        }
                    }

                    if item.status == .wantToWatch {
                        ReasonAddedField(item: item)
                        watchActions
                    }

                    secondaryActions
                }
                .padding(.horizontal, Spacing.screenMargin)
                .padding(.top, Spacing.sm)
                .padding(.bottom, Spacing.xxl)
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
        .sheet(isPresented: $showingRatingSheet) {
            WatchRatingSheet(item: item, initialRating: sheetInitialRating)
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

    private var titleBlock: some View {
        VStack(spacing: Spacing.sm) {
            Text(item.title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            GenreChips(names: item.genres.map(\.name))
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var watchActions: some View {
        if isRatingInline {
            VStack(spacing: Spacing.sm) {
                Text("¿Cuánto te ha gustado?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                StarRatingPicker(rating: $inlineRating) { rating in
                    sheetInitialRating = rating
                    showingRatingSheet = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.lg)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius, style: .continuous))
            .glassBorder(cornerRadius: AppTheme.cardCornerRadius)
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else {
            PrimaryGlassButton(title: "Marcar como vista", systemImage: "checkmark.circle.fill") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isRatingInline = true
                }
            }
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

            if let starRating {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { value in
                        Image(systemName: value <= starRating ? "star.fill" : "star")
                            .foregroundStyle(value <= starRating ? Color.yellow : Color.secondary.opacity(0.4))
                            .font(.subheadline)
                    }
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
                    sheetInitialRating = nil
                    showingRatingSheet = true
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

    private var starRating: Int? {
        item.personalImpact.map { Int(($0 / 2).rounded()) }
    }

    /// Hasta 4 métricas esenciales que reparten el ancho de la fila.
    private var metricChips: [MetricChip.Item] {
        var chips: [MetricChip.Item] = [.init(label: "Tipo", value: item.mediaType.displayName)]
        if let year = item.year {
            chips.append(.init(label: "Año", value: String(year)))
        }
        if item.mediaType == .movie, let runtime = item.runtimeMinutes, runtime > 0 {
            chips.append(.init(label: "Duración", value: "\(runtime) min"))
        } else if item.mediaType == .tv, let seasons = item.numberOfSeasons, seasons > 0 {
            chips.append(.init(label: "Temporadas", value: "\(seasons)"))
        }
        if let vote = item.voteAverage, vote > 0 {
            chips.append(.init(label: "Valoración", value: String(format: "★ %.1f", vote)))
        }
        return chips
    }
}
