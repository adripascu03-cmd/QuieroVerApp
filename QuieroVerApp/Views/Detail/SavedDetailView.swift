import SwiftUI
import SwiftData

/// Ficha de un item ya guardado, en "Quiero ver" o en "Vistas".
/// Jerarquía: portada → título/género → metadatos esenciales →
/// sinopsis → dirección/creación → reparto → registro personal/acciones.
struct SavedDetailView: View {
    @Bindable var item: MediaItem

    @Binding var isTabBarHidden: Bool
    var onJumpToRoot: (() -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isRatingInline = false
    @State private var inlineRating = 3
    @State private var sheetInitialRating: Int?
    @State private var showingRatingSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var selectedPerson: PersonNavigationTarget?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                MediaHeroHeader(
                    title: item.title,
                    mediaType: item.mediaType,
                    posterPath: item.posterPath,
                    backdropPath: item.backdropPath
                )

                VStack(alignment: .leading, spacing: Spacing.xl) {
                    GlassInfoPanel {
                        VStack(spacing: Spacing.xs) {
                            Text(item.title)
                                .font(.title2.bold())
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            GenreChips(names: item.genres.map(\.name))
                        }
                        .frame(maxWidth: .infinity)
                    }

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
                                selectedPerson = PersonNavigationTarget(director)
                            }
                        }
                    }

                    if !item.cast.isEmpty {
                        SectionBlock(title: "Reparto") {
                            CastCarousel(people: item.cast.map(PersonDisplayItem.init)) { person in
                                selectedPerson = PersonNavigationTarget(person)
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
                .padding(.top, MediaHeroHeader.posterOverlap + Spacing.sm)
                .padding(.bottom, Spacing.xl)
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
        }
        .navigationDestination(item: $selectedPerson) { target in
            PersonDetailView(
                personId: target.personId,
                initialName: target.name,
                initialProfilePath: target.profilePath,
                onJumpToRoot: onJumpToRoot
            )
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
        .onAppear {
            withAnimation { isTabBarHidden = true }
        }
        .onDisappear {
            withAnimation { isTabBarHidden = false }
        }
    }

    @ViewBuilder
    private var watchActions: some View {
        if isRatingInline {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("¿Cuánto te ha gustado?")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                StarRatingPicker(rating: $inlineRating) { rating in
                    sheetInitialRating = rating
                    showingRatingSheet = true
                }
            }
            .padding(Spacing.md)
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

    private var metricChips: [MetricChip.Item] {
        var chips: [MetricChip.Item] = [.init(label: "Tipo", value: item.mediaType.displayName)]
        if let year = item.year {
            chips.append(.init(label: "Año", value: String(year)))
        }
        if item.mediaType == .movie, let runtime = item.runtimeMinutes, runtime > 0 {
            chips.append(.init(label: "Duración", value: "\(runtime) min"))
        }
        if item.mediaType == .tv, let seasons = item.numberOfSeasons, seasons > 0 {
            chips.append(.init(label: "Temporadas", value: seasons == 1 ? "1" : "\(seasons)"))
        }
        if let vote = item.voteAverage, vote > 0 {
            chips.append(.init(label: "Valoración", value: String(format: "★ %.1f", vote)))
        }
        return chips
    }
}
