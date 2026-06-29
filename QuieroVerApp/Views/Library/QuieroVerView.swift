import SwiftUI
import SwiftData

/// Modo de presentación de la biblioteca "Quiero ver".
enum LibraryDisplayMode: Equatable {
    case deck
    case grid
}

struct QuieroVerView: View {
    @Binding var path: NavigationPath
    var onRequestVistas: () -> Void = {}

    @Environment(\.modelContext) private var modelContext

    @Query(
        filter: #Predicate<MediaItem> { $0.statusRaw == "wantToWatch" },
        sort: [SortDescriptor(\MediaItem.addedAt, order: .reverse)]
    )
    private var allItems: [MediaItem]

    @State private var showingSearch = false
    @State private var filter: LibraryFilter = .recientes
    @State private var mode: LibraryDisplayMode = .deck

    private var items: [MediaItem] {
        guard let mediaType = filter.mediaType else { return allItems }
        return allItems.filter { $0.mediaType == mediaType }
    }

    private var showsModeToggle: Bool {
        !allItems.isEmpty && filter != .directores
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: Spacing.md) {
                LibraryHeader(title: "Quiero ver", count: allItems.count, noun: "guardada") {
                    headerControls
                }

                if allItems.isEmpty {
                    Spacer()
                    EmptyStateView(
                        title: "Todavía no has guardado nada.",
                        subtitle: "Toca + para buscar una película, serie o persona."
                    )
                    Spacer()
                } else {
                    RefinedFilterPillBar(
                        options: [.recientes, .peliculas, .series, .directores],
                        selection: $filter
                    )
                    content
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationDestination(for: MediaItem.self) { item in
                SavedDetailView(item: item, path: $path, onJumpToRoot: { path = NavigationPath() })
            }
            .navigationDestination(for: PersonNavigationTarget.self) { target in
                PersonDetailView(
                    personId: target.personId,
                    initialName: target.name,
                    initialProfilePath: target.profilePath,
                    path: $path,
                    onJumpToRoot: { path = NavigationPath() }
                )
            }
            .navigationDestination(for: MediaSearchResult.self) { result in
                RemoteDetailView(result: result, path: $path, onJumpToRoot: { path = NavigationPath() })
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingSearch) {
                SearchView()
            }
            .onChange(of: allItems.count) { oldCount, newCount in
                // Al añadir una película, vuelve al deck y a Recientes para
                // que la nueva (la más reciente) quede enfocada y visible.
                if newCount > oldCount {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        filter = .recientes
                        mode = .deck
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var headerControls: some View {
        HStack(spacing: Spacing.sm) {
            if showsModeToggle {
                CircleIconButton(systemName: mode == .deck ? "square.grid.2x2" : "rectangle.stack") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                        mode = mode == .deck ? .grid : .deck
                    }
                }
            }

            Button {
                showingSearch = true
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(.white)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 42, height: 42)
                    .background(Color.accentColor, in: Circle())
                    .overlay(Circle().strokeBorder(.white.opacity(0.25), lineWidth: 1))
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 9, x: 0, y: 4)
            }
            .buttonStyle(PressableButtonStyle(scale: 0.9))
            .accessibilityLabel("Añadir película, serie o persona")
        }
    }

    @ViewBuilder
    private var content: some View {
        Group {
            if filter == .directores {
                ScrollView {
                    DirectorsSection(items: allItems) { person in
                        path.append(PersonNavigationTarget(person))
                    }
                }
            } else if items.isEmpty {
                EmptyFilterNotice()
            } else if mode == .deck {
                PerspectivePosterDeck(
                    items: items,
                    onOpenDetail: { path.append($0) },
                    onMarkWatched: markWatched
                )
                .id(filter)
                .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                PosterGridView(items: items) { path.append($0) }
                    .id("grid-\(filter.rawValue)")
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.3), value: filter)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: mode)
    }

    /// Marca como vista directamente desde el deck (sin estrellas/nota —
    /// ese flujo completo sigue en la ficha) y cambia a "Vistas".
    private func markWatched(_ item: MediaItem) {
        item.markAsWatched(impact: nil, note: nil, watchedAt: .now)
        onRequestVistas()
    }
}

/// Cabecera de biblioteca: título grande + contador, con controles
/// opcionales a la derecha. Compartida por "Quiero ver" y "Vistas".
struct LibraryHeader<Accessory: View>: View {
    let title: String
    let count: Int
    /// Singular del sustantivo ("guardada" / "archivada"); el plural
    /// añade una "s".
    let noun: String
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(title)
                    .font(.largeTitle.bold())
                Text(countLabel)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            accessory
        }
        .padding(.horizontal, Spacing.screenMargin)
        .padding(.top, Spacing.sm)
    }

    private var countLabel: String {
        count == 1 ? "1 \(noun)" : "\(count) \(noun)s"
    }
}

extension LibraryHeader where Accessory == EmptyView {
    init(title: String, count: Int, noun: String) {
        self.init(title: title, count: count, noun: noun) { EmptyView() }
    }
}

/// Aviso centrado cuando un filtro no tiene resultados. Vista única
/// (no varios hijos sueltos) para rellenar el espacio del deck sin que
/// los modificadores del contenedor se apliquen a cada elemento.
struct EmptyFilterNotice: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No hay nada con este filtro.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    QuieroVerView(path: .constant(NavigationPath()))
        .modelContainer(for: [MediaItem.self, FavoritePerson.self], inMemory: true)
}
